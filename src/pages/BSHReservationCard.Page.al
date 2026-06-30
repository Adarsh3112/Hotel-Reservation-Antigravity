page 50124 "BSH Reservation Card"
{
    Caption = 'BSH Reservation';
    PageType = Card;
    SourceTable = "BSH Reservation";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Reservation No."; Rec."Reservation No.")
                {
                    ApplicationArea = All;
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
                field("Deposit Amount"; Rec."Deposit Amount")
                {
                    ApplicationArea = All;
                }
                field("Deposit Status"; Rec."Deposit Status")
                {
                    ApplicationArea = All;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Remaining Due"; Rec."Remaining Due")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Final Paid"; Rec."Final Paid")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(ServiceCharges; "BSH Service Charges")
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
            action(AssignRoom)
            {
                Caption = 'Assign Room';
                ApplicationArea = All;
                Image = Allocate;

                trigger OnAction()
                var
                    ReservationMgt: Codeunit "BSH Reservation Mgt";
                begin
                    ReservationMgt.AssignRoom(Rec, Rec."Room No.");
                end;
            }
            action(CheckIn)
            {
                Caption = 'Check In';
                ApplicationArea = All;
                Image = Approve;

                trigger OnAction()
                var
                    ReservationMgt: Codeunit "BSH Reservation Mgt";
                begin
                    ReservationMgt.CheckIn(Rec);
                end;
            }
            action(CaptureDeposit)
            {
                Caption = 'Capture Deposit';
                ApplicationArea = All;
                Image = Payment;

                trigger OnAction()
                var
                    PaymentMgt: Codeunit "BSH Payment Mgt";
                begin
                    PaymentMgt.RecordDeposit(Rec, Rec."Deposit Amount", true, '');
                end;
            }
            action(FailDeposit)
            {
                Caption = 'Record Failed Deposit';
                ApplicationArea = All;
                Image = Cancel;

                trigger OnAction()
                var
                    PaymentMgt: Codeunit "BSH Payment Mgt";
                begin
                    PaymentMgt.RecordDeposit(Rec, Rec."Deposit Amount", false, '');
                end;
            }
            action(AddBreakfast)
            {
                Caption = 'Add Breakfast';
                ApplicationArea = All;
                Image = Add;

                trigger OnAction()
                var
                    ReservationMgt: Codeunit "BSH Reservation Mgt";
                begin
                    ReservationMgt.AddServiceCharge(Rec."Reservation No.", Enum::"BSH Service Charge Type"::Breakfast, 'Breakfast', 10);
                end;
            }
            action(GenerateInvoice)
            {
                Caption = 'Generate Invoice';
                ApplicationArea = All;
                Image = Invoice;

                trigger OnAction()
                var
                    BillingMgt: Codeunit "BSH Billing Mgt";
                begin
                    BillingMgt.GenerateInvoice(Rec);
                end;
            }
            action(PostFinalPayment)
            {
                Caption = 'Post Final Payment';
                ApplicationArea = All;
                Image = Payment;

                trigger OnAction()
                var
                    PaymentMgt: Codeunit "BSH Payment Mgt";
                begin
                    PaymentMgt.PostFinalPayment(Rec, Rec."Remaining Due");
                end;
            }
            action(CheckOut)
            {
                Caption = 'Check Out';
                ApplicationArea = All;
                Image = Close;

                trigger OnAction()
                var
                    ReservationMgt: Codeunit "BSH Reservation Mgt";
                begin
                    ReservationMgt.CloseReservation(Rec);
                end;
            }
            action(ProcessRefund)
            {
                Caption = 'Process Refund';
                ApplicationArea = All;
                Image = ReverseRegister;

                trigger OnAction()
                var
                    RefundMgt: Codeunit "BSH Refund Mgt";
                begin
                    RefundMgt.ProcessRefund(Rec, Rec."Deposit Applied", 'Finance approved refund', true);
                end;
            }
        }
    }
}
