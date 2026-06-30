page 50109 "Hotel Front Desk Role Center"
{
    Caption = 'Hotel Front Desk';
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

                part(FrontDeskCues; "Hotel Front Desk Cues")
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
            group(Reservations)
            {
                Caption = 'Reservations';
                Image = Calendar;

                action(ReservationList)
                {
                    Caption = 'Reservations';
                    ApplicationArea = All;
                    RunObject = Page "Reservation List";
                    ToolTip = 'View and manage all hotel reservations.';
                }
                action(RoomList)
                {
                    Caption = 'Rooms';
                    ApplicationArea = All;
                    RunObject = Page "Room List";
                    ToolTip = 'View and manage hotel rooms.';
                }
            }
        }
    }
}
