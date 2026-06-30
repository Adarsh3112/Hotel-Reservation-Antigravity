page 50131 "BSB Hotel Room List"
{
    PageType = List;
    SourceTable = "BSB Hotel Room";
    CardPageId = "BSB Hotel Room Card";
    Caption = 'Hotel Rooms';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Rooms)
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
