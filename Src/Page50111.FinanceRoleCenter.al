page 50111 "Hotel Finance Role Center"
{
    Caption = 'Hotel Finance';
    PageType = RoleCenter;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(RoleCenter)
        {
            group(Cues)
            {
                Caption = 'At a Glance';

                part(FinanceCues; "Hotel Finance Cues")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(Billing)
            {
                Caption = 'Billing & Finance';
                Image = Finance;

                action(ReservationList)
                {
                    Caption = 'Reservations';
                    ApplicationArea = All;
                    RunObject = Page "Reservation List";
                    ToolTip = 'View and manage all hotel reservations.';
                }
                action(HotelSetup)
                {
                    Caption = 'Hotel Setup';
                    ApplicationArea = All;
                    RunObject = Page "Hotel Setup";
                    ToolTip = 'Configure hotel setup and number series.';
                }
            }
        }
    }
}
