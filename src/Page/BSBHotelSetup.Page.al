page 50130 "BSB Hotel Setup"
{
    PageType = Card;
    SourceTable = "BSB Hotel Setup";
    Caption = 'Hotel Setup';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Res. Nos."; Rec."Res. Nos.")
                {
                    ApplicationArea = All;
                }
                field("Deposit Required"; Rec."Deposit Required")
                {
                    ApplicationArea = All;
                }
                field("Default Deposit %"; Rec."Default Deposit %")
                {
                    ApplicationArea = All;
                }
            }
            group(Posting)
            {
                field("Room G/L Account"; Rec."Room G/L Account")
                {
                    ApplicationArea = All;
                }
                field("Service G/L Account"; Rec."Service G/L Account")
                {
                    ApplicationArea = All;
                }
                field("Deposit G/L Account"; Rec."Deposit G/L Account")
                {
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetRecord();
    end;
}
