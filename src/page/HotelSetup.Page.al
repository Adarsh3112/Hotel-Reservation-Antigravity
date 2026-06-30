page 50105 "Hotel Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Hotel Setup";
    Caption = 'Hotel Setup';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default VAT percentage for hotel invoicing.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}
