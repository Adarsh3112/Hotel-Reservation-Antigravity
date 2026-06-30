table 50102 "Hotel Setup"
{
    Caption = 'Hotel Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Reservation Nos."; Code[20])
        {
            Caption = 'Reservation Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(3; "Room Charge Item No."; Code[20])
        {
            Caption = 'Room Charge Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(4; "Service Charge Item No."; Code[20])
        {
            Caption = 'Service Charge Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(5; "Deposit Item No."; Code[20])
        {
            Caption = 'Deposit Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(6; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(7; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(8; "Default Room VAT %"; Decimal)
        {
            Caption = 'Default Room VAT %';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the default VAT percentage applied to room charges. This value is used as the fallback rate when no VAT Product Posting Group override is present.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    var
        HotelVATCalculation: Codeunit "Hotel VAT Calculation";
        VATSetupChanged: Boolean;
        UpdatedCount: Integer;
    begin
        // Detect whether any VAT-relevant field has changed.
        // When VAT Prod. Posting Group or Default Room VAT % changes, all
        // un-invoiced reservations must be recalculated so that stored VAT
        // amounts reflect the new configuration immediately.
        VATSetupChanged :=
            (Rec."VAT Prod. Posting Group" <> xRec."VAT Prod. Posting Group") or
            (Rec."Default Room VAT %"      <> xRec."Default Room VAT %");

        if not VATSetupChanged then
            exit;

        if GuiAllowed then begin
            // Warn the user that VAT amounts will be recalculated on all
            // un-invoiced reservations as a result of the setup change.
            if not Confirm(
                'The VAT setup has changed (VAT Prod. Posting Group or Default Room VAT %%).\\' +
                'This will trigger a recalculation of VAT on all un-invoiced reservations.\\' +
                'Do you want to continue and recalculate now?',
                true)
            then begin
                // User declined — roll back the field changes by restoring xRec values
                // so the record is not saved with a partial update.
                Rec."VAT Prod. Posting Group" := xRec."VAT Prod. Posting Group";
                Rec."Default Room VAT %"      := xRec."Default Room VAT %";
                Error('VAT setup change was cancelled. No reservations were updated.');
            end;
        end;

        // Perform the bulk recalculation after the record is modified.
        UpdatedCount := HotelVATCalculation.BulkRecalcUnInvoicedReservations();

        if GuiAllowed then
            Message(
                'VAT setup updated.\\' +
                'VAT has been recalculated on %1 un-invoiced reservation(s).',
                UpdatedCount);
    end;

    /// <summary>
    /// Singleton helper — returns the one Hotel Setup record, creating it if it
    /// does not yet exist. Call this instead of a bare Get() wherever the setup
    /// record is needed so that a missing record never causes a runtime error.
    /// </summary>
    procedure GetRecordOnce()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
