codeunit 50103 "Generate Hotel Invoice"
{
    /// <summary>
    /// Creates a standard BC Sales Invoice from a Reservation Header.
    /// The invoice includes:
    ///   - One Sales Line for the room charge (nights x nightly rate).
    ///   - One Sales Line per service charge line associated with the reservation.
    ///   - One negative Sales Line for the deposit credit when Deposit Amount > 0
    ///     and the deposit has been captured (Deposit Captured = TRUE) or received
    ///     (Deposit Received = TRUE, legacy field), effectively deducting the deposit
    ///     from the total due.
    /// VAT Bus./Prod. Posting Groups from the Reservation Header and Hotel Setup are
    /// applied to the Sales Header and each Sales Line so that BC's standard VAT
    /// routines compute the correct tax amounts on posting.
    ///
    /// The Reservation No. is stored on the Sales Invoice header in two places:
    ///   1. Sales Header."External Document No."  — standard BC field, visible on
    ///      printed documents and used for customer cross-reference.
    ///   2. Sales Header."Hotel Reservation No."  — custom extension field that
    ///      provides a typed, relational link back to the Reservation Header table.
    ///
    /// After the Sales Header is inserted the resulting Document No. is written
    /// back to Reservation Header."Invoice No.".
    ///
    /// Duplicate-invoice guard: if "Invoice No." is already populated the procedure
    /// raises an error immediately — before any Sales Header or line is created —
    /// ensuring that no double-billing can occur regardless of the calling context.
    /// </summary>
    procedure GenerateInvoice(var ReservationHeader: Record "Reservation Header")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        HotelSetup: Record "Hotel Setup";
        HotelVATCalculation: Codeunit "Hotel VAT Calculation";
        ReservationServiceCharge: Record "Reservation Service Charge";
        NextLineNo: Integer;
        NumberOfNights: Integer;
        RoomChargeAmount: Decimal;
        ServiceItemNo: Code[20];
        RoomItemNo: Code[20];
        DepositItemNo: Code[20];
        DepositIsCaptured: Boolean;
    begin
        // -----------------------------------------------------------------------
        // Guard: do not create a duplicate invoice.
        // This is the FIRST check — performed before any other logic so that
        // no Sales Header is ever created for an already-invoiced reservation.
        // -----------------------------------------------------------------------
        if ReservationHeader."Invoice No." <> '' then
            Error(
                'Invoice generation is blocked for Reservation %1: invoice %2 has already been generated. ' +
                'Duplicate invoices are not permitted.',
                ReservationHeader."Reservation No.",
                ReservationHeader."Invoice No.");

        // Guard: reservation must be Closed (checked out) before invoicing
        if ReservationHeader.Status <> "Hotel Reservation Status"::Closed then
            Error(
                'An invoice can only be generated for a Closed reservation. Current status: %1.',
                ReservationHeader.Status);

        // Guard: customer must be assigned
        if ReservationHeader."Customer No." = '' then
            Error('A Customer No. must be assigned to the reservation before generating an invoice.');

        // Guard: payment must not be in a Failed state before invoicing
        if ReservationHeader."Payment Status" = "Hotel Payment Status"::Failed then
            Error(
                'Invoice generation is blocked for Reservation %1 because the Payment Status is ''Failed''. ' +
                'Please resolve the payment issue before generating an invoice.',
                ReservationHeader."Reservation No.");

        // Determine whether the deposit was captured using the Deposit Captured
        // field (primary) or the legacy Deposit Received field (backward compat).
        DepositIsCaptured := ReservationHeader."Deposit Captured" or ReservationHeader."Deposit Received";

        // -----------------------------------------------------------------------
        // Load Hotel Setup — provides Item No. defaults and posting groups
        // -----------------------------------------------------------------------
        HotelSetup.GetRecordOnce();

        ServiceItemNo := HotelSetup."Service Charge Item No.";
        RoomItemNo    := HotelSetup."Room Charge Item No.";
        DepositItemNo := HotelSetup."Deposit Item No.";

        if RoomItemNo = '' then
            Error('Room Charge Item No. must be configured in Hotel Setup to generate the room charge line.');

        if (ReservationHeader."Deposit Amount" > 0) and DepositIsCaptured and (DepositItemNo = '') then
            Error('Deposit Item No. must be configured in Hotel Setup to apply the deposit credit.');

        // Ensure VAT is up-to-date before creating the invoice lines
        HotelVATCalculation.CalcReservationVAT(ReservationHeader);

        // -----------------------------------------------------------------------
        // Create Sales Header
        // -----------------------------------------------------------------------
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.Insert(true);   // Assigns Document No. from Sales invoice no. series

        SalesHeader.Validate("Sell-to Customer No.", ReservationHeader."Customer No.");
        SalesHeader.Validate("Prices Including VAT", false);
        SalesHeader.Validate("Posting Date", Today());

        // Store Reservation No. in External Document No. (standard BC field —
        // appears on printed invoice and used for customer cross-reference).
        SalesHeader."External Document No." := ReservationHeader."Reservation No.";

        // Store Reservation No. in the dedicated custom extension field so that
        // a typed, relational link back to the Reservation Header is maintained.
        SalesHeader."Hotel Reservation No." := ReservationHeader."Reservation No.";

        // Apply VAT/Gen. Bus. Posting Groups from the reservation so that the
        // correct VAT entries are created when the invoice is posted in BC.
        if ReservationHeader."VAT Bus. Posting Group" <> '' then
            SalesHeader.Validate("VAT Bus. Posting Group", ReservationHeader."VAT Bus. Posting Group");
        if ReservationHeader."Gen. Bus. Posting Group" <> '' then
            SalesHeader.Validate("Gen. Bus. Posting Group", ReservationHeader."Gen. Bus. Posting Group");

        SalesHeader.Modify(true);

        NextLineNo := 10000;

        // -----------------------------------------------------------------------
        // Sales Line 1: Room Charge  (Nightly Rate x Duration in nights)
        // -----------------------------------------------------------------------
        if (ReservationHeader."Check-In Date" <> 0D) and
           (ReservationHeader."Check-Out Date" <> 0D) and
           (ReservationHeader."Check-Out Date" > ReservationHeader."Check-In Date")
        then begin
            NumberOfNights   := ReservationHeader."Check-Out Date" - ReservationHeader."Check-In Date";
            RoomChargeAmount := NumberOfNights * ReservationHeader."Nightly Rate";

            SalesLine.Init();
            SalesLine.Validate("Document Type", SalesHeader."Document Type");
            SalesLine.Validate("Document No.", SalesHeader."No.");
            SalesLine.Validate("Line No.", NextLineNo);

            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", RoomItemNo);
            SalesLine.Description :=
                CopyStr(
                    StrSubstNo(
                        'Room %1 - %2 night(s) (%3 to %4)',
                        ReservationHeader."Room No.",
                        NumberOfNights,
                        ReservationHeader."Check-In Date",
                        ReservationHeader."Check-Out Date"),
                    1, MaxStrLen(SalesLine.Description));
            SalesLine.Validate(Quantity, NumberOfNights);
            SalesLine.Validate("Unit Price", ReservationHeader."Nightly Rate");

            // Apply product posting groups from Hotel Setup so VAT is computed
            // correctly at the line level by BC's standard routines.
            if HotelSetup."VAT Prod. Posting Group" <> '' then
                SalesLine.Validate("VAT Prod. Posting Group", HotelSetup."VAT Prod. Posting Group");
            if HotelSetup."Gen. Prod. Posting Group" <> '' then
                SalesLine.Validate("Gen. Prod. Posting Group", HotelSetup."Gen. Prod. Posting Group");

            SalesLine.Insert(true);
            NextLineNo += 10000;
        end;

        // -----------------------------------------------------------------------
        // Sales Lines: Service Charge lines
        // All service charge lines for this reservation are included on the
        // invoice so that the guest is billed for every recorded charge.
        // Posted + Validated lines represent fully approved charges; unposted
        // lines that exist are also included to ensure complete billing.
        // -----------------------------------------------------------------------
        ReservationServiceCharge.SetRange("Reservation No.", ReservationHeader."Reservation No.");
        if ReservationServiceCharge.FindSet() then begin
            if ServiceItemNo = '' then
                Error(
                    'Service Charge Item No. must be configured in Hotel Setup ' +
                    'to include service charges on the invoice.');

            repeat
                SalesLine.Init();
                SalesLine.Validate("Document Type", SalesHeader."Document Type");
                SalesLine.Validate("Document No.", SalesHeader."No.");
                SalesLine.Validate("Line No.", NextLineNo);

                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Validate("No.", ServiceItemNo);
                SalesLine.Description :=
                    CopyStr(
                        ReservationServiceCharge.Description,
                        1, MaxStrLen(SalesLine.Description));
                SalesLine.Validate(Quantity, ReservationServiceCharge.Quantity);
                SalesLine.Validate("Unit Price", ReservationServiceCharge."Unit Price");

                // Apply product posting groups for correct VAT treatment
                if HotelSetup."VAT Prod. Posting Group" <> '' then
                    SalesLine.Validate("VAT Prod. Posting Group", HotelSetup."VAT Prod. Posting Group");
                if HotelSetup."Gen. Prod. Posting Group" <> '' then
                    SalesLine.Validate("Gen. Prod. Posting Group", HotelSetup."Gen. Prod. Posting Group");

                SalesLine.Insert(true);
                NextLineNo += 10000;
            until ReservationServiceCharge.Next() = 0;
        end;

        // -----------------------------------------------------------------------
        // Sales Line: Deposit Handling
        // When Deposit Captured (or legacy Deposit Received) = TRUE: add a
        // negative credit line to deduct the deposit from the amount due.
        // When Deposit Amount > 0 but not captured: add an informational comment
        // line flagging the outstanding deposit for the billing agent.
        // -----------------------------------------------------------------------
        if ReservationHeader."Deposit Amount" > 0 then begin
            if DepositIsCaptured then begin
                // Deposit was captured — deduct it as a credit on the invoice
                SalesLine.Init();
                SalesLine.Validate("Document Type", SalesHeader."Document Type");
                SalesLine.Validate("Document No.", SalesHeader."No.");
                SalesLine.Validate("Line No.", NextLineNo);

                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Validate("No.", DepositItemNo);
                SalesLine.Description :=
                    CopyStr(
                        StrSubstNo(
                            'Deposit captured for Reservation %1 - credit applied',
                            ReservationHeader."Reservation No."),
                        1, MaxStrLen(SalesLine.Description));
                SalesLine.Validate(Quantity, 1);
                SalesLine.Validate("Unit Price", -ReservationHeader."Deposit Amount");

                if HotelSetup."VAT Prod. Posting Group" <> '' then
                    SalesLine.Validate("VAT Prod. Posting Group", HotelSetup."VAT Prod. Posting Group");
                if HotelSetup."Gen. Prod. Posting Group" <> '' then
                    SalesLine.Validate("Gen. Prod. Posting Group", HotelSetup."Gen. Prod. Posting Group");

                SalesLine.Insert(true);
                NextLineNo += 10000;
            end else begin
                // Deposit was NOT captured — flag it on the invoice so the billing
                // agent is aware that the deposit remains outstanding.
                SalesLine.Init();
                SalesLine.Validate("Document Type", SalesHeader."Document Type");
                SalesLine.Validate("Document No.", SalesHeader."No.");
                SalesLine.Validate("Line No.", NextLineNo);

                SalesLine.Validate(Type, SalesLine.Type::" ");
                SalesLine.Description :=
                    CopyStr(
                        StrSubstNo(
                            'WARNING: Deposit of %1 for Reservation %2 was NOT captured - ' +
                            'please collect separately.',
                            ReservationHeader."Deposit Amount",
                            ReservationHeader."Reservation No."),
                        1, MaxStrLen(SalesLine.Description));
                SalesLine.Validate(Quantity, 0);
                SalesLine.Insert(true);
                NextLineNo += 10000;
            end;
        end;

        // -----------------------------------------------------------------------
        // Write the generated Invoice No. back to the Reservation Header.
        // This also acts as the permanent duplicate-generation lock — once set,
        // the first guard at the top of this procedure prevents any re-run.
        // -----------------------------------------------------------------------
        ReservationHeader."Invoice No." := SalesHeader."No.";
        ReservationHeader.Modify(true);

        Message(
            'Invoice %1 has been created successfully for Reservation %2.',
            SalesHeader."No.",
            ReservationHeader."Reservation No.");
    end;
}
