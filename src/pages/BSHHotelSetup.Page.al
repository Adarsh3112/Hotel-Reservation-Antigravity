page 50120 "BSH Hotel Setup"
{
    Caption = 'BSH Hotel Setup';
    PageType = Card;
    SourceTable = "BSH Hotel Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("VAT Percent"; Rec."VAT Percent")
                {
                    ApplicationArea = All;
                }
                field("Room Nos."; Rec."Room Nos.")
                {
                    ApplicationArea = All;
                }
                field("Reservation Nos."; Rec."Reservation Nos.")
                {
                    ApplicationArea = All;
                }
                field("Deposit Item No."; Rec."Deposit Item No.")
                {
                    ApplicationArea = All;
                }
                field("Service Item No."; Rec."Service Item No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
