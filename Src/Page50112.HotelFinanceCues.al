page 50112 "Hotel Finance Cues"
{
    Caption = 'Finance Cues';
    PageType = CardPart;
    SourceTable = "Finance Cue Setup";
    RefreshOnActivate = true;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            cuegroup(InvoiceCues)
            {
                Caption = 'Invoicing';

                field(PendingInvoices; Rec."Pending Invoices")
                {
                    ApplicationArea = All;
                    Caption = 'Pending Invoices';
                    DrillDownPageId = "Reservation List";
                    Style = Ambiguous;
                    StyleExpr = Rec."Pending Invoices" > 0;
                    ToolTip = 'Shows Closed reservations that do not yet have a Sales Invoice. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        ReservationHeader: Record "Reservation Header";
                    begin
                        ReservationHeader.SetRange(Status, "Hotel Reservation Status"::Closed);
                        ReservationHeader.SetRange("Invoice No.", '');
                        Page.Run(Page::"Reservation List", ReservationHeader);
                    end;
                }
                field(InvoicedReservations; Rec."Invoiced Reservations")
                {
                    ApplicationArea = All;
                    Caption = 'Invoiced Reservations';
                    DrillDownPageId = "Reservation List";
                    Style = Favorable;
                    StyleExpr = Rec."Invoiced Reservations" > 0;
                    ToolTip = 'Shows the number of Closed reservations that have been invoiced. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        ReservationHeader: Record "Reservation Header";
                    begin
                        ReservationHeader.SetRange(Status, "Hotel Reservation Status"::Closed);
                        ReservationHeader.SetFilter("Invoice No.", '<>%1', '');
                        Page.Run(Page::"Reservation List", ReservationHeader);
                    end;
                }
            }
            cuegroup(DepositCues)
            {
                Caption = 'Deposit Reconciliation';

                field(DepositsPendingReconciliation; Rec."Deposits Pending Reconciliation")
                {
                    ApplicationArea = All;
                    Caption = 'Deposits Pending Reconciliation';
                    DrillDownPageId = "Reservation List";
                    Style = Unfavorable;
                    StyleExpr = Rec."Deposits Pending Reconciliation" > 0;
                    ToolTip = 'Shows reservations that have a Deposit Amount set but the deposit has not yet been captured. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        ReservationHeader: Record "Reservation Header";
                    begin
                        ReservationHeader.SetFilter("Deposit Amount", '>%1', 0);
                        ReservationHeader.SetRange("Deposit Captured", false);
                        Page.Run(Page::"Reservation List", ReservationHeader);
                    end;
                }
                field(PaymentsPending; Rec."Payments Pending")
                {
                    ApplicationArea = All;
                    Caption = 'Payments Pending';
                    DrillDownPageId = "Reservation List";
                    Style = Ambiguous;
                    StyleExpr = Rec."Payments Pending" > 0;
                    ToolTip = 'Shows reservations with a Pending payment status. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        ReservationHeader: Record "Reservation Header";
                    begin
                        ReservationHeader.SetRange("Payment Status", "Hotel Payment Status"::Pending);
                        Page.Run(Page::"Reservation List", ReservationHeader);
                    end;
                }
                field(FailedPayments; Rec."Failed Payments")
                {
                    ApplicationArea = All;
                    Caption = 'Failed Payments';
                    DrillDownPageId = "Reservation List";
                    Style = Unfavorable;
                    StyleExpr = Rec."Failed Payments" > 0;
                    ToolTip = 'Shows reservations with a Failed payment status requiring immediate attention. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        ReservationHeader: Record "Reservation Header";
                    begin
                        ReservationHeader.SetRange("Payment Status", "Hotel Payment Status"::Failed);
                        Page.Run(Page::"Reservation List", ReservationHeader);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetRecordOrInitialize();
        Rec.CalcFields(
            "Pending Invoices",
            "Invoiced Reservations",
            "Deposits Pending Reconciliation",
            "Payments Pending",
            "Failed Payments");
    end;
}
