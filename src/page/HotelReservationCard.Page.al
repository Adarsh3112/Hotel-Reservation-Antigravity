page 50103 "Hotel Reservation Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Hotel Reservation";
    Caption = 'Hotel Reservation Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Reservation No."; Rec."Reservation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique reservation number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
                field("Room No."; Rec."Room No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the room number assigned.';
                }
                field("Check-in Date"; Rec."Check-in Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the check-in date.';
                }
                field("Check-out Date"; Rec."Check-out Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the check-out date.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current reservation status.';
                }
            }

            group(Billing)
            {
                Caption = 'Billing & Payment';

                field("Deposit Amount"; Rec."Deposit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the required deposit amount.';
                }
                field("Deposit Paid"; Rec."Deposit Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if the deposit has been paid.';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the generated invoice number.';
                }
                field(Invoiced; Rec.Invoiced)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if the invoice has been generated.';
                }
                field("Net Amount Due"; NetAmountDue)
                {
                    ApplicationArea = All;
                    Caption = 'Net Amount Due';
                    Editable = false;
                    ToolTip = 'Shows the remaining balance due on the reservation.';
                }
            }

            group("Refund Processing")
            {
                Caption = 'Refund (Finance Only)';

                field("Refund Amount"; RefundAmountToProcess)
                {
                    ApplicationArea = All;
                    Caption = 'Refund Amount to Process';
                    MinValue = 0;
                    ToolTip = 'Specifies the amount to refund to the guest.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CaptureDeposit)
            {
                ApplicationArea = All;
                Caption = 'Capture Deposit';
                Image = PaymentJournal;
                ToolTip = 'Processes and records the deposit payment.';

                trigger OnAction()
                var
                    HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
                begin
                    if Confirm('Simulate successful deposit payment?', true) then
                        HotelLifecycleMgt.CaptureDeposit(Rec, true)
                    else
                        HotelLifecycleMgt.CaptureDeposit(Rec, false);
                    
                    CurrPage.Update(false);
                end;
            }
            action(CheckIn)
            {
                ApplicationArea = All;
                Caption = 'Check In';
                Image = Approve;
                ToolTip = 'Checks the guest into the assigned room.';

                trigger OnAction()
                var
                    HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
                begin
                    HotelLifecycleMgt.CheckIn(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ServiceCharges)
            {
                ApplicationArea = All;
                Caption = 'Service Charges';
                Image = ServiceLedger;
                RunObject = Page "Hotel Service Charges";
                RunPageLink = "Reservation No." = field("Reservation No.");
                ToolTip = 'Opens the service charges associated with this reservation.';
            }
            action(GenerateInvoice)
            {
                ApplicationArea = All;
                Caption = 'Generate Invoice';
                Image = Invoice;
                ToolTip = 'Generates the final invoice and posts charges to the ledger.';

                trigger OnAction()
                var
                    HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
                begin
                    HotelLifecycleMgt.GenerateInvoice(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(PostFinalPayment)
            {
                ApplicationArea = All;
                Caption = 'Post Final Payment';
                Image = Payment;
                ToolTip = 'Settle the remaining balance due on this reservation.';

                trigger OnAction()
                var
                    HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
                begin
                    if Confirm('Simulate successful final payment?', true) then
                        HotelLifecycleMgt.PostFinalPayment(Rec, true)
                    else
                        HotelLifecycleMgt.PostFinalPayment(Rec, false);

                    CurrPage.Update(false);
                end;
            }
            action(CheckOut)
            {
                ApplicationArea = All;
                Caption = 'Check Out';
                Image = Close;
                ToolTip = 'Checks out the guest and closes the reservation.';

                trigger OnAction()
                var
                    HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
                begin
                    HotelLifecycleMgt.CheckOut(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ProcessRefundAction)
            {
                ApplicationArea = All;
                Caption = 'Process Refund';
                Image = Reject;
                ToolTip = 'Refunds the specified amount to the guest (requires Finance role).';

                trigger OnAction()
                var
                    HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
                begin
                    if RefundAmountToProcess <= 0 then
                        Error('Please specify a positive refund amount.');

                    if Confirm('Simulate successful refund payment?', true) then
                        HotelLifecycleMgt.ProcessRefund(Rec, RefundAmountToProcess, true)
                    else
                        HotelLifecycleMgt.ProcessRefund(Rec, RefundAmountToProcess, false);

                    RefundAmountToProcess := 0;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
    begin
        NetAmountDue := HotelLifecycleMgt.GetNetAmountDue(Rec."Reservation No.");
    end;

    var
        NetAmountDue: Decimal;
        RefundAmountToProcess: Decimal;
}
