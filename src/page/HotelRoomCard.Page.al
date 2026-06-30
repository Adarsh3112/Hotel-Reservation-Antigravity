page 50101 "Hotel Room Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Hotel Room";
    Caption = 'Hotel Room Card';

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
                    ToolTip = 'Specifies the unique room number.';
                }
                field("Room Type"; Rec."Room Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the room category.';
                }
                field("Nightly Rate"; Rec."Nightly Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the nightly rate for renting the room.';
                }
                field(Occupied; Rec.Occupied)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if this room is currently occupied.';
                }
            }
        }
    }
}
