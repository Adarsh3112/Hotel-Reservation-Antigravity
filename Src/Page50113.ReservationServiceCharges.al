page 50113 "Reservation Service Charges"
{
    Caption = 'Reservation Service Charges';
    PageType = ListPart;
    SourceTable = "Reservation Service Charge";
    ApplicationArea = All;
    UsageCategory = None;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the line number of the service charge.';
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this line is a Room charge or a Service charge.';
                }
                field("Service Type"; Rec."Service Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the category of service: Breakfast, Laundry, Transfer, or Other.';
                    Editable = Rec."Type" = Rec."Type"::Service;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the service charge (e.g. Breakfast on 01/06, Transfer to Airport).';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity for this service charge.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price for this service charge.';
                }
                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the total amount (Quantity x Unit Price) for this service charge line.';
                }
                field("Posted"; Rec."Posted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether this service charge has been posted by Front Desk and will be included on the Sales Invoice.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date on which this service charge was posted.';
                }
                field("Validated"; Rec."Validated")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Indicates whether this service charge has been validated by Finance.';
                }
                field("Validated By"; Rec."Validated By")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the user ID of the Finance team member who validated this charge.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PostCharge)
            {
                Caption = 'Post Charge';
                ApplicationArea = All;
                Image = Post;
                ToolTip = 'Mark the selected service charge line as Posted so it will be included on the generated Sales Invoice. Only available to Front Desk users.';

                trigger OnAction()
                begin
                    if Rec.Posted then
                        Error('This service charge is already posted.');
                    if Rec."Type" <> Rec."Type"::Service then
                        Error('Only Service-type lines can be posted from this subpage.');
                    Rec.Validate(Posted, true);
                    Rec.Validate("Posting Date", Today());
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }
            action(ValidateCharge)
            {
                Caption = 'Validate Charge';
                ApplicationArea = All;
                Image = Approve;
                ToolTip = 'Finance validation: marks the selected posted service charge as Validated, confirming it is correct and approved for invoicing.';

                trigger OnAction()
                var
                    HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
                begin
                    HotelPermissionMgt.CheckFinancePermission();
                    if not Rec.Posted then
                        Error('Only posted service charges can be validated. Please post the charge first.');
                    if Rec.Validated then
                        Error('This service charge has already been validated.');
                    Rec.Validated := true;
                    Rec."Validated By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Validated By"));
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
