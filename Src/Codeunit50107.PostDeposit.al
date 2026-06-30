codeunit 50107 "Post Deposit"
{
    /// <summary>
    /// Simulates a deposit payment capture for a Reservation Header.
    /// This action:
    ///   1. Validates a Deposit Amount has been specified on the reservation.
    ///   2. Guards that the deposit has not already been captured.
    ///   3. Guards that the reservation is in Confirmed status (deposit must be
    ///      posted before Check-In transitions the reservation to Occupied).
    ///   4. Simulates or integrates with a payment gateway to capture the deposit.
    ///   5. On success: sets Deposit Captured = TRUE, Deposit Received = TRUE,
    ///      and Payment Status = Received.
    ///   6. On simulated failure: sets Payment Status = Failed and raises an error
    ///      that blocks Check-In and Invoice Generation until resolved.
    /// All changes are committed together; any guard failure rolls back via Error().
    /// </summary>
    procedure PostDeposit(var ReservationHeader: Record "Reservation Header")
    begin
        // Guard: a deposit amount must be specified
        if ReservationHeader."Deposit Amount" <= 0 then
            Error(
                'Post Deposit cannot proceed for Reservation %1 because no Deposit Amount has been set. ' +
                'Please enter a Deposit Amount before posting the deposit.',
                ReservationHeader."Reservation No.");

        // Guard: deposit must not already be captured
        if ReservationHeader."Deposit Captured" then
            Error(
                'The deposit for Reservation %1 has already been captured (Amount: %2). ' +
                'No further action is required.',
                ReservationHeader."Reservation No.",
                ReservationHeader."Deposit Amount");

        // Guard: reservation must be in Confirmed status — deposits are captured
        // before check-in, so Occupied or Closed reservations should not use this action.
        if ReservationHeader.Status <> "Hotel Reservation Status"::Confirmed then
            Error(
                'Post Deposit is only available for reservations in Confirmed status. ' +
                'Current status: %1.',
                ReservationHeader.Status);

        // Simulate payment capture.
        // In a real integration this is the point where an external payment gateway
        // API call would be made. The result (captured / failed) would be handled below.
        // For this simulation the capture always succeeds.
        CaptureDepositPayment(ReservationHeader);
    end;

    /// <summary>
    /// Internal procedure that performs the deposit capture and records the outcome.
    /// Simulates a successful payment capture by setting Deposit Captured, Deposit
    /// Received and Payment Status to their post-capture values, then saves the record.
    /// In a real payment-gateway integration, replace the simulation block with the
    /// actual API call and handle success/failure branches accordingly.
    /// </summary>
    local procedure CaptureDepositPayment(var ReservationHeader: Record "Reservation Header")
    var
        CaptureSucceeded: Boolean;
    begin
        // --- Payment gateway integration point ---
        // Replace the line below with your payment provider API call.
        // CaptureSucceeded := PaymentGateway.CaptureDeposit(
        //     ReservationHeader."Customer No.",
        //     ReservationHeader."Deposit Amount");
        CaptureSucceeded := true;  // Simulation: capture always succeeds
        // -----------------------------------------

        if CaptureSucceeded then begin
            // Record successful deposit capture
            ReservationHeader.Validate("Deposit Captured", true);
            ReservationHeader.Validate("Deposit Received", true);
            ReservationHeader.Validate("Payment Status", "Hotel Payment Status"::Received);
            ReservationHeader."Amount Paid" := ReservationHeader."Deposit Amount";
            ReservationHeader.Modify(true);

            Message(
                'Deposit of %1 has been successfully captured for Reservation %2.\' +
                'Deposit Captured has been set to Yes and Payment Status updated to Received.\' +
                'The reservation may now proceed to Check-In.',
                ReservationHeader."Deposit Amount",
                ReservationHeader."Reservation No.");
        end else begin
            // Record failed capture — blocks Check-In and Invoice Generation
            ReservationHeader.Validate("Payment Status", "Hotel Payment Status"::Failed);
            ReservationHeader.Modify(true);

            Error(
                'Deposit capture FAILED for Reservation %1 (Amount: %2).\' +
                'Payment Status has been set to Failed.\' +
                'Check-In and Invoice Generation are blocked until the issue is resolved.\' +
                'Please retry the payment or contact the guest.',
                ReservationHeader."Reservation No.",
                ReservationHeader."Deposit Amount");
        end;
    end;
}
