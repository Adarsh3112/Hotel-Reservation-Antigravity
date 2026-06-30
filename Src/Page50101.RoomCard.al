page 50101 "Room Card"
{
    Caption = 'Room Card';
    PageType = Card;
    SourceTable = "Room";
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                    Editable = false;
                    ToolTip = 'Indicates whether the room is currently occupied. This flag is updated automatically by reservation status changes.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(RoomList)
            {
                Caption = 'Room List';
                ApplicationArea = All;
                Image = List;
                RunObject = Page "Room List";
                ToolTip = 'View the full list of rooms.';
            }
        }
        area(Promoted)
        {
            actionref(RoomList_Promoted; RoomList) { }
        }
    }
}
