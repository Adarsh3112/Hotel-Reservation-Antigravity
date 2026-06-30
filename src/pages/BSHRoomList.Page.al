page 50121 "BSH Room List"
{
    Caption = 'BSH Rooms';
    PageType = List;
    SourceTable = "BSH Room";
    CardPageId = "BSH Room Card";
    ApplicationArea = All;
    UsageCategory = Lists;

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
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
