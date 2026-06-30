codeunit 50133 "BSH Refund Mgt"
{
    procedure ProcessRefund(var Reservation: Record "BSH Reservation"; Amount: Decimal; Reason: Text[100]; IsFinanceUser: Boolean)
    var
        PaymentEntry: Record "BSH Payment Entry";
    begin
        if not IsFinanceUser then
            Error('Only Finance users can process refunds.');
        if Reservation."Invoice No." = '' then
            Error('An invoice must exist before refund.');
        if Amount <= 0 then
            Error('Refund amount must be greater than zero.');
        if Reason = '' then
            Error('Refund reason is required.');

        PaymentEntry.Init();
        PaymentEntry.Validate("Reservation No.", Reservation."Reservation No.");
        PaymentEntry.Validate("Payment Type", PaymentEntry."Payment Type"::Refund);
        PaymentEntry.Validate("Payment Status", PaymentEntry."Payment Status"::Posted);
        PaymentEntry.Validate(Amount, Amount);
        PaymentEntry.Validate("Posting Date", Today());
        PaymentEntry.Validate("Processed Role", 'Finance');
        PaymentEntry.Insert(true);
    end;
}
