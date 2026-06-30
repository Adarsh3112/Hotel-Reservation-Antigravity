codeunit 50102 "Reservation Check-Out"
{
    /// <summary>
    /// Performs an atomic Check-Out transition for a Reservation:
    ///   1. Validates the reservation is in Occupied status.
    ///   2. Calculates the total stay charge (nights × nightly rate).
    ///   3. Sets Reservation Status to Closed.
    ///   4. Clears the Room.Occupied flag.
    /// All changes are committed together; if any guard fails the entire
    /// operation is rolled back via an Error().
    /// </summary>
    procedure CheckOut(var ReservationHeader: Record "Reservation Header")
    var
        TotalCharge: Decimal;
        NumberOfNights: Integer;
    begin
        // Guard: must be in Occupied status
        if ReservationHeader.Status <> "Hotel Reservation Status"::Occupied then
            Error('Check-Out is only allowed for reservations with status Occupied. Current status: %1.',
                  ReservationHeader.Status);

        // Guard: a room must be assigned
        if ReservationHeader."Room No." = '' then
            Error('A Room must be assigned to this reservation.');

        // Billing process: calculate total stay charge
        TotalCharge := CalculateTotalCharge(ReservationHeader, NumberOfNights);

        // Transition reservation status → Closed (this will also update Room.Occupied via OnValidate)
        ReservationHeader.Validate(Status, "Hotel Reservation Status"::Closed);
        ReservationHeader.Modify(true);

        // Notify front desk of the billing summary
        if NumberOfNights > 0 then
            Message('Check-Out complete.\\Stay: %1 night(s) × %2 = %3.\\Deposit collected: %4.',
                    NumberOfNights,
                    ReservationHeader."Nightly Rate",
                    TotalCharge,
                    ReservationHeader."Deposit Amount")
        else
            Message('Check-Out complete. Reservation %1 has been closed.',
                    ReservationHeader."Reservation No.");
    end;

    /// <summary>
    /// Calculates the total room charge based on the number of nights between
    /// Check-In Date and Check-Out Date multiplied by the Nightly Rate.
    /// Returns the total charge; sets NumberOfNights as an output parameter.
    /// </summary>
    local procedure CalculateTotalCharge(ReservationHeader: Record "Reservation Header"; var NumberOfNights: Integer): Decimal
    begin
        NumberOfNights := 0;

        if (ReservationHeader."Check-In Date" = 0D) or (ReservationHeader."Check-Out Date" = 0D) then
            exit(0);

        if ReservationHeader."Check-Out Date" <= ReservationHeader."Check-In Date" then
            exit(0);

        NumberOfNights := ReservationHeader."Check-Out Date" - ReservationHeader."Check-In Date";
        exit(NumberOfNights * ReservationHeader."Nightly Rate");
    end;
}
