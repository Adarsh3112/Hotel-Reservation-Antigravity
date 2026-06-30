page 50102 "Hotel Reservation List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Hotel Reservation";
    CardPageId = "Hotel Reservation Card";
    Caption = 'Hotel Reservations';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Reservation No."; Rec."Reservation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique reservation number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer linking to the reservation.';
                }
                field("Room No."; Rec."Room No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the room number assigned to this reservation.';
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
                    ToolTip = 'Specifies the reservation status (Confirmed, Occupied, Closed).';
                }
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
                    ToolTip = 'Specifies the invoice number once generated.';
                }
                field(Invoiced; Rec.Invoiced)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if an invoice has been generated.';
                }
            }
        }
    }
}
