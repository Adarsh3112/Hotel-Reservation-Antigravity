table 50114 "BSH Payment Entry"
{
    Caption = 'BSH Payment Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Reservation No."; Code[20])
        {
            Caption = 'Reservation No.';
            DataClassification = CustomerContent;
            TableRelation = "BSH Reservation"."Reservation No.";
        }
        field(3; "Payment Type"; Option)
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
            OptionMembers = Deposit,"Final Payment",Refund;
        }
        field(4; "Payment Status"; Enum "BSH Payment Status")
        {
            Caption = 'Payment Status';
            DataClassification = CustomerContent;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(7; "External Ref."; Code[50])
        {
            Caption = 'External Ref.';
            DataClassification = CustomerContent;
        }
        field(8; "Ledger Entry No."; Integer)
        {
            Caption = 'Ledger Entry No.';
            DataClassification = CustomerContent;
        }
        field(9; "Processed Role"; Text[30])
        {
            Caption = 'Processed Role';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Reservation; "Reservation No.", "Payment Type", "Payment Status")
        {
        }
    }
}
