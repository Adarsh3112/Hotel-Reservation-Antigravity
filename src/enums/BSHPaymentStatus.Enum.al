enum 50102 "BSH Payment Status"
{
    Extensible = false;

    value(0; None)
    {
        Caption = 'None';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Captured)
    {
        Caption = 'Captured';
    }
    value(3; Failed)
    {
        Caption = 'Failed';
    }
    value(4; Posted)
    {
        Caption = 'Posted';
    }
    value(5; Reconciled)
    {
        Caption = 'Reconciled';
    }
}
