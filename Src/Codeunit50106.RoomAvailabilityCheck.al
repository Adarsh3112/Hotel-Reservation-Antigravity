codeunit 50109 "Room Availability Check"
{
    /// <summary>
    /// Checks whether the given Room No. is available for the requested date range
    /// by scanning the Reservation Header table for any active (Confirmed or Occupied)
    /// reservations whose stay period overlaps with [CheckInDate, CheckOutDate).
    ///
    /// Overlap condition (standard half-open interval test):
    ///   existing."Check-In Date"  < RequestedCheckOut
    ///   AND
    ///   existing."Check-Out Date" > RequestedCheckIn
    ///
    /// Returns TRUE  when the room is available (no conflict found).
    /// Returns FALSE when a conflicting active reservation already exists.
    ///
    /// Call CheckAvailabilityOrError to raise a descriptive overbooking error.
    /// </summary>
    procedure CheckAvailability(
        RoomNo: Code[20];
        RequestedCheckIn: Date;
        RequestedCheckOut: Date;
        ExcludeReservationNo: Code[20]): Boolean
    var
        ConflictingReservation: Record "Reservation Header";
    begin
        // Cannot evaluate availability without a room and a complete date range.
        if (RoomNo = '') or (RequestedCheckIn = 0D) or (RequestedCheckOut = 0D) then
            exit(true);

        // Only active reservations (Confirmed or Occupied) create a booking conflict.
        // Closed reservations are historical and do not block future bookings.
        ConflictingReservation.SetRange("Room No.", RoomNo);
        ConflictingReservation.SetFilter(
            Status,
            '%1|%2',
            "Hotel Reservation Status"::Confirmed,
            "Hotel Reservation Status"::Occupied);

        // Exclude the reservation currently being validated so that editing an
        // existing record does not conflict with itself.
        if ExcludeReservationNo <> '' then
            ConflictingReservation.SetFilter("Reservation No.", '<>%1', ExcludeReservationNo);

        // Overlap filter — half-open interval:
        //   existing check-in must be before the requested check-out
        ConflictingReservation.SetFilter("Check-In Date", '<%1', RequestedCheckOut);
        //   existing check-out must be after the requested check-in
        ConflictingReservation.SetFilter("Check-Out Date", '>%1', RequestedCheckIn);

        // If no conflicting record exists the room is available.
        exit(ConflictingReservation.IsEmpty);
    end;

    /// <summary>
    /// Calls CheckAvailability and raises a clear, descriptive error when the room
    /// is already booked for overlapping dates.
    ///
    /// Intended to be called from:
    ///   - Reservation Header field triggers: "Room No.", "Check-In Date", "Check-Out Date"
    ///   - Reservation Header table triggers: OnInsert, OnModify
    /// </summary>
    procedure CheckAvailabilityOrError(ReservationHeader: Record "Reservation Header")
    begin
        // Skip validation for Closed reservations — they no longer block the room.
        if ReservationHeader.Status = "Hotel Reservation Status"::Closed then
            exit;

        // Skip when mandatory fields are not yet filled in (partial record during entry).
        if (ReservationHeader."Room No." = '') or
           (ReservationHeader."Check-In Date" = 0D) or
           (ReservationHeader."Check-Out Date" = 0D)
        then
            exit;

        if not CheckAvailability(
                ReservationHeader."Room No.",
                ReservationHeader."Check-In Date",
                ReservationHeader."Check-Out Date",
                ReservationHeader."Reservation No.")
        then
            Error(
                'Overbooking prevented: Room %1 is already reserved by another guest ' +
                'for a period that overlaps %2 to %3.\\' +
                'Please choose a different room or adjust the Check-In / Check-Out dates ' +
                'so that they do not conflict with an existing Confirmed or Occupied reservation.',
                ReservationHeader."Room No.",
                Format(ReservationHeader."Check-In Date", 0, '<Day,2>/<Month,2>/<Year4>'),
                Format(ReservationHeader."Check-Out Date", 0, '<Day,2>/<Month,2>/<Year4>'));
    end;
}
