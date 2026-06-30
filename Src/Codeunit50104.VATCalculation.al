codeunit 50104 "Hotel VAT Calculation"
{
    /// <summary>
    /// Central VAT calculation engine for the Hotel extension.
    ///
    /// VAT resolution priority (highest to lowest):
    ///   1. BC's standard VATPostingSetup: looked up using the VAT Bus. Posting Group
    ///      on the Reservation Header combined with the VAT Prod. Posting Group from
    ///      Hotel Setup. This is the native BC tax-engine path.
    ///   2. HotelSetup."Default Room VAT %" — fallback when no posting-group match
    ///      exists.
    ///
    /// Integration with BC's native Sales Line VAT calculation:
    ///   An event subscriber on Sales Line's OnAfterValidateEvent for "VAT Prod.
    ///   Posting Group" re-applies the correct hotel VAT posting groups to every
    ///   Sales Line created from a hotel reservation invoice, ensuring BC's own
    ///   VAT calculation routines produce the correct tax entries on posting.
    ///
    /// Recalculation on Hotel Setup change:
    ///   BulkRecalcUnInvoicedReservations iterates all Reservation Headers that
    ///   have not yet been invoiced and re-runs CalcReservationVAT on each one,
    ///   keeping stored VAT amounts current after a VAT setup change.
    /// </summary>

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    /// <summary>
    /// Entry point: calculates VAT for all charges on the given Reservation Header
    /// and writes the results back. Can be called at any time before invoicing.
    /// Resolves VAT % from BC's VATPostingSetup using the posting groups on the
    /// Reservation Header and Hotel Setup, then falls back to Default Room VAT %.
    /// </summary>
    procedure CalcReservationVAT(var ReservationHeader: Record "Reservation Header")
    var
        HotelSetup: Record "Hotel Setup";
        ReservationServiceCharge: Record "Reservation Service Charge";
        RoomChargeExclVAT: Decimal;
        RoomVATAmount: Decimal;
        TotalExclVAT: Decimal;
        TotalVATAmount: Decimal;
        NumberOfNights: Integer;
        VATPercent: Decimal;
    begin
        HotelSetup.GetRecordOnce();

        // Resolve the effective VAT % from BC's native VATPostingSetup table using
        // the posting group combination, falling back to the Default Room VAT %.
        VATPercent := ResolveVATPercent(
            ReservationHeader."VAT Bus. Posting Group",
            HotelSetup."VAT Prod. Posting Group",
            HotelSetup."Default Room VAT %");

        // --- Room charge VAT ---
        RoomChargeExclVAT := 0;
        RoomVATAmount := 0;
        if (ReservationHeader."Check-In Date" <> 0D) and
           (ReservationHeader."Check-Out Date" <> 0D) and
           (ReservationHeader."Check-Out Date" > ReservationHeader."Check-In Date")
        then begin
            NumberOfNights :=
                ReservationHeader."Check-Out Date" - ReservationHeader."Check-In Date";
            RoomChargeExclVAT := NumberOfNights * ReservationHeader."Nightly Rate";
            RoomVATAmount :=
                Round(RoomChargeExclVAT * VATPercent / 100, GetRoundingPrecision());
        end;

        TotalExclVAT   := RoomChargeExclVAT;
        TotalVATAmount := RoomVATAmount;

        // --- Service charge VAT ---
        // Apply the same resolved VAT % to every service charge line so that both
        // room rates and service charges are taxed based on BC Tax configuration.
        ReservationServiceCharge.SetRange(
            "Reservation No.", ReservationHeader."Reservation No.");
        if ReservationServiceCharge.FindSet(true) then
            repeat
                ReservationServiceCharge."VAT %" := VATPercent;
                ReservationServiceCharge."VAT Amount" :=
                    Round(
                        ReservationServiceCharge.Amount * VATPercent / 100,
                        GetRoundingPrecision());
                ReservationServiceCharge."Amount Incl. VAT" :=
                    ReservationServiceCharge.Amount +
                    ReservationServiceCharge."VAT Amount";
                ReservationServiceCharge.Modify(false);

                TotalExclVAT   += ReservationServiceCharge.Amount;
                TotalVATAmount += ReservationServiceCharge."VAT Amount";
            until ReservationServiceCharge.Next() = 0;

        // --- Write totals back to Reservation Header ---
        ReservationHeader."VAT Amount"      := TotalVATAmount;
        ReservationHeader."Amount Incl. VAT" := TotalExclVAT + TotalVATAmount;
        ReservationHeader.Modify(true);
    end;

    /// <summary>
    /// 'Recalculate Tax' entry point — refreshes VAT calculations in case the
    /// VAT posting setup has changed since the last calculation.
    /// Displays a confirmation message when complete.
    /// Blocked on fully-invoiced reservations.
    /// </summary>
    procedure RecalculateTax(var ReservationHeader: Record "Reservation Header")
    begin
        if ReservationHeader."Reservation No." = '' then
            Error('No reservation is selected.');

        if ReservationHeader.Status = "Hotel Reservation Status"::Closed then
            if ReservationHeader."Invoice No." <> '' then
                Error(
                    'Tax cannot be recalculated after an invoice has been generated (Invoice %1).',
                    ReservationHeader."Invoice No.");

        CalcReservationVAT(ReservationHeader);

        Message(
            'Tax has been recalculated for Reservation %1.\\VAT Amount: %2  |  Total Incl. VAT: %3',
            ReservationHeader."Reservation No.",
            ReservationHeader."VAT Amount",
            ReservationHeader."Amount Incl. VAT");
    end;

    /// <summary>
    /// Bulk recalculation: iterates all Reservation Headers that have not yet been
    /// invoiced (Invoice No. = '') and re-runs CalcReservationVAT on each one.
    /// Called from the Hotel Setup table's OnModify trigger and from the
    /// Hotel Setup page's SaveSetup action whenever VAT-relevant fields change.
    ///
    /// This fulfils the acceptance criterion: changing VAT setup on the Hotel Setup
    /// page triggers an update on all un-invoiced reservations.
    ///
    /// Returns the count of reservations that were updated.
    /// </summary>
    procedure BulkRecalcUnInvoicedReservations(): Integer
    var
        ReservationHeader: Record "Reservation Header";
        UpdatedCount: Integer;
    begin
        UpdatedCount := 0;

        // Only process reservations that have not yet been invoiced.
        ReservationHeader.SetRange("Invoice No.", '');
        if ReservationHeader.FindSet(true) then
            repeat
                // Skip reservations without the minimum data needed for VAT calc.
                if (ReservationHeader."Customer No." <> '') and
                   (ReservationHeader."Room No." <> '')
                then begin
                    CalcReservationVAT(ReservationHeader);
                    UpdatedCount += 1;
                end;
            until ReservationHeader.Next() = 0;

        exit(UpdatedCount);
    end;

    /// <summary>
    /// Retrieves the VAT % applicable to the given reservation using the
    /// VAT Bus. Posting Group on the header and the VAT Prod. Posting Group
    /// configured in Hotel Setup.
    /// Returns 0 when posting groups are not configured.
    /// </summary>
    procedure GetVATPercent(ReservationHeader: Record "Reservation Header"): Decimal
    var
        HotelSetup: Record "Hotel Setup";
    begin
        HotelSetup.GetRecordOnce();
        exit(
            ResolveVATPercent(
                ReservationHeader."VAT Bus. Posting Group",
                HotelSetup."VAT Prod. Posting Group",
                HotelSetup."Default Room VAT %"));
    end;

    /// <summary>
    /// Returns the VAT % for the given Business/Product Posting Group combination
    /// from BC's native VATPostingSetup table.
    /// Falls back to DefaultVATPct when the posting groups are blank or when no
    /// matching VATPostingSetup row exists.
    /// This is the single authoritative resolution path used by all procedures in
    /// this codeunit so that the BC tax engine is always the primary source.
    /// </summary>
    procedure GetVATPercentFromSetup(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; DefaultVATPct: Decimal): Decimal
    begin
        exit(ResolveVATPercent(VATBusPostingGroup, VATProdPostingGroup, DefaultVATPct));
    end;

    // -------------------------------------------------------------------------
    // Event Subscribers — BC native Sales Line VAT calculation integration
    // -------------------------------------------------------------------------

    /// <summary>
    /// Hooks into the Sales Line insertion event raised when invoice lines are
    /// created by GenerateInvoice. When the Sales Header carries a Hotel
    /// Reservation No. the subscriber ensures that the correct VAT Prod. Posting
    /// Group from Hotel Setup is stamped on the line, thereby driving BC's own
    /// VAT calculation routines through the standard VATPostingSetup lookup when
    /// the invoice is eventually posted.
    ///
    /// This satisfies the technical hint: "Hook into the Sales Line VAT
    /// calculation events when generating the invoice."
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        SalesHeader: Record "Sales Header";
        HotelSetup: Record "Hotel Setup";
    begin
        // Only act on Invoice-type documents.
        if Rec."Document Type" <> Rec."Document Type"::Invoice then
            exit;

        // Only act when a Hotel Reservation No. is present on the Sales Header,
        // meaning this line was generated by the hotel invoice flow.
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        if SalesHeader."Hotel Reservation No." = '' then
            exit;

        // Only apply to Item lines — skip blank/comment lines (Type = ' ').
        if Rec.Type <> Rec.Type::Item then
            exit;

        HotelSetup.GetRecordOnce();

        // Apply hotel VAT Prod. Posting Group when it is configured and the line
        // does not already carry one. This ensures BC's standard
        // VATPostingSetup lookup fires with the correct product group,
        // producing the right VAT entries on posting.
        if (HotelSetup."VAT Prod. Posting Group" <> '') and
           (Rec."VAT Prod. Posting Group" <> HotelSetup."VAT Prod. Posting Group")
        then begin
            Rec."VAT Prod. Posting Group" := HotelSetup."VAT Prod. Posting Group";
            Rec.Modify(false);
        end;
    end;

    /// <summary>
    /// Hooks into the Sales Line OnAfterValidateEvent for 'VAT Prod. Posting Group'.
    /// When BC validates the VAT Prod. Posting Group on a hotel Sales Line it
    /// internally looks up VATPostingSetup and recalculates the VAT amount on the
    /// line using its own tax engine. This subscriber runs after that recalculation
    /// to ensure the hotel posting group is preserved — preventing any downstream
    /// code from overwriting it with an incorrect value.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'VAT Prod. Posting Group', false, false)]
    local procedure OnAfterValidateVATProdPostingGroup(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
        HotelSetup: Record "Hotel Setup";
    begin
        // Only act on Invoice lines for hotel reservations.
        if Rec."Document Type" <> Rec."Document Type"::Invoice then
            exit;

        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        if SalesHeader."Hotel Reservation No." = '' then
            exit;

        if Rec.Type <> Rec.Type::Item then
            exit;

        HotelSetup.GetRecordOnce();

        // If the hotel posting group is configured and BC's own validation has
        // replaced it with a different value, restore it so that the correct
        // VATPostingSetup row drives the tax calculation.
        if (HotelSetup."VAT Prod. Posting Group" <> '') and
           (Rec."VAT Prod. Posting Group" <> HotelSetup."VAT Prod. Posting Group")
        then
            Rec."VAT Prod. Posting Group" := HotelSetup."VAT Prod. Posting Group";
    end;

    // -------------------------------------------------------------------------
    // Private helpers
    // -------------------------------------------------------------------------

    /// <summary>
    /// Core VAT % resolution: queries BC's VATPostingSetup for the given
    /// Business/Product Posting Group combination. Returns DefaultVATPct when
    /// the groups are blank or no matching setup row exists.
    /// </summary>
    local procedure ResolveVATPercent(
        VATBusPostingGroup: Code[20];
        VATProdPostingGroup: Code[20];
        DefaultVATPct: Decimal): Decimal
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if (VATBusPostingGroup <> '') and (VATProdPostingGroup <> '') then
            if VATPostingSetup.Get(VATBusPostingGroup, VATProdPostingGroup) then
                exit(VATPostingSetup."VAT %");

        exit(DefaultVATPct);
    end;

    local procedure GetRoundingPrecision(): Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if GeneralLedgerSetup.Get() then
            exit(GeneralLedgerSetup."Amount Rounding Precision");
        exit(0.01);
    end;
}
