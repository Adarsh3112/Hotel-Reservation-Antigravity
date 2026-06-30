page 50132 "BSB Hotel Room Card"
{
    PageType = Card;
    SourceTable = "BSB Hotel Room";
    Caption = 'Hotel Room';
    ApplicationArea = All;
    UsageCategory = None;

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
            }
        }
    }
}
