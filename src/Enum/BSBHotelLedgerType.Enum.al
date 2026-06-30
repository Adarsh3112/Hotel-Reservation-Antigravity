enum 50102 "BSB Hotel Ledger Type"
{
    Extensible = false;

    value(0; Deposit)
    {
        Caption = 'Deposit';
    }
    value(1; Invoice)
    {
        Caption = 'Invoice';
    }
    value(2; Payment)
    {
        Caption = 'Payment';
    }
    value(3; Refund)
    {
        Caption = 'Refund';
    }
}
