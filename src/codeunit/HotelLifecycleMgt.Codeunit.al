codeunit 50100 "Hotel Lifecycle Mgt."
{
    procedure CheckRoomAvailability(RoomNo: Code[20]; CheckIn: Date; CheckOut: Date; ExcludeReservationNo: Code[20])
    var
        Reservation: Record "Hotel Reservation";
    begin
        if RoomNo = '' then
            exit;
        if (CheckIn = 0D) or (CheckOut = 0D) then
            exit;
        if CheckIn >= CheckOut then
            Error('Check-in Date must be before Check-out Date.');

        Reservation.SetRange("Room No.", RoomNo);
        Reservation.SetFilter(Status, '%1|%2', Reservation.Status::Confirmed, Reservation.Status::Occupied);
        if ExcludeReservationNo <> '' then
            Reservation.SetFilter("Reservation No.", '<>%1', ExcludeReservationNo);

        if Reservation.FindSet() then begin
            repeat
                if (CheckIn < Reservation."Check-out Date") and (CheckOut > Reservation."Check-in Date") then
                    Error('Room %1 is already booked/occupied for the selected dates.', RoomNo);
            until Reservation.Next() = 0;
        end;
    end;

    procedure CaptureDeposit(var Reservation: Record "Hotel Reservation"; Success: Boolean)
    begin
        Reservation.TestField(Status, Reservation.Status::Confirmed);
        Reservation.TestField("Deposit Amount");
        if Reservation."Deposit Amount" <= 0 then
            Error('Deposit Amount must be greater than zero to capture.');
        if Reservation."Deposit Paid" then
            Error('Deposit has already been paid for this reservation.');

        if not Success then
            Error('Deposit payment failed. Reservation deposit cannot be marked as paid.');

        Reservation."Deposit Paid" := true;
        Reservation.Modify(true);

        InsertLedgerEntry(
            Reservation."Reservation No.",
            'DEP-' + Reservation."Reservation No.",
            "Hotel Ledger Entry Type"::Deposit,
            -Reservation."Deposit Amount",
            Reservation."Customer No."
        );
    end;

    procedure CheckIn(var Reservation: Record "Hotel Reservation")
    var
        Room: Record "Hotel Room";
    begin
        Reservation.TestField(Status, Reservation.Status::Confirmed);
        Reservation.TestField("Room No.");
        Reservation.TestField("Check-in Date");
        Reservation.TestField("Check-out Date");

        if Reservation."Deposit Amount" > 0 then begin
            if not Reservation."Deposit Paid" then
                Error('Deposit of %1 must be paid before check-in.', Reservation."Deposit Amount");
        end;

        Room.Get(Reservation."Room No.");
        if Room.Occupied then
            Error('Room %1 is currently occupied.', Reservation."Room No.");

        Reservation.Status := Reservation.Status::Occupied;
        Reservation.Modify(true);

        Room.Occupied := true;
        Room.Modify(true);
    end;

    procedure GenerateInvoice(var Reservation: Record "Hotel Reservation")
    var
        Room: Record "Hotel Room";
        Setup: Record "Hotel Setup";
        ServiceCharge: Record "Hotel Service Charge";
        Nights: Integer;
        RoomCost: Decimal;
        ServiceCost: Decimal;
        VATRate: Decimal;
        TotalNet: Decimal;
        TotalVAT: Decimal;
    begin
        Reservation.TestField(Status, Reservation.Status::Occupied);
        if Reservation.Invoiced then
            Error('Invoice has already been generated for this reservation.');

        Room.Get(Reservation."Room No.");
        Nights := Reservation."Check-out Date" - Reservation."Check-in Date";
        if Nights <= 0 then
            Nights := 1;

        RoomCost := Nights * Room."Nightly Rate";

        // Calculate Service Charges
        ServiceCharge.SetRange("Reservation No.", Reservation."Reservation No.");
        if ServiceCharge.FindSet() then begin
            repeat
                ServiceCost += ServiceCharge.Amount;
            until ServiceCharge.Next() = 0;
        end;

        TotalNet := RoomCost + ServiceCost;

        // Get VAT rate
        VATRate := 0;
        if Setup.Get() then
            VATRate := Setup."VAT %";

        TotalVAT := Round(TotalNet * (VATRate / 100), 0.01);

        Reservation."Invoice No." := 'INV-' + Reservation."Reservation No.";
        Reservation.Invoiced := true;
        Reservation.Modify(true);

        // Post Charges to Ledger (Positive amounts for debits)
        InsertLedgerEntry(Reservation."Reservation No.", Reservation."Invoice No.", "Hotel Ledger Entry Type"::"Room Charge", RoomCost, Reservation."Customer No.");

        if ServiceCost > 0 then begin
            ServiceCharge.SetRange("Reservation No.", Reservation."Reservation No.");
            if ServiceCharge.FindSet() then begin
                repeat
                    InsertLedgerEntry(Reservation."Reservation No.", Reservation."Invoice No.", "Hotel Ledger Entry Type"::"Service Charge", ServiceCharge.Amount, Reservation."Customer No.");
                until ServiceCharge.Next() = 0;
            end;
        end;

        if TotalVAT > 0 then
            InsertLedgerEntry(Reservation."Reservation No.", Reservation."Invoice No.", "Hotel Ledger Entry Type"::VAT, TotalVAT, Reservation."Customer No.");
    end;

    procedure PostFinalPayment(var Reservation: Record "Hotel Reservation"; Success: Boolean)
    var
        RemainingDue: Decimal;
    begin
        Reservation.TestField(Invoiced, true);
        if not Success then
            Error('Payment failed. Cannot post final payment.');

        RemainingDue := GetNetAmountDue(Reservation."Reservation No.");
        if RemainingDue <= 0 then
            Error('There is no remaining amount due to settle.');

        InsertLedgerEntry(Reservation."Reservation No.", Reservation."Invoice No.", "Hotel Ledger Entry Type"::Payment, -RemainingDue, Reservation."Customer No.");
    end;

    procedure CheckOut(var Reservation: Record "Hotel Reservation")
    var
        Room: Record "Hotel Room";
        RemainingDue: Decimal;
    begin
        Reservation.TestField(Status, Reservation.Status::Occupied);
        Reservation.TestField(Invoiced, true);

        RemainingDue := GetNetAmountDue(Reservation."Reservation No.");
        if RemainingDue <> 0 then
            Error('Reservation cannot be checked out because the remaining amount due is %1 (must be 0).', RemainingDue);

        Room.Get(Reservation."Room No.");
        Room.Occupied := false;
        Room.Modify(true);

        Reservation.Status := Reservation.Status::Closed;
        Reservation.Modify(true);
    end;

    procedure ProcessRefund(var Reservation: Record "Hotel Reservation"; RefundAmount: Decimal; RefundSuccess: Boolean)
    var
        SecurityMgt: Codeunit "Hotel Security Mgt.";
        TotalPaid: Decimal;
        TotalRefunded: Decimal;
        MaxRefundable: Decimal;
    begin
        SecurityMgt.CheckFinancePermission();

        if not RefundSuccess then
            Error('Refund transaction failed.');

        if RefundAmount <= 0 then
            Error('Refund amount must be positive.');

        TotalPaid := GetTotalPaid(Reservation."Reservation No.");
        TotalRefunded := GetTotalRefunded(Reservation."Reservation No.");
        MaxRefundable := TotalPaid - TotalRefunded;

        if RefundAmount > MaxRefundable then
            Error('Cannot refund %1. Maximum refundable amount is %2.', RefundAmount, MaxRefundable);

        InsertLedgerEntry(Reservation."Reservation No.", 'REF-' + Reservation."Reservation No.", "Hotel Ledger Entry Type"::Refund, RefundAmount, Reservation."Customer No.");
    end;

    procedure GetNetAmountDue(ReservationNo: Code[20]): Decimal
    var
        LedgerEntry: Record "Hotel Ledger Entry";
        Total: Decimal;
    begin
        LedgerEntry.SetRange("Reservation No.", ReservationNo);
        if LedgerEntry.FindSet() then begin
            repeat
                Total += LedgerEntry.Amount;
            until LedgerEntry.Next() = 0;
        end;
        exit(Total);
    end;

    procedure GetTotalPaid(ReservationNo: Code[20]): Decimal
    var
        LedgerEntry: Record "Hotel Ledger Entry";
        Total: Decimal;
    begin
        LedgerEntry.SetRange("Reservation No.", ReservationNo);
        LedgerEntry.SetFilter("Entry Type", '%1|%2', LedgerEntry."Entry Type"::Deposit, LedgerEntry."Entry Type"::Payment);
        if LedgerEntry.FindSet() then begin
            repeat
                Total += LedgerEntry.Amount;
            until LedgerEntry.Next() = 0;
        end;
        exit(-Total);
    end;

    procedure GetTotalRefunded(ReservationNo: Code[20]): Decimal
    var
        LedgerEntry: Record "Hotel Ledger Entry";
        Total: Decimal;
    begin
        LedgerEntry.SetRange("Reservation No.", ReservationNo);
        LedgerEntry.SetRange("Entry Type", LedgerEntry."Entry Type"::Refund);
        if LedgerEntry.FindSet() then begin
            repeat
                Total += LedgerEntry.Amount;
            until LedgerEntry.Next() = 0;
        end;
        exit(Total);
    end;

    local procedure InsertLedgerEntry(ReservationNo: Code[20]; DocNo: Code[20]; EntryType: Enum "Hotel Ledger Entry Type"; Amount: Decimal; CustNo: Code[20])
    var
        LedgerEntry: Record "Hotel Ledger Entry";
        LastEntryNo: Integer;
    begin
        if LedgerEntry.FindLast() then
            LastEntryNo := LedgerEntry."Entry No.";

        LedgerEntry.Init();
        LedgerEntry."Entry No." := LastEntryNo + 1;
        LedgerEntry."Reservation No." := ReservationNo;
        LedgerEntry."Posting Date" := WorkDate();
        LedgerEntry."Document No." := DocNo;
        LedgerEntry."Entry Type" := EntryType;
        LedgerEntry.Amount := Amount;
        LedgerEntry."Customer No." := CustNo;
        LedgerEntry.Insert(true);
    end;
}
