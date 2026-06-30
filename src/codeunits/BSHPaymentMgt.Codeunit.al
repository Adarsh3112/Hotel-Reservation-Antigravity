codeunit 50132 "BSH Payment Mgt"
{
    procedure RecordDeposit(var Reservation: Record "BSH Reservation"; Amount: Decimal; Captured: Boolean; ExternalRef: Code[50])
    var
        PaymentEntry: Record "BSH Payment Entry";
    begin
        if Reservation.Status = Reservation.Status::Closed then
            Error('Closed reservations cannot receive deposits.');
        if Amount <= 0 then
            Error('Deposit amount must be greater than zero.');

        PaymentEntry.Init();
        PaymentEntry.Validate("Reservation No.", Reservation."Reservation No.");
        PaymentEntry.Validate("Payment Type", PaymentEntry."Payment Type"::Deposit);
        PaymentEntry.Validate(Amount, Amount);
        PaymentEntry.Validate("Posting Date", Today());
        PaymentEntry.Validate("External Ref.", ExternalRef);
        PaymentEntry.Validate("Processed Role", 'Front Desk');
        if Captured then
            PaymentEntry.Validate("Payment Status", PaymentEntry."Payment Status"::Captured)
        else
            PaymentEntry.Validate("Payment Status", PaymentEntry."Payment Status"::Failed);
        PaymentEntry.Insert(true);

        Reservation.Validate("Deposit Amount", Amount);
        if Captured then
            Reservation.Validate("Deposit Status", Reservation."Deposit Status"::Captured)
        else
            Reservation.Validate("Deposit Status", Reservation."Deposit Status"::Failed);
        Reservation.Modify(true);
    end;

    procedure GetCapturedDeposit(ReservationNo: Code[20]): Decimal
    var
        PaymentEntry: Record "BSH Payment Entry";
        Amount: Decimal;
    begin
        PaymentEntry.SetRange("Reservation No.", ReservationNo);
        PaymentEntry.SetRange("Payment Type", PaymentEntry."Payment Type"::Deposit);
        PaymentEntry.SetRange("Payment Status", PaymentEntry."Payment Status"::Captured);
        if PaymentEntry.FindSet() then
            repeat
                Amount += PaymentEntry.Amount;
            until PaymentEntry.Next() = 0;
        exit(Amount);
    end;

    procedure PostFinalPayment(var Reservation: Record "BSH Reservation"; Amount: Decimal)
    var
        PaymentEntry: Record "BSH Payment Entry";
    begin
        if Reservation."Invoice No." = '' then
            Error('An invoice must exist before final payment.');
        if Amount < Reservation."Remaining Due" then
            Error('Final payment must cover the remaining amount due.');

        PaymentEntry.Init();
        PaymentEntry.Validate("Reservation No.", Reservation."Reservation No.");
        PaymentEntry.Validate("Payment Type", PaymentEntry."Payment Type"::"Final Payment");
        PaymentEntry.Validate("Payment Status", PaymentEntry."Payment Status"::Reconciled);
        PaymentEntry.Validate(Amount, Amount);
        PaymentEntry.Validate("Posting Date", Today());
        PaymentEntry.Validate("Processed Role", 'Finance');
        PaymentEntry.Insert(true);

        Reservation.Validate("Final Paid", true);
        Reservation.Validate("Remaining Due", 0);
        Reservation.Modify(true);
    end;
}
