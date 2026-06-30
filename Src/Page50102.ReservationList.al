page 50102 "Reservation List"
{
    Caption = 'Reservation List';
    PageType = List;
    SourceTable = "Reservation Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Reservation Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(ReservationLines)
            {
                field("Reservation No."; Rec."Reservation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique number that identifies this reservation.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer associated with this reservation.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Room No."; Rec."Room No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the room assigned to this reservation.';
                }
                field("Check-In Date"; Rec."Check-In Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the guest checks in.';
                }
                field("Check-Out Date"; Rec."Check-Out Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the guest checks out.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current status of the reservation.';
                }
                field("Payment Status"; Rec."Payment Status")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = Rec."Payment Status" = "Hotel Payment Status"::Failed;
                    ToolTip = 'Specifies the payment capture status for this reservation: Pending, Received, or Failed. Failed reservations are blocked from Check-In and Invoice Generation.';
                }
                field("Nightly Rate"; Rec."Nightly Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the nightly rate pulled from the assigned Room record.';
                }
                field("Deposit Amount"; Rec."Deposit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the deposit amount required for this reservation.';
                }
                field("Deposit Captured"; Rec."Deposit Captured")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec."Deposit Captured";
                    ToolTip = 'Indicates whether the deposit has been successfully captured via the Post Deposit action. Check-In is blocked until TRUE when a Deposit Amount is specified.';
                }
                field("Amount Paid"; Rec."Amount Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total payment amount received for this reservation. A refund cannot exceed this amount.';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sales Invoice number generated for this reservation.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewReservation)
            {
                Caption = 'New Reservation';
                ApplicationArea = All;
                Image = New;
                RunObject = Page "Reservation Card";
                RunPageMode = Create;
                ToolTip = 'Create a new reservation record.';
            }
            action(PostDeposit)
            {
                Caption = 'Post Deposit';
                ApplicationArea = All;
                Image = PaymentJournal;
                Enabled = (Rec."Deposit Amount" > 0) and (not Rec."Deposit Captured") and (Rec."Status" = "Hotel Reservation Status"::Confirmed);
                ToolTip = 'Simulate or integrate a payment capture for the deposit on the selected reservation. Sets Deposit Captured to Yes and Payment Status to Received on success. Must be run before Check-In when a Deposit Amount is specified.';

                trigger OnAction()
                var
                    PostDepositCU: Codeunit "Post Deposit";
                begin
                    PostDepositCU.PostDeposit(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CheckIn)
            {
                Caption = 'Check In';
                ApplicationArea = All;
                Image = Reconcile;
                Enabled = Rec."Status" = "Hotel Reservation Status"::Confirmed;
                ToolTip = 'Move the selected reservation to Occupied status. Verifies the room is not already occupied and that any required deposit has been captured. Blocked if Payment Status is Failed.';

                trigger OnAction()
                var
                    ReservationCheckIn: Codeunit "Reservation Check-In";
                begin
                    ReservationCheckIn.CheckIn(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CheckOut)
            {
                Caption = 'Check Out';
                ApplicationArea = All;
                Image = ReleaseDoc;
                Enabled = Rec."Status" = "Hotel Reservation Status"::Occupied;
                ToolTip = 'Close the selected reservation. Triggers billing and clears the room occupancy flag.';

                trigger OnAction()
                var
                    ReservationCheckOut: Codeunit "Reservation Check-Out";
                begin
                    ReservationCheckOut.CheckOut(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CapturePayment)
            {
                Caption = 'Capture Payment';
                ApplicationArea = All;
                Image = Payment;
                Enabled = Rec."Payment Status" <> "Hotel Payment Status"::Received;
                ToolTip = 'Record the payment capture result for the selected reservation. Set to Received on success or Failed on decline. Failed status blocks Check-In and Invoice Generation.';

                trigger OnAction()
                var
                    SelectionText: Text;
                begin
                    SelectionText := StrSubstNo(
                        'Select the payment capture result for Reservation %1:\\' +
                        '1 = Received (payment captured successfully)\\' +
                        '2 = Failed (payment capture declined or errored)\\' +
                        '3 = Pending (reset to awaiting capture)',
                        Rec."Reservation No.");

                    case StrMenu('Received,Failed,Pending', 1, SelectionText) of
                        1:
                            begin
                                Rec.Validate("Payment Status", "Hotel Payment Status"::Received);
                                if Rec."Amount Paid" = 0 then
                                    Rec."Amount Paid" := Rec."Amount Incl. VAT";
                                Rec.Modify(true);
                                Message('Payment Status has been set to Received for Reservation %1.', Rec."Reservation No.");
                            end;
                        2:
                            begin
                                Rec.Validate("Payment Status", "Hotel Payment Status"::Failed);
                                Rec.Modify(true);
                                Error(
                                    'Payment capture has FAILED for Reservation %1. ' +
                                    'Check-In and Invoice Generation are blocked until the payment issue is resolved. ' +
                                    'Please retry the payment or contact the guest, then set Payment Status to Received.',
                                    Rec."Reservation No.");
                            end;
                        3:
                            begin
                                Rec.Validate("Payment Status", "Hotel Payment Status"::Pending);
                                Rec.Modify(true);
                                Message('Payment Status has been reset to Pending for Reservation %1.', Rec."Reservation No.");
                            end;
                    end;
                    CurrPage.Update(false);
                end;
            }
            action(ProcessRefund)
            {
                Caption = 'Process Refund';
                ApplicationArea = All;
                Image = Undo;
                // Layer 1 UI guard: HOTEL-FRONTDESK has only R on Hotel Setup, so
                // this action is completely hidden from Front Desk users.
                // Only HOTEL-FINANCE and HOTEL-ADMIN (both have M on Hotel Setup)
                // will see and be able to invoke this action.
                AccessByPermission = tabledata "Hotel Setup" = M;
                Enabled = Rec."Amount Paid" > 0;
                ToolTip = 'Process a refund for payments received on the selected reservation. The refund amount cannot exceed the total amount paid. Restricted to HOTEL-FINANCE and HOTEL-ADMIN users only — hidden from Front Desk staff.';

                trigger OnAction()
                var
                    ProcessRefundCU: Codeunit "Process Refund";
                begin
                    if Dialog.Confirm(
                        'Process a refund for Reservation %1?\\' +
                        'Amount Paid on record: %2\\' +
                        'The full amount paid will be refunded.\\' +
                        'Do you want to proceed?',
                        false,
                        Rec."Reservation No.",
                        Rec."Amount Paid")
                    then begin
                        // Layer 2 permission check fires inside ProcessRefund codeunit.
                        ProcessRefundCU.ProcessRefund(Rec, Rec."Amount Paid");
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RefundDeposit)
            {
                Caption = 'Refund Deposit';
                ApplicationArea = All;
                Image = Undo;
                // AccessByPermission: only HOTEL-FINANCE / HOTEL-ADMIN users see and run this action.
                AccessByPermission = tabledata "Hotel Setup" = M;
                Enabled = (Rec."Deposit Amount" > 0) and Rec."Deposit Received";
                ToolTip = 'Process a deposit refund for the selected reservation. Restricted to HOTEL-FINANCE and HOTEL-ADMIN users.';

                trigger OnAction()
                var
                    HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
                begin
                    // Code-level guard: Front Desk users are blocked with a clear error.
                    HotelPermissionMgt.CheckRefundPermission();

                    if not Confirm(
                        'Are you sure you want to process a refund of %1 for Reservation %2?',
                        false,
                        Rec."Deposit Amount",
                        Rec."Reservation No.")
                    then
                        exit;

                    Rec.Validate("Deposit Captured", false);
                    Rec.Validate("Deposit Received", false);
                    Rec.Validate("Deposit Amount", 0);
                    Rec.Modify(true);

                    Message(
                        'Refund processed successfully for Reservation %1.\\Deposit has been cleared.',
                        Rec."Reservation No.");
                    CurrPage.Update(false);
                end;
            }
            action(GenerateInvoice)
            {
                Caption = 'Generate Invoice';
                ApplicationArea = All;
                Image = Invoice;
                // AccessByPermission: only HOTEL-FINANCE / HOTEL-ADMIN users see and run this action.
                AccessByPermission = tabledata "Hotel Setup" = M;
                Enabled = (Rec."Status" = "Hotel Reservation Status"::Closed) and (Rec."Invoice No." = '');
                ToolTip = 'Create a standard BC Sales Invoice for the selected reservation. Blocked if Payment Status is Failed or an invoice already exists. Restricted to HOTEL-FINANCE and HOTEL-ADMIN users.';

                trigger OnAction()
                var
                    GenerateHotelInvoice: Codeunit "Generate Hotel Invoice";
                    HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
                begin
                    // Code-level guard: ensures only Finance/Admin can generate invoices.
                    HotelPermissionMgt.CheckFinancePermission();

                    GenerateHotelInvoice.GenerateInvoice(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(NewReservation_Promoted; NewReservation) { }
            actionref(PostDeposit_Promoted; PostDeposit) { }
            actionref(CheckIn_Promoted; CheckIn) { }
            actionref(CheckOut_Promoted; CheckOut) { }
            actionref(CapturePayment_Promoted; CapturePayment) { }
            actionref(ProcessRefund_Promoted; ProcessRefund) { }
            actionref(RefundDeposit_Promoted; RefundDeposit) { }
            actionref(GenerateInvoice_Promoted; GenerateInvoice) { }
        }
    }
}
