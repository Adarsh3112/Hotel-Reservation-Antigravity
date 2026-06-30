page 50100 "Room List"
{
    Caption = 'Room List';
    PageType = List;
    SourceTable = "Room";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Room Card";
    Editable = false;

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

    actions
    {
        area(Processing)
        {
            action(NewRoom)
            {
                Caption = 'New Room';
                ApplicationArea = All;
                Image = New;
                RunObject = Page "Room Card";
                RunPageMode = Create;
                ToolTip = 'Create a new room record.';
            }
        }
        area(Promoted)
        {
            actionref(NewRoom_Promoted; NewRoom) { }
        }
    }
}
