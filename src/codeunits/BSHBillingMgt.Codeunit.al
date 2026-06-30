codeunit 50131 "BSH Billing Mgt"
{
    procedure GenerateInvoice(var Reservation: Record "BSH Reservation"): Code[20]
    var
        HotelSetup: Record "BSH Hotel Setup";
        PaymentMgt: Codeunit "BSH Payment Mgt";
        LodgingAmount: Decimal;
        ServiceAmount: Decimal;
        DepositApplied: Decimal;
        VATAmount: Decimal;
        TotalAmount: Decimal;
    begin
        if Reservation.Status <> Reservation.Status::Occupied then
            Error('Only occupied reservations can be invoiced.');
        if Reservation."Invoice No." <> '' then
            Error('Reservation %1 already has invoice %2.', Reservation."Reservation No.", Reservation."Invoice No.");

        HotelSetup.GetSetup();
        LodgingAmount := CalcLodging(Reservation);
        ServiceAmount := CalcServiceTotal(Reservation."Reservation No.");
        VATAmount := Round((LodgingAmount + ServiceAmount) * HotelSetup."VAT Percent" / 100, 0.01);
        DepositApplied := PaymentMgt.GetCapturedDeposit(Reservation."Reservation No.");
        TotalAmount := LodgingAmount + ServiceAmount + VATAmount - DepositApplied;
        if TotalAmount < 0 then
            TotalAmount := 0;

        Reservation.Validate("Lodging Amount", LodgingAmount);
        Reservation.Validate("Service Amount", ServiceAmount);
        Reservation.Validate("VAT Amount", VATAmount);
        Reservation.Validate("Deposit Applied", DepositApplied);
        Reservation.Validate("Remaining Due", TotalAmount);
        Reservation.Validate("Invoice No.", CopyStr('INV-' + Reservation."Reservation No.", 1, MaxStrLen(Reservation."Invoice No.")));
        Reservation.Modify(true);
        exit(Reservation."Invoice No.");
    end;

    procedure CalcLodging(Reservation: Record "BSH Reservation"): Decimal
    var
        Room: Record "BSH Room";
        Nights: Integer;
    begin
        Reservation.ValidateDates();
        if Reservation."Room No." = '' then
            Error('A room must be assigned before invoicing.');
        if not Room.Get(Reservation."Room No.") then
            Error('Room %1 does not exist.', Reservation."Room No.");

        Nights := Reservation."Check-out Date" - Reservation."Check-in Date";
        exit(Nights * Room."Nightly Rate");
    end;

    procedure CalcServiceTotal(ReservationNo: Code[20]): Decimal
    var
        ServiceCharge: Record "BSH Service Charge";
        Amount: Decimal;
    begin
        ServiceCharge.SetRange("Reservation No.", ReservationNo);
        ServiceCharge.SetRange(Billable, true);
        if ServiceCharge.FindSet() then
            repeat
                Amount += ServiceCharge.Amount;
            until ServiceCharge.Next() = 0;
        exit(Amount);
    end;

    procedure ValidateTaxSetup()
    var
        HotelSetup: Record "BSH Hotel Setup";
    begin
        HotelSetup.GetSetup();
        if HotelSetup."VAT Percent" < 0 then
            Error('VAT percent cannot be negative.');
    end;
}
