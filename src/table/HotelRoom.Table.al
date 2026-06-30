table 50100 "Hotel Room"
{
    DataClassification = CustomerContent;
    Caption = 'Hotel Room';
    LookupPageId = "Hotel Room List";
    DrillDownPageId = "Hotel Room List";

    fields
    {
        field(1; "Room No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Room No.';
            NotBlank = true;
        }
        field(2; "Room Type"; Enum "Hotel Room Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Room Type';
        }
        field(3; "Nightly Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Nightly Rate';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
        }
        field(4; Occupied; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Occupied';
        }
    }

    keys
    {
        key(PK; "Room No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Room No.", "Room Type", "Nightly Rate", Occupied)
        {
        }
    }
}
