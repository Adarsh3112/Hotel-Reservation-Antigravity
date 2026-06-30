page 50110 "Hotel Front Desk Cues"
{
    Caption = 'Front Desk Cues';
    PageType = CardPart;
    SourceTable = "Front Desk Cue Setup";
    RefreshOnActivate = true;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            cuegroup(OccupancyCues)
            {
                Caption = 'Occupancy';

                field(OccupiedRooms; Rec."Occupied Rooms")
                {
                    ApplicationArea = All;
                    Caption = 'Occupied Rooms';
                    DrillDownPageId = "Reservation List";
                    ToolTip = 'Shows the number of reservations currently in Occupied status. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        ReservationHeader: Record "Reservation Header";
                    begin
                        ReservationHeader.SetRange(Status, "Hotel Reservation Status"::Occupied);
                        Page.Run(Page::"Reservation List", ReservationHeader);
                    end;
                }
                field(AvailableRooms; Rec."Available Rooms")
                {
                    ApplicationArea = All;
                    Caption = 'Available Rooms';
                    DrillDownPageId = "Room List";
                    ToolTip = 'Shows the number of rooms not currently marked as occupied. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        Room: Record Room;
                    begin
                        Room.SetRange(Occupied, false);
                        Page.Run(Page::"Room List", Room);
                    end;
                }
            }
            cuegroup(CheckInCues)
            {
                Caption = 'Check-Ins';

                field(PendingCheckInsToday; Rec."Pending Check-Ins Today")
                {
                    ApplicationArea = All;
                    Caption = 'Pending Check-Ins Today';
                    DrillDownPageId = "Reservation List";
                    Style = Ambiguous;
                    StyleExpr = Rec."Pending Check-Ins Today" > 0;
                    ToolTip = 'Shows Confirmed reservations with a Check-In Date of today. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        ReservationHeader: Record "Reservation Header";
                    begin
                        ReservationHeader.SetRange(Status, "Hotel Reservation Status"::Confirmed);
                        ReservationHeader.SetRange("Check-In Date", Today());
                        Page.Run(Page::"Reservation List", ReservationHeader);
                    end;
                }
                field(TotalConfirmed; Rec."Total Confirmed Reservations")
                {
                    ApplicationArea = All;
                    Caption = 'Confirmed Reservations';
                    DrillDownPageId = "Reservation List";
                    ToolTip = 'Shows the total number of reservations in Confirmed status. Click to view the list.';

                    trigger OnDrillDown()
                    var
                        ReservationHeader: Record "Reservation Header";
                    begin
                        ReservationHeader.SetRange(Status, "Hotel Reservation Status"::Confirmed);
                        Page.Run(Page::"Reservation List", ReservationHeader);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetRecordOrInitialize();
        Rec.SetFilter("Date Filter", Format(Today()));
        Rec.CalcFields(
            "Occupied Rooms",
            "Available Rooms",
            "Pending Check-Ins Today",
            "Total Confirmed Reservations");
    end;
}
