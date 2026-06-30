codeunit 50100 "Hotel Reservation Mgt"
{
    /// <summary>
    /// Fetches the Nightly Rate from the linked Room record into the Reservation Header.
    /// Called from the Room No. OnValidate trigger so the rate is always in sync.
    /// </summary>
    procedure FetchRateFromRoom(var ReservationHeader: Record "Reservation Header")
    var
        Room: Record Room;
    begin
        if ReservationHeader."Room No." = '' then begin
            ReservationHeader."Nightly Rate" := 0;
            exit;
        end;
        if Room.Get(ReservationHeader."Room No.") then
            ReservationHeader."Nightly Rate" := Room."Nightly Rate"
        else
            ReservationHeader."Nightly Rate" := 0;
    end;

    /// <summary>
    /// Updates the Occupied flag on the Room records affected by a change to a
    /// Reservation Header (either a Room No. change or a Status change).
    /// </summary>
    procedure UpdateRoomOccupancy(var ReservationHeader: Record "Reservation Header"; var xReservationHeader: Record "Reservation Header")
    var
        Room: Record Room;
        OldRoomNo: Code[20];
        NewRoomNo: Code[20];
    begin
        OldRoomNo := xReservationHeader."Room No.";
        NewRoomNo := ReservationHeader."Room No.";

        // Recalculate the old room (if it exists and differs from the new one)
        if (OldRoomNo <> '') and (OldRoomNo <> NewRoomNo) then
            if Room.Get(OldRoomNo) then begin
                Room.Occupied := IsRoomCurrentlyOccupied(OldRoomNo, ReservationHeader."Reservation No.", ReservationHeader);
                Room.Modify();
            end;

        // Recalculate the new / current room
        if NewRoomNo <> '' then
            if Room.Get(NewRoomNo) then begin
                Room.Occupied := IsRoomCurrentlyOccupied(NewRoomNo, ReservationHeader."Reservation No.", ReservationHeader);
                Room.Modify();
            end;
    end;

    local procedure IsRoomCurrentlyOccupied(RoomNo: Code[20]; CurrentReservationNo: Code[20]; CurrentRec: Record "Reservation Header"): Boolean
    var
        ReservationHeader: Record "Reservation Header";
    begin
        // Check whether any OTHER reservation for this room is currently Occupied
        ReservationHeader.SetRange("Room No.", RoomNo);
        ReservationHeader.SetRange(Status, "Hotel Reservation Status"::Occupied);
        if CurrentReservationNo <> '' then
            ReservationHeader.SetFilter("Reservation No.", '<>%1', CurrentReservationNo);

        if not ReservationHeader.IsEmpty then
            exit(true);

        // Also consider the record being validated right now
        if (CurrentRec."Room No." = RoomNo) and (CurrentRec.Status = "Hotel Reservation Status"::Occupied) then
            exit(true);

        exit(false);
    end;

    /// <summary>
    /// Returns TRUE when an existing Confirmed or Occupied reservation for the same
    /// Room No. overlaps the date range of the supplied ReservationHeader.
    /// Overlap condition: existing.CheckIn < new.CheckOut AND existing.CheckOut > new.CheckIn
    /// Only reservations in Confirmed or Occupied status are considered active
    /// booking conflicts; Closed reservations are ignored.
    /// </summary>
    procedure CheckForOverlappingReservations(ReservationHeader: Record "Reservation Header"): Boolean
    var
        OtherReservation: Record "Reservation Header";
    begin
        if (ReservationHeader.Status = "Hotel Reservation Status"::Closed) then
            exit(false);

        if (ReservationHeader."Room No." = '') or
           (ReservationHeader."Check-In Date" = 0D) or
           (ReservationHeader."Check-Out Date" = 0D)
        then
            exit(false);

        OtherReservation.SetRange("Room No.", ReservationHeader."Room No.");
        OtherReservation.SetFilter("Reservation No.", '<>%1', ReservationHeader."Reservation No.");
        // Only block on active statuses: Confirmed or Occupied
        OtherReservation.SetFilter(Status, '%1|%2',
            "Hotel Reservation Status"::Confirmed,
            "Hotel Reservation Status"::Occupied);
        // Overlap: other.CheckIn < this.CheckOut
        OtherReservation.SetFilter("Check-In Date", '<%1', ReservationHeader."Check-Out Date");
        // Overlap: other.CheckOut > this.CheckIn
        OtherReservation.SetFilter("Check-Out Date", '>%1', ReservationHeader."Check-In Date");

        exit(not OtherReservation.IsEmpty);
    end;

    /// <summary>
    /// Raises an error when CheckForOverlappingReservations detects a conflict.
    /// Call this from any trigger or codeunit that assigns or changes a Room No.
    /// or modifies the Check-In / Check-Out dates of a Reservation Header.
    /// </summary>
    procedure VerifyNoOverlap(ReservationHeader: Record "Reservation Header")
    begin
        if CheckForOverlappingReservations(ReservationHeader) then
            Error(
                'Room %1 is already reserved for the period %2 to %3 in Confirmed or Occupied status. ' +
                'Please select a different room or adjust the dates.',
                ReservationHeader."Room No.",
                ReservationHeader."Check-In Date",
                ReservationHeader."Check-Out Date");
    end;
}
