codeunit 50108 "Process Refund"
{
    /// <summary>
    /// Handles the full 'Process Refund' workflow for a Hotel Reservation.
    ///
    /// Security model:
    ///   This codeunit may only be invoked by users holding the HOTEL-FINANCE
    ///   or HOTEL-ADMIN permission set.  The gate is enforced in two layers:
    ///
    ///   Layer 1 — UI (AccessByPermission on the page action):
    ///     The 'Process Refund' action on the Reservation Card and Reservation List
    ///     carries  AccessByPermission = tabledata "Hotel Setup" = M
    ///     HOTEL-FRONTDESK has only R on Hotel Setup, so the action is invisible
    ///     and inaccessible to Front Desk users directly from the UI.
    ///
    ///   Layer 2 — Code (CheckRefundPermission inside this codeunit):
    ///     Even if a Front Desk user were to call this codeunit by some other
    ///     means (e.g. a custom page or web-service call), the first statement
    ///     of ProcessRefund() calls HotelPermissionMgt.CheckRefundPermission(),
    ///     which raises a hard Error() for any user without Finance/Admin rights.
    ///
    /// Refund amount validation:
    ///   A refund cannot exceed the Amount Paid recorded on the Reservation Header.
    ///   This prevents over-refunding regardless of what the operator enters.
    ///
    /// Procedure: ProcessRefund
    ///   Accepts the Reservation Header and the requested refund amount.
    ///   Validates permissions, validates the amount ceiling, updates the
    ///   reservation record, and produces a success message.
    /// </summary>

    /// <summary>
    /// Main entry point called from the 'Process Refund' page action.
    /// Parameters:
    ///   ReservationHeader - the reservation being refunded (passed by VAR so
    ///                       field updates are visible to the caller's record variable).
    ///   RefundAmount      - the amount the Finance user wants to refund.
    ///                       Must be > 0 and <= ReservationHeader."Amount Paid".
    /// </summary>
    procedure ProcessRefund(var ReservationHeader: Record "Reservation Header"; RefundAmount: Decimal)
    var
        HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
    begin
        // -----------------------------------------------------------------------
        // Layer 2 permission check — hard error for non-Finance/Admin users.
        // This fires even when the codeunit is called outside the standard UI.
        // -----------------------------------------------------------------------
        HotelPermissionMgt.CheckRefundPermission();

        // -----------------------------------------------------------------------
        // Input validation: refund amount must be positive.
        // -----------------------------------------------------------------------
        if RefundAmount <= 0 then
            Error(
                'Refund amount must be greater than zero. ' +
                'Please enter a positive refund amount for Reservation %1.',
                ReservationHeader."Reservation No.");

        // -----------------------------------------------------------------------
        // Ceiling validation: cannot refund more than what was actually paid.
        // Amount Paid is set when a deposit is captured (Post Deposit action)
        // or when Payment Status is set to Received via Capture Payment.
        // -----------------------------------------------------------------------
        if ReservationHeader."Amount Paid" <= 0 then
            Error(
                'No payment has been recorded for Reservation %1 (Amount Paid = 0). ' +
                'A refund can only be processed after a payment has been received.',
                ReservationHeader."Reservation No.");

        if RefundAmount > ReservationHeader."Amount Paid" then
            Error(
                'The requested refund amount of %1 exceeds the total payment received of %2 ' +
                'for Reservation %3.\\' +
                'A refund cannot exceed the original payment amount.',
                RefundAmount,
                ReservationHeader."Amount Paid",
                ReservationHeader."Reservation No.");

        // -----------------------------------------------------------------------
        // Execute the refund: reduce Amount Paid by the refunded amount,
        // clear deposit flags when the full deposit has been returned,
        // and record the updated payment status.
        // -----------------------------------------------------------------------
        ApplyRefund(ReservationHeader, RefundAmount);
    end;

    /// <summary>
    /// Applies the validated refund to the Reservation Header.
    /// Reduces Amount Paid by RefundAmount.
    /// When the refund covers the full deposit (Amount Paid reaches 0),
    /// Deposit Captured and Deposit Received are cleared to reflect that
    /// no captured funds remain on the reservation.
    /// Payment Status is set back to Pending to indicate the reservation
    /// balance is no longer settled.
    /// </summary>
    local procedure ApplyRefund(var ReservationHeader: Record "Reservation Header"; RefundAmount: Decimal)
    var
        NewAmountPaid: Decimal;
    begin
        NewAmountPaid := ReservationHeader."Amount Paid" - RefundAmount;

        // When the full payment has been refunded, clear all payment/deposit flags.
        if NewAmountPaid <= 0 then begin
            NewAmountPaid := 0;
            ReservationHeader.Validate("Deposit Captured", false);
            ReservationHeader.Validate("Deposit Received", false);
            ReservationHeader.Validate("Payment Status", "Hotel Payment Status"::Pending);
        end;

        // Write the reduced Amount Paid directly (field is Editable = false on the
        // page but must be writable here to record the post-refund balance).
        ReservationHeader."Amount Paid" := NewAmountPaid;
        ReservationHeader.Modify(true);

        Message(
            'Refund of %1 has been successfully processed for Reservation %2.\\' +
            'Remaining amount paid: %3.',
            RefundAmount,
            ReservationHeader."Reservation No.",
            NewAmountPaid);
    end;
}
