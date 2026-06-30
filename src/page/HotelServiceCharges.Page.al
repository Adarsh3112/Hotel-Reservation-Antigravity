page 50104 "Hotel Service Charges"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Hotel Service Charge";
    Caption = 'Hotel Service Charges';
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Reservation No."; Rec."Reservation No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the reservation number.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the line number of this service charge.';
                }
                field("Service Type"; Rec."Service Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of service (Breakfast, Laundry, Transfer).';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost of the service.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        ServiceCharge: Record "Hotel Service Charge";
    begin
        ServiceCharge.SetRange("Reservation No.", Rec."Reservation No.");
        if ServiceCharge.FindLast() then
            Rec."Line No." := ServiceCharge."Line No." + 10000
        else
            Rec."Line No." := 10000;
    end;
}
