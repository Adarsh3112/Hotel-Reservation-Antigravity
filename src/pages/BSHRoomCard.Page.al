page 50122 "BSH Room Card"
{
    Caption = 'BSH Room';
    PageType = Card;
    SourceTable = "BSH Room";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Room No."; Rec."Room No.")
                {
                    ApplicationArea = All;
                }
                field("Room Type"; Rec."Room Type")
                {
                    ApplicationArea = All;
                }
                field("Nightly Rate"; Rec."Nightly Rate")
                {
                    ApplicationArea = All;
                }
                field(Occupied; Rec.Occupied)
                {
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
