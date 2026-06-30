page 50123 "BSH Reservation List"
{
    Caption = 'BSH Reservations';
    PageType = List;
    SourceTable = "BSH Reservation";
    CardPageId = "BSH Reservation Card";
    ApplicationArea = All;
    UsageCategory = Lists;

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
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
