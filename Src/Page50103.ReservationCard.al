page 50103 "Reservation Card"
{
    Caption = 'Reservation Card';
    PageType = Card;
    SourceTable = "Reservation Header";
    ApplicationArea = All;
    UsageCategory = None;

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
                    Importance = Promoted;
                    ToolTip = 'Specifies the unique number that identifies this reservation. It is assigned automatically from the No. Series.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the customer associated with this reservation.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the customer. Populated automatically from the Customer record.';
                }
                field("Room No."; Rec."Room No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the room assigned to this reservation. Selecting a room will automatically populate the Nightly Rate and update the room occupancy flag.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Room: Record Room;
                    begin
                        Room.SetRange(Occupied, false);
                        if Page.RunModal(Page::"Room Lookup", Room) = Action::LookupOK then begin
                            Rec.Validate("Room No.", Room."Room No.");
                            CurrPage.Update(false);
                            exit(true);
                        end;
                        exit(false);
                    end;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the current status of the reservation: Confirmed, Occupied, or Closed.';
                }
            }
            group(Dates)
            {
                Caption = 'Stay Dates';

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
            }
            group(Financial)
            {
                Caption = 'Financial';

                field("Nightly Rate"; Rec."Nightly Rate")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the nightly rate pulled automatically from the assigned Room record when a Room No. is selected.';
                }
                field("Deposit Amount"; Rec."Deposit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the deposit amount required for this reservation. Run Post Deposit to capture this amount before Check-In.';
                }
                field("Deposit Captured"; Rec."Deposit Captured")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Style = Favorable;
                    StyleExpr = Rec."Deposit Captured";
                    ToolTip = 'Indicates whether the deposit has been successfully captured via the Post Deposit action. Check-In is blocked until this is TRUE when a Deposit Amount is specified. A captured deposit is deducted as a credit on the generated Sales Invoice.';
                }
                field("Deposit Received"; Rec."Deposit Received")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether the deposit has been received from the guest. This field is kept in sync with Deposit Captured. When set, the deposit is deducted as a credit on the generated Sales Invoice.';
                }
                field("Payment Status"; Rec."Payment Status")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Style = Unfavorable;
                    StyleExpr = Rec."Payment Status" = "Hotel Payment Status"::Failed;
                    ToolTip = 'Specifies the current payment capture status for this reservation: Pending, Received, or Failed. A Failed status prevents Check-In and Invoice Generation until the issue is resolved.';
                }
                field("Amount Paid"; Rec."Amount Paid")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    Style = Strong;
                    ToolTip = 'Specifies the total payment amount received for this reservation. A refund cannot exceed this amount. Updated when a deposit is captured or payment is received.';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the Sales Invoice number generated for this reservation. Populated automatically when Generate Invoice is run. Once set, duplicate invoice generation is permanently blocked for this reservation.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT Business Posting Group used to determine the VAT rate for this reservation. Populated automatically from the Customer when a Customer No. is selected.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the General Business Posting Group for the reservation. Populated automatically from the Customer when a Customer No. is selected.';
                }
                field("Total Service Charges"; Rec."Total Service Charges")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    Style = Strong;
                    ToolTip = 'Specifies the total amount of all service charges added to this reservation. Calculated automatically from the service charge lines.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    Style = Strong;
                    ToolTip = 'Specifies the total VAT amount calculated on room charges and service charges for this reservation. Use Recalculate Tax to refresh this value after any changes.';
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    Style = Strong;
                    ToolTip = 'Specifies the total amount including VAT for all room and service charges on this reservation. Use Recalculate Tax to refresh this value after any changes.';
                }
            }
            part(ServiceCharges; "Reservation Service Charges")
            {
                ApplicationArea = All;
                SubPageLink = "Reservation No." = field("Reservation No.");
                ToolTip = 'Manage additional service charges for this reservation (e.g. Room Service, Minibar). All charges are included on the Sales Invoice when Generate Invoice is run.';
            }
            group(NoSeriesGroup)
            {
                Caption = 'No. Series';
                Visible = false;

                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the No. Series used to assign the Reservation No.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ReservationList)
            {
                Caption = 'Reservation List';
                ApplicationArea = All;
                Image = List;
                RunObject = Page "Reservation List";
                ToolTip = 'View the full list of reservations.';
            }
        }
        area(Processing)
        {
            action(PostDeposit)
            {
                Caption = 'Post Deposit';
                ApplicationArea = All;
                Image = PaymentJournal;
                Enabled = (Rec."Deposit Amount" > 0) and (not Rec."Deposit Captured") and (Rec."Status" = "Hotel Reservation Status"::Confirmed);
                ToolTip = 'Simulate or integrate a payment capture for the deposit on this reservation. Sets Deposit Captured to Yes and Payment Status to Received on success. Must be run before Check-In when a Deposit Amount is specified.';

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
                ToolTip = 'Move the reservation to Occupied status when the guest checks in. Verifies the room is not already occupied and that any required deposit has been captured. Blocked if Payment Status is Failed.';

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
                ToolTip = 'Close the reservation when the guest checks out. Triggers the billing process and clears the room occupancy flag.';

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
                ToolTip = 'Record the outcome of a payment or deposit capture attempt. Set Payment Status to Received on success, or to Failed if the capture was declined. A Failed status blocks Check-In and Invoice Generation.';

                trigger OnAction()
                var
                    NewPaymentStatus: Enum "Hotel Payment Status";
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
                ToolTip = 'Process a refund for payments received on this reservation. The refund amount cannot exceed the total amount paid. Restricted to HOTEL-FINANCE and HOTEL-ADMIN users only — hidden from Front Desk staff.';

                trigger OnAction()
                var
                    ProcessRefundCU: Codeunit "Process Refund";
                    RefundAmountInput: Decimal;
                    InputText: Text;
                begin
                    // Prompt Finance user to enter the refund amount.
                    InputText := Format(Rec."Amount Paid");
                    if not Evaluate(RefundAmountInput, InputText) then
                        RefundAmountInput := 0;

                    if Dialog.Confirm(
                        'Process a refund for Reservation %1?\\' +
                        'Amount Paid on record: %2\\' +
                        'The full amount paid will be refunded.\\' +
                        'Do you want to proceed?',
                        false,
                        Rec."Reservation No.",
                        Rec."Amount Paid")
                    then begin
                        // Call the codeunit — layer 2 permission check fires inside.
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
                // AccessByPermission: only users who can MODIFY Hotel Setup
                // (i.e. HOTEL-FINANCE and HOTEL-ADMIN) will see this action.
                AccessByPermission = tabledata "Hotel Setup" = M;
                Enabled = (Rec."Deposit Amount" > 0) and Rec."Deposit Received";
                ToolTip = 'Process a refund of the deposit collected for this reservation. Restricted to HOTEL-FINANCE and HOTEL-ADMIN users.';

                trigger OnAction()
                var
                    HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
                begin
                    // Code-level guard: raises a descriptive error for non-Finance users
                    // who manage to trigger this action outside of the page UI.
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
            action(RecalculateTax)
            {
                Caption = 'Recalculate Tax';
                ApplicationArea = All;
                Image = Calculate;
                // AccessByPermission: only HOTEL-FINANCE / HOTEL-ADMIN may recalculate tax.
                AccessByPermission = tabledata "Hotel Setup" = M;
                Enabled = Rec."Invoice No." = '';
                ToolTip = 'Recalculates the VAT amount on all room and service charges for this reservation based on the current VAT posting setup. Restricted to HOTEL-FINANCE and HOTEL-ADMIN users.';

                trigger OnAction()
                var
                    HotelVATCalculation: Codeunit "Hotel VAT Calculation";
                    HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
                begin
                    // Code-level guard prevents Front Desk users from recalculating tax
                    // even if the action were accessible through non-standard means.
                    HotelPermissionMgt.CheckTaxSetupPermission();

                    HotelVATCalculation.RecalculateTax(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(GenerateInvoice)
            {
                Caption = 'Generate Invoice';
                ApplicationArea = All;
                Image = Invoice;
                // AccessByPermission: only HOTEL-FINANCE / HOTEL-ADMIN may generate invoices.
                AccessByPermission = tabledata "Hotel Setup" = M;
                // Enabled only when the reservation is Closed AND no invoice has been
                // generated yet — prevents duplicate invoice creation from the UI.
                Enabled = (Rec."Status" = "Hotel Reservation Status"::Closed) and (Rec."Invoice No." = '');
                ToolTip = 'Create a standard BC Sales Invoice for this reservation, including room night charges (Nightly Rate x Duration) and all service charge lines. The Reservation No. is stored on the invoice header. Blocked if an invoice already exists (duplicate prevention) or if Payment Status is Failed. Restricted to HOTEL-FINANCE and HOTEL-ADMIN users.';

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
            actionref(ReservationList_Promoted; ReservationList) { }
            actionref(PostDeposit_Promoted; PostDeposit) { }
            actionref(CheckIn_Promoted; CheckIn) { }
            actionref(CheckOut_Promoted; CheckOut) { }
            actionref(CapturePayment_Promoted; CapturePayment) { }
            actionref(ProcessRefund_Promoted; ProcessRefund) { }
            actionref(RefundDeposit_Promoted; RefundDeposit) { }
            actionref(RecalculateTax_Promoted; RecalculateTax) { }
            actionref(GenerateInvoice_Promoted; GenerateInvoice) { }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Status" := "Hotel Reservation Status"::Confirmed;
    end;
}
