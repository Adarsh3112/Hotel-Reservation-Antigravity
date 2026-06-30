page 50135 "BSB Hotel Service Lines"
{
    PageType = ListPart;
    SourceTable = "BSB Hotel Service Line";
    Caption = 'Hotel Service Lines';
    ApplicationArea = All;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Service Type"; Rec."Service Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field(Billable; Rec.Billable)
                {
                    ApplicationArea = All;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
