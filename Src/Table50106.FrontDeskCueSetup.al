table 50106 "Front Desk Cue Setup"
{
    Caption = 'Front Desk Cue Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Occupied Rooms"; Integer)
        {
            Caption = 'Occupied Rooms';
            FieldClass = FlowField;
            CalcFormula = count("Reservation Header" where(Status = const(Occupied)));
            Editable = false;
            ToolTip = 'Specifies the number of reservations currently in Occupied status.';
        }
        field(3; "Pending Check-Ins Today"; Integer)
        {
            Caption = 'Pending Check-Ins Today';
            FieldClass = FlowField;
            CalcFormula = count("Reservation Header" where(
                Status = const(Confirmed),
                "Check-In Date" = field("Date Filter")));
            Editable = false;
            ToolTip = 'Specifies the number of Confirmed reservations with a Check-In Date matching the date filter (today by default).';
        }
        field(4; "Total Confirmed Reservations"; Integer)
        {
            Caption = 'Total Confirmed Reservations';
            FieldClass = FlowField;
            CalcFormula = count("Reservation Header" where(Status = const(Confirmed)));
            Editable = false;
            ToolTip = 'Specifies the total number of reservations in Confirmed status.';
        }
        field(5; "Available Rooms"; Integer)
        {
            Caption = 'Available Rooms';
            FieldClass = FlowField;
            CalcFormula = count(Room where(Occupied = const(false)));
            Editable = false;
            ToolTip = 'Specifies the number of rooms not currently marked as Occupied.';
        }
        field(6; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecordOrInitialize()
    begin
        if not Get('') then begin
            Init();
            "Primary Key" := '';
            Insert();
        end;
    end;
}
