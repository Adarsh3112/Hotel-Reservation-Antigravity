table 50100 "Room"
{
    Caption = 'Room';
    DataClassification = CustomerContent;
    LookupPageId = "Room List";
    DrillDownPageId = "Room List";

    fields
    {
        field(1; "Room No."; Code[20])
        {
            Caption = 'Room No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Room Type"; Enum "Room Type")
        {
            Caption = 'Room Type';
            DataClassification = CustomerContent;
        }
        field(3; "Nightly Rate"; Decimal)
        {
            Caption = 'Nightly Rate';
            DataClassification = CustomerContent;
            MinValue = 0;
            AutoFormatType = 1;
        }
        field(4; "Occupied"; Boolean)
        {
            Caption = 'Occupied';
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

    fieldgroups
    {
        fieldgroup(DropDown; "Room No.", "Room Type", "Nightly Rate") { }
        fieldgroup(Brick; "Room No.", "Room Type", "Nightly Rate") { }
    }

    trigger OnDelete()
    begin
        if Rec.Occupied then
            Error('You cannot delete an occupied room.');
    end;

    trigger OnRename()
    begin
        if xRec.Occupied then
            Error('You cannot rename an occupied room.');
    end;
}
