table 50111 "BSH Room"
{
    Caption = 'BSH Room';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Room No."; Code[20])
        {
            Caption = 'Room No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Room Type"; Text[30])
        {
            Caption = 'Room Type';
            DataClassification = CustomerContent;
        }
        field(3; "Nightly Rate"; Decimal)
        {
            Caption = 'Nightly Rate';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(4; Occupied; Boolean)
        {
            Caption = 'Occupied';
            DataClassification = CustomerContent;
        }
        field(5; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Room No.")
        {
            Clustered = true;
        }
    }
}
