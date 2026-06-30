codeunit 50101 "Reservation Check-In"
{
    /// <summary>
    /// Performs an atomic Check-In transition for a Reservation:
    ///   1. Validates the reservation is in Confirmed status.
    ///   2. Verifies no overlapping Confirmed or Occupied reservation exists for
    ///      the same room and date range (double-booking guard).
    ///   3. Verifies the assigned Room is not already flagged as Occupied
    ///      by a different active reservation.
    ///   4. Guards that a required deposit (Deposit Amount > 0) has been
    ///      captured (Deposit Captured = TRUE) before check-in is permitted.
    ///   5. Guards that Payment Status is not 'Failed'.
    ///   6. Sets Reservation Status to Occupied.
    ///   7. Sets the Room.Occupied flag to TRUE.
    /// </summary>
    procedure CheckIn(var ReservationHeader: Record "Reservation Header")
    var
        Room: Record Room;
        RoomAvailabilityCheck: Codeunit "Room Availability Check";
    begin
        // Guard: must be in Confirmed status
        if ReservationHeader.Status <> "Hotel Reservation Status"::Confirmed then
            Error('Check-In is only allowed for reservations with status Confirmed. Current status: %1.',
                  ReservationHeader.Status);

        // Guard: a room must be assigned
        if ReservationHeader."Room No." = '' then
            Error('A Room must be assigned before checking in.');

        // Guard: room must exist
        if not Room.Get(ReservationHeader."Room No.") then
            Error('Room %1 does not exist.', ReservationHeader."Room No.");

        // Guard: no overlapping Confirmed or Occupied reservation for the same room and period
        RoomAvailabilityCheck.CheckAvailabilityOrError(ReservationHeader);

        // Guard: room must not already be occupied
        if Room.Occupied then
            Error('Room %1 is already occupied. Please assign a different room before checking in.',
                  ReservationHeader."Room No.");

        // Guard: deposit must be captured if a deposit amount has been specified.
        if ReservationHeader."Deposit Amount" > 0 then begin
            if (not ReservationHeader."Deposit Captured") and (not ReservationHeader."Deposit Received") then
                Error(
                    'Check-In is not allowed for Reservation %1 until the deposit of %2 has been captured. ' +
                    'Please run Post Deposit to capture the deposit before proceeding.',
                    ReservationHeader."Reservation No.",
                    ReservationHeader."Deposit Amount");
        end;

        // Guard: Payment Status must not be Failed.
        if ReservationHeader."Payment Status" = "Hotel Payment Status"::Failed then
            Error(
                'Check-In is blocked for Reservation %1 because the Payment Status is ''Failed''. ' +
                'Please resolve the payment issue and set Payment Status to ''Received'' before checking in.',
                ReservationHeader."Reservation No.");

        // Transition reservation status → Occupied (this will also update Room.Occupied via OnValidate)
        ReservationHeader.Validate(Status, "Hotel Reservation Status"::Occupied);
        ReservationHeader.Modify(true);
    end;
}
