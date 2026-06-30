page 50137 "BSB Hotel User Roles"
{
    PageType = List;
    SourceTable = "BSB Hotel User Role";
    Caption = 'Hotel User Roles';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Roles)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field(Role; Rec.Role)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
