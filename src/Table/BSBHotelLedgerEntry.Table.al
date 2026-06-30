table 50114 "BSB Hotel Ledger Entry"
{
    Caption = 'Hotel Ledger Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Reservation No."; Code[20])
        {
            Caption = 'Reservation No.';
            TableRelation = "BSB Hotel Reservation";
        }
        field(3; "Entry Type"; Enum "BSB Hotel Ledger Type")
        {
            Caption = 'Entry Type';
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Reservation; "Reservation No.", "Entry Type")
        {
        }
    }
}
