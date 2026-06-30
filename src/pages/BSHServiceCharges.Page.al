page 50125 "BSH Service Charges"
{
    Caption = 'BSH Service Charges';
    PageType = ListPart;
    SourceTable = "BSH Service Charge";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Charges)
            {
                field("Charge Type"; Rec."Charge Type")
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
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Billable; Rec.Billable)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
