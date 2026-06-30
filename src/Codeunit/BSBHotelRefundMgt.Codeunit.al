codeunit 50121 "BSB Hotel Refund Mgt."
{
    procedure ProcessRefund(var Reservation: Record "BSB Hotel Reservation"; RefundAmount: Decimal)
    var
        HotelMgt: Codeunit "BSB Hotel Mgt.";
    begin
        RequireFinanceUser();
        Reservation.TestField("Reservation No.");
        Reservation.TestField("Final Payment Posted", true);
        if Reservation."Refund Posted" then
            Error('A refund has already been posted for reservation %1.', Reservation."Reservation No.");
        if RefundAmount <= 0 then
            Error('Refund amount must be positive.');
        if RefundAmount > Reservation."Invoice Amount" then
            Error('Refund amount cannot exceed invoice amount.');

        Reservation."Refund Amount" := RefundAmount;
        Reservation."Refund Posted" := true;
        Reservation.Modify(true);
        HotelMgt.CreateLedgerEntry(Reservation."Reservation No.", Enum::"BSB Hotel Ledger Type"::Refund, -RefundAmount, Reservation."Invoice No.", 'Refund posted');
    end;

    procedure RequireFinanceUser()
    var
        UserRole: Record "BSB Hotel User Role";
    begin
        if not UserRole.Get(UserId()) then
            Error('User %1 is not authorized to process hotel refunds.', UserId());
        if not (UserRole.Role in [UserRole.Role::Finance, UserRole.Role::Admin]) then
            Error('User %1 is not authorized to process hotel refunds.', UserId());
    end;
}
