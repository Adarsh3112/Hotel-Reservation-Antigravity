page 50100 "Hotel Room List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Hotel Room";
    CardPageId = "Hotel Room Card";
    Caption = 'Hotel Rooms';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Room No."; Rec."Room No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique room number.';
                }
                field("Room Type"; Rec."Room Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the room category (Single, Double, or Suite).';
                }
                field("Nightly Rate"; Rec."Nightly Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the nightly rate for renting the room.';
                }
                field(Occupied; Rec.Occupied)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if this room is currently checked into.';
                }
            }
        }
    }
}
