page 50104 "Room Lookup"
{
    Caption = 'Room Lookup';
    PageType = List;
    SourceTable = "Room";
    ApplicationArea = All;
    UsageCategory = None;
    Editable = false;
    SourceTableView = where(Occupied = const(false));

    layout
    {
        area(Content)
        {
            repeater(RoomLines)
            {
                field("Room No."; Rec."Room No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the room.';
                }
                field("Room Type"; Rec."Room Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type/category of the room.';
                }
                field("Nightly Rate"; Rec."Nightly Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the nightly rate charged for the room.';
                }
                field("Occupied"; Rec."Occupied")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether the room is currently occupied by a guest.';
                }
            }
        }
    }
}
