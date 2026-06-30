enum 50103 "Hotel Ledger Entry Type"
{
    Extensible = true;

    value(0; Deposit)
    {
        Caption = 'Deposit';
    }
    value(1; "Room Charge")
    {
        Caption = 'Room Charge';
    }
    value(2; "Service Charge")
    {
        Caption = 'Service Charge';
    }
    value(3; VAT)
    {
        Caption = 'VAT';
    }
    value(4; Payment)
    {
        Caption = 'Payment';
    }
    value(5; Refund)
    {
        Caption = 'Refund';
    }
}
