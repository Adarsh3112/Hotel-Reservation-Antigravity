codeunit 50120 "BSB Hotel Mgt."
{
    procedure AssignReservationNo(var Reservation: Record "BSB Hotel Reservation")
    var
        HotelSetup: Record "BSB Hotel Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if Reservation."Reservation No." <> '' then
            exit;

        HotelSetup.GetRecord();
        HotelSetup.TestField("Res. Nos.");
        Reservation."Reservation No." := NoSeries.GetNextNo(HotelSetup."Res. Nos.", WorkDate(), true);
    end;

    procedure ValidateRoomAvailable(Reservation: Record "BSB Hotel Reservation")
    var
        OtherReservation: Record "BSB Hotel Reservation";
    begin
        if (Reservation."Room No." = '') or (Reservation."Check-in Date" = 0D) or (Reservation."Check-out Date" = 0D) then
            exit;

        Reservation.ValidateDateRange();
        OtherReservation.SetRange("Room No.", Reservation."Room No.");
        OtherReservation.SetFilter("Reservation No.", '<>%1', Reservation."Reservation No.");
        OtherReservation.SetFilter(Status, '%1|%2', OtherReservation.Status::Confirmed, OtherReservation.Status::Occupied);
        if OtherReservation.FindSet() then
            repeat
                if DatesOverlap(Reservation."Check-in Date", Reservation."Check-out Date", OtherReservation."Check-in Date", OtherReservation."Check-out Date") then
                    Error('Room %1 is already reserved for dates that overlap %2 to %3.', Reservation."Room No.", Reservation."Check-in Date", Reservation."Check-out Date");
            until OtherReservation.Next() = 0;
    end;

    procedure CaptureDeposit(var Reservation: Record "BSB Hotel Reservation"; PaymentSucceeded: Boolean)
    begin
        Reservation.TestField("Reservation No.");
        Reservation.TestField(Status, Reservation.Status::Confirmed);

        if not PaymentSucceeded then
            Error('Deposit payment failed. The deposit was not captured.');

        Reservation.TestField("Deposit Amount");
        Reservation."Deposit Captured" := true;
        Reservation."Captured Deposit Amt." := Reservation."Deposit Amount";
        Reservation.Modify(true);
        CreateLedgerEntry(Reservation."Reservation No.", Enum::"BSB Hotel Ledger Type"::Deposit, Reservation."Captured Deposit Amt.", '', 'Deposit captured');
    end;

    procedure CheckIn(var Reservation: Record "BSB Hotel Reservation")
    var
        HotelSetup: Record "BSB Hotel Setup";
        Room: Record "BSB Hotel Room";
    begin
        Reservation.TestField("Reservation No.");
        Reservation.TestField("Customer No.");
        Reservation.TestField("Room No.");
        Reservation.TestField(Status, Reservation.Status::Confirmed);
        Reservation.ValidateDateRange();
        ValidateRoomAvailable(Reservation);

        HotelSetup.GetRecord();
        if HotelSetup."Deposit Required" then
            Reservation.TestField("Deposit Captured", true);

        Room.Get(Reservation."Room No.");
        Room.Occupied := true;
        Room.Modify(true);

        Reservation.Status := Reservation.Status::Occupied;
        Reservation.Modify(true);
    end;

    procedure PostServiceCharge(ReservationNo: Code[20]; ServiceType: Enum "BSB Hotel Service Type"; Amount: Decimal): Integer
    var
        Reservation: Record "BSB Hotel Reservation";
        ServiceLine: Record "BSB Hotel Service Line";
    begin
        Reservation.Get(ReservationNo);
        if Reservation.Status = Reservation.Status::Closed then
            Error('Cannot post service charges to closed reservation %1.', ReservationNo);
        if Amount <= 0 then
            Error('Service charge amount must be positive.');

        ServiceLine.Init();
        ServiceLine."Reservation No." := ReservationNo;
        ServiceLine."Service Type" := ServiceType;
        ServiceLine.Description := Format(ServiceType);
        ServiceLine.Amount := Amount;
        ServiceLine.Billable := true;
        ServiceLine.Insert(true);
        exit(ServiceLine."Line No.");
    end;

    procedure CheckOut(var Reservation: Record "BSB Hotel Reservation")
    var
        Room: Record "BSB Hotel Room";
    begin
        Reservation.TestField("Reservation No.");
        Reservation.TestField(Status, Reservation.Status::Occupied);

        Room.Get(Reservation."Room No.");
        Room.Occupied := false;
        Room.Modify(true);

        Reservation.Status := Reservation.Status::Closed;
        Reservation.Modify(true);
    end;

    procedure GenerateInvoice(var Reservation: Record "BSB Hotel Reservation"): Code[20]
    var
        HotelSetup: Record "BSB Hotel Setup";
        Room: Record "BSB Hotel Room";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceLine: Record "BSB Hotel Service Line";
        LineNo: Integer;
        RoomAmount: Decimal;
        ServiceAmount: Decimal;
        NetAmount: Decimal;
        VatAmount: Decimal;
    begin
        Reservation.TestField("Reservation No.");
        Reservation.TestField("Customer No.");
        Reservation.TestField(Status, Reservation.Status::Closed);
        if Reservation."Invoice No." <> '' then
            Error('Invoice %1 has already been generated for reservation %2.', Reservation."Invoice No.", Reservation."Reservation No.");

        HotelSetup.GetRecord();
        HotelSetup.TestField("Room G/L Account");
        HotelSetup.TestField("Service G/L Account");
        HotelSetup.TestField("Deposit G/L Account");

        Room.Get(Reservation."Room No.");
        RoomAmount := CalcNightCount(Reservation) * Room."Nightly Rate";

        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Reservation."Customer No.");
        SalesHeader.Modify(true);

        LineNo := 10000;
        AddSalesLine(SalesHeader, SalesLine, LineNo, HotelSetup."Room G/L Account", 'Room ' + Reservation."Room No.", RoomAmount, HotelSetup."VAT Prod. Posting Group");

        ServiceLine.SetRange("Reservation No.", Reservation."Reservation No.");
        ServiceLine.SetRange(Billable, true);
        if ServiceLine.FindSet(true) then
            repeat
                LineNo += 10000;
                ServiceAmount += ServiceLine.Amount;
                AddSalesLine(SalesHeader, SalesLine, LineNo, HotelSetup."Service G/L Account", ServiceLine.Description, ServiceLine.Amount, HotelSetup."VAT Prod. Posting Group");
                ServiceLine.Posted := true;
                ServiceLine.Modify(true);
            until ServiceLine.Next() = 0;

        if Reservation."Deposit Captured" and (Reservation."Captured Deposit Amt." <> 0) then begin
            LineNo += 10000;
            AddSalesLine(SalesHeader, SalesLine, LineNo, HotelSetup."Deposit G/L Account", 'Deposit applied', -Reservation."Captured Deposit Amt.", HotelSetup."VAT Prod. Posting Group");
        end;

        SalesHeader.CalcFields(Amount, "Amount Including VAT");
        NetAmount := RoomAmount + ServiceAmount - Reservation."Captured Deposit Amt.";
        VatAmount := SalesHeader."Amount Including VAT" - SalesHeader.Amount;
        Reservation."Invoice No." := SalesHeader."No.";
        Reservation."Invoice Amount" := SalesHeader."Amount Including VAT";
        Reservation."VAT Amount" := VatAmount;
        Reservation."Remaining Amount" := SalesHeader."Amount Including VAT";
        Reservation."Invoice Posted" := false;
        Reservation.Modify(true);

        if NetAmount = 0 then;
        CreateLedgerEntry(Reservation."Reservation No.", Enum::"BSB Hotel Ledger Type"::Invoice, Reservation."Invoice Amount", Reservation."Invoice No.", 'Invoice generated');
        exit(Reservation."Invoice No.");
    end;

    procedure PostFinalPayment(var Reservation: Record "BSB Hotel Reservation")
    var
        PaymentAmount: Decimal;
    begin
        Reservation.TestField("Reservation No.");
        Reservation.TestField("Invoice No.");
        if Reservation."Final Payment Posted" then
            Error('Final payment has already been posted for reservation %1.', Reservation."Reservation No.");

        PaymentAmount := Reservation."Remaining Amount";
        if PaymentAmount < 0 then
            Error('Remaining amount cannot be negative.');

        Reservation."Remaining Amount" := 0;
        Reservation."Final Payment Posted" := true;
        Reservation.Modify(true);
        CreateLedgerEntry(Reservation."Reservation No.", Enum::"BSB Hotel Ledger Type"::Payment, PaymentAmount, Reservation."Invoice No.", 'Final payment posted');
    end;

    procedure CalcNightCount(Reservation: Record "BSB Hotel Reservation"): Integer
    begin
        Reservation.ValidateDateRange();
        exit(Reservation."Check-out Date" - Reservation."Check-in Date");
    end;

    procedure CalcServiceAmount(ReservationNo: Code[20]): Decimal
    var
        ServiceLine: Record "BSB Hotel Service Line";
        TotalAmount: Decimal;
    begin
        ServiceLine.SetRange("Reservation No.", ReservationNo);
        ServiceLine.SetRange(Billable, true);
        if ServiceLine.FindSet() then
            repeat
                TotalAmount += ServiceLine.Amount;
            until ServiceLine.Next() = 0;
        exit(TotalAmount);
    end;

    procedure CreateLedgerEntry(ReservationNo: Code[20]; EntryType: Enum "BSB Hotel Ledger Type"; Amount: Decimal; DocumentNo: Code[20]; Description: Text[100])
    var
        LedgerEntry: Record "BSB Hotel Ledger Entry";
    begin
        LedgerEntry.Init();
        LedgerEntry."Reservation No." := ReservationNo;
        LedgerEntry."Entry Type" := EntryType;
        LedgerEntry.Amount := Amount;
        LedgerEntry."Document No." := DocumentNo;
        LedgerEntry."Posting Date" := WorkDate();
        LedgerEntry.Description := Description;
        LedgerEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(LedgerEntry."User ID"));
        LedgerEntry.Insert(true);
    end;

    local procedure AddSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; LineNo: Integer; GLAccountNo: Code[20]; Description: Text[100]; Amount: Decimal; VATProdPostingGroup: Code[20])
    begin
        if Amount = 0 then
            exit;

        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", LineNo);
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", GLAccountNo);
        SalesLine.Validate(Description, Description);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", Amount);
        if VATProdPostingGroup <> '' then
            SalesLine.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        SalesLine.Modify(true);
    end;

    local procedure DatesOverlap(StartDate: Date; EndDate: Date; OtherStartDate: Date; OtherEndDate: Date): Boolean
    begin
        exit((StartDate < OtherEndDate) and (EndDate > OtherStartDate));
    end;
}
