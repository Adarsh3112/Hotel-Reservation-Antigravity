table 50111 "BSB Hotel Room"
{
    Caption = 'Hotel Room';
    DataClassification = CustomerContent;
    LookupPageId = "BSB Hotel Room List";
    DrillDownPageId = "BSB Hotel Room List";

    fields
    {
        field(1; "Room No."; Code[20])
        {
            Caption = 'Room No.';
            NotBlank = true;
        }
        field(2; "Room Type"; Code[30])
        {
            Caption = 'Room Type';
        }
        field(3; "Nightly Rate"; Decimal)
        {
            Caption = 'Nightly Rate';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(4; Occupied; Boolean)
        {
            Caption = 'Occupied';
            Editable = false;
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
