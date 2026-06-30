table 50102 "Hotel Service Charge"
{
    DataClassification = CustomerContent;
    Caption = 'Hotel Service Charge';

    fields
    {
        field(1; "Reservation No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reservation No.';
            TableRelation = "Hotel Reservation";
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(3; "Service Type"; Enum "Hotel Service Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Service Type';
        }
        field(4; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Reservation No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
