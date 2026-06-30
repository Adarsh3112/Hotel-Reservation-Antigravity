page 50134 "BSB Hotel Res. Card"
{
    PageType = Card;
    SourceTable = "BSB Hotel Reservation";
    Caption = 'Hotel Reservation';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Reservation No."; Rec."Reservation No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Room No."; Rec."Room No.")
                {
                    ApplicationArea = All;
                }
                field("Check-in Date"; Rec."Check-in Date")
                {
                    ApplicationArea = All;
                }
                field("Check-out Date"; Rec."Check-out Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
            group(Deposit)
            {
                field("Deposit Amount"; Rec."Deposit Amount")
                {
                    ApplicationArea = All;
                }
                field("Deposit Captured"; Rec."Deposit Captured")
                {
                    ApplicationArea = All;
                }
                field("Captured Deposit Amt."; Rec."Captured Deposit Amt.")
                {
                    ApplicationArea = All;
                }
            }
            group(Billing)
            {
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Invoice Amount"; Rec."Invoice Amount")
                {
                    ApplicationArea = All;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                }
                field("Final Payment Posted"; Rec."Final Payment Posted")
                {
                    ApplicationArea = All;
                }
                field("Refund Posted"; Rec."Refund Posted")
                {
                    ApplicationArea = All;
                }
            }
            part(ServiceLines; "BSB Hotel Service Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Reservation No." = field("Reservation No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CaptureDeposit)
            {
                Caption = 'Capture Deposit';
                ApplicationArea = All;

                trigger OnAction()
                var
                    HotelMgt: Codeunit "BSB Hotel Mgt.";
                begin
                    HotelMgt.CaptureDeposit(Rec, true);
                end;
            }
            action(CheckIn)
            {
                Caption = 'Check In';
                ApplicationArea = All;

                trigger OnAction()
                var
                    HotelMgt: Codeunit "BSB Hotel Mgt.";
                begin
                    HotelMgt.CheckIn(Rec);
                end;
            }
            action(CheckOut)
            {
                Caption = 'Check Out';
                ApplicationArea = All;

                trigger OnAction()
                var
                    HotelMgt: Codeunit "BSB Hotel Mgt.";
                begin
                    HotelMgt.CheckOut(Rec);
                end;
            }
            action(GenerateInvoice)
            {
                Caption = 'Generate Invoice';
                ApplicationArea = All;

                trigger OnAction()
                var
                    HotelMgt: Codeunit "BSB Hotel Mgt.";
                begin
                    HotelMgt.GenerateInvoice(Rec);
                end;
            }
            action(PostFinalPayment)
            {
                Caption = 'Post Final Payment';
                ApplicationArea = All;

                trigger OnAction()
                var
                    HotelMgt: Codeunit "BSB Hotel Mgt.";
                begin
                    HotelMgt.PostFinalPayment(Rec);
                end;
            }
        }
    }
}
