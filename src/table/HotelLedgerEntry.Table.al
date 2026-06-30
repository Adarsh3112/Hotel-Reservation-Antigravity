table 50104 "Hotel Ledger Entry"
{
    DataClassification = CustomerContent;
    Caption = 'Hotel Ledger Entry';
    LookupPageId = "Hotel Ledger Entries";
    DrillDownPageId = "Hotel Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; "Reservation No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reservation No.';
            TableRelation = "Hotel Reservation";
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(4; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(5; "Entry Type"; Enum "Hotel Ledger Entry Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Type';
        }
        field(6; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            DecimalPlaces = 2 : 2;
        }
        field(7; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Reservation; "Reservation No.")
        {
        }
    }
}
