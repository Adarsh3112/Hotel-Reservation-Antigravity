page 50138 "BSB Hotel Finance Res."
{
    PageType = List;
    SourceTable = "BSB Hotel Reservation";
    Caption = 'Hotel Finance Reservations';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Reservations)
            {
                field("Reservation No."; Rec."Reservation No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Invoice Amount"; Rec."Invoice Amount")
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                }
                field("Refund Posted"; Rec."Refund Posted")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessRefund)
            {
                Caption = 'Process Refund';
                ApplicationArea = All;

                trigger OnAction()
                var
                    RefundMgt: Codeunit "BSB Hotel Refund Mgt.";
                begin
                    RefundMgt.ProcessRefund(Rec, Rec."Invoice Amount");
                end;
            }
        }
    }
}
