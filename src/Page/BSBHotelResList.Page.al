page 50133 "BSB Hotel Res. List"
{
    PageType = List;
    SourceTable = "BSB Hotel Reservation";
    CardPageId = "BSB Hotel Res. Card";
    Caption = 'Hotel Reservations';
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
                field("Deposit Captured"; Rec."Deposit Captured")
                {
                    ApplicationArea = All;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
