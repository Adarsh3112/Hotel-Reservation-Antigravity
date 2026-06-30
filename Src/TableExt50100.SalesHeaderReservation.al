tableextension 50100 "Sales Header Hotel Ext" extends "Sales Header"
{
    fields
    {
        field(50100; "Hotel Reservation No."; Code[20])
        {
            Caption = 'Hotel Reservation No.';
            DataClassification = CustomerContent;
            TableRelation = "Reservation Header"."Reservation No.";
            Editable = false;
            ToolTip = 'Specifies the Hotel Reservation number from which this Sales Invoice was generated.';
        }
    }
}
