table 50101 "Reservation Header"
{
    Caption = 'Reservation Header';
    DataClassification = CustomerContent;
    LookupPageId = "Reservation List";
    DrillDownPageId = "Reservation List";

    fields
    {
        field(1; "Reservation No."; Code[20])
        {
            Caption = 'Reservation No.';
            DataClassification = CustomerContent;
            NotBlank = false;
            Editable = false;

            trigger OnValidate()
            begin
                if "Reservation No." <> xRec."Reservation No." then begin
                    NoSeries.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if "Customer No." <> '' then begin
                    Customer.Get("Customer No.");
                    "Customer Name" := Customer.Name;
                    "Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
                    "VAT Bus. Posting Group" := Customer."VAT Bus. Posting Group";
                end else begin
                    "Customer Name" := '';
                    "Gen. Bus. Posting Group" := '';
                    "VAT Bus. Posting Group" := '';
                end;
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Room No."; Code[20])
        {
            Caption = 'Room No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Room."Room No.";

            trigger OnValidate()
            var
                HotelReservationMgt: Codeunit "Hotel Reservation Mgt";
                RoomAvailabilityCheck: Codeunit "Room Availability Check";
            begin
                HotelReservationMgt.FetchRateFromRoom(Rec);
                // Primary availability gate: CheckAvailability via dedicated codeunit
                RoomAvailabilityCheck.CheckAvailabilityOrError(Rec);
                HotelReservationMgt.UpdateRoomOccupancy(Rec, xRec);
            end;
        }
        field(5; "Check-In Date"; Date)
        {
            Caption = 'Check-In Date';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            var
                RoomAvailabilityCheck: Codeunit "Room Availability Check";
            begin
                if ("Check-In Date" <> 0D) and ("Check-Out Date" <> 0D) then
                    if "Check-In Date" >= "Check-Out Date" then
                        Error('Check-In Date must be earlier than Check-Out Date.');
                // Primary availability gate: fires immediately when date is changed
                RoomAvailabilityCheck.CheckAvailabilityOrError(Rec);
            end;
        }
        field(6; "Check-Out Date"; Date)
        {
            Caption = 'Check-Out Date';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            var
                RoomAvailabilityCheck: Codeunit "Room Availability Check";
            begin
                if ("Check-In Date" <> 0D) and ("Check-Out Date" <> 0D) then
                    if "Check-Out Date" <= "Check-In Date" then
                        Error('Check-Out Date must be later than Check-In Date.');
                // Primary availability gate: fires immediately when date is changed
                RoomAvailabilityCheck.CheckAvailabilityOrError(Rec);
            end;
        }
        field(7; "Status"; Enum "Hotel Reservation Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                HotelReservationMgt: Codeunit "Hotel Reservation Mgt";
            begin
                // Guard: deposit must be captured before transitioning to Occupied
                if Status = Status::Occupied then begin
                    if ("Deposit Amount" > 0) and (not "Deposit Captured") then
                        Error(
                            'Reservation %1 cannot be set to Occupied because a deposit of %2 is required ' +
                            'but has not been captured. Please run Post Deposit before proceeding.',
                            "Reservation No.",
                            "Deposit Amount");
                end;
                HotelReservationMgt.UpdateRoomOccupancy(Rec, xRec);
            end;
        }
        field(8; "Deposit Amount"; Decimal)
        {
            Caption = 'Deposit Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
            AutoFormatType = 1;
        }
        field(9; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(10; "Nightly Rate"; Decimal)
        {
            Caption = 'Nightly Rate';
            DataClassification = CustomerContent;
            MinValue = 0;
            AutoFormatType = 1;
            Editable = false;
        }
        field(11; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Sales Header"."No." where("Document Type" = const(Invoice));
        }
        field(12; "Deposit Received"; Boolean)
        {
            Caption = 'Deposit Received';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // Keep Deposit Captured in sync: when Deposit Received is set,
                // mirror the value to Deposit Captured so both fields stay consistent.
                "Deposit Captured" := "Deposit Received";
            end;
        }
        field(13; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
            Editable = false;
            AutoFormatType = 1;
        }
        field(14; "Amount Incl. VAT"; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            DataClassification = CustomerContent;
            Editable = false;
            AutoFormatType = 1;
        }
        field(15; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(16; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(17; "Payment Status"; Enum "Hotel Payment Status")
        {
            Caption = 'Payment Status';
            DataClassification = CustomerContent;
            InitValue = "Pending";
        }
        field(18; "Total Service Charges"; Decimal)
        {
            Caption = 'Total Service Charges';
            FieldClass = FlowField;
            CalcFormula = sum("Reservation Service Charge".Amount where("Reservation No." = field("Reservation No.")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(19; "Deposit Captured"; Boolean)
        {
            Caption = 'Deposit Captured';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // Keep legacy Deposit Received field in sync when Deposit Captured changes.
                "Deposit Received" := "Deposit Captured";
            end;
        }
        field(20; "Amount Paid"; Decimal)
        {
            Caption = 'Amount Paid';
            DataClassification = CustomerContent;
            MinValue = 0;
            AutoFormatType = 1;
            Editable = false;
            ToolTip = 'Specifies the total payment amount received for this reservation. Used as the ceiling for refund validation — a refund cannot exceed this amount.';
        }
    }

    keys
    {
        key(PK; "Reservation No.")
        {
            Clustered = true;
        }
        key(CustomerIdx; "Customer No.") { }
        key(RoomIdx; "Room No.") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Reservation No.", "Customer No.", "Room No.", "Status") { }
        fieldgroup(Brick; "Reservation No.", "Customer Name", "Room No.", "Status") { }
    }

    var

    var
        NoSeries: Codeunit "No. Series";

    trigger OnInsert()
    var
        RoomAvailabilityCheck: Codeunit "Room Availability Check";
    begin
        if "Reservation No." = '' then begin
            "No. Series" := GetNoSeriesCode();
            "Reservation No." := NoSeries.GetNextNo("No. Series");
        end;

        // Primary availability gate: dedicated CheckAvailability codeunit
        RoomAvailabilityCheck.CheckAvailabilityOrError(Rec);
    end;

    trigger OnModify()
    var
        RoomAvailabilityCheck: Codeunit "Room Availability Check";
    begin
        if (xRec."Status" = xRec."Status"::Closed) and ("Status" <> "Status"::Closed) then
            Error('You cannot re-open a Closed reservation.');
        // Primary availability gate: dedicated CheckAvailability codeunit
        RoomAvailabilityCheck.CheckAvailabilityOrError(Rec);
    end;

    trigger OnDelete()
    var
        ReservationServiceCharge: Record "Reservation Service Charge";
    begin
        if "Status" = "Status"::Occupied then
            Error('You cannot delete a reservation that is currently Occupied.');

        if "Invoice No." <> '' then
            Error('You cannot delete a reservation that has already been invoiced (Invoice %1).', "Invoice No.");

        ReservationServiceCharge.SetRange("Reservation No.", "Reservation No.");
        ReservationServiceCharge.DeleteAll(true);
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        HotelSetup: Record "Hotel Setup";
    begin
        if not HotelSetup.Get() then begin
            HotelSetup.Init();
            HotelSetup."Reservation Nos." := GetOrCreateNoSeries();
            HotelSetup.Insert();
        end;
        if HotelSetup."Reservation Nos." = '' then begin
            HotelSetup."Reservation Nos." := GetOrCreateNoSeries();
            HotelSetup.Modify();
        end;
        exit(HotelSetup."Reservation Nos.");
    end;

    local procedure GetOrCreateNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := 'HOTEL-RES';
        if not NoSeries.Get(NoSeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := NoSeriesCode;
            NoSeries.Description := 'Hotel Reservations';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := false;
            NoSeries.Insert();

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NoSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'RES-00001';
            NoSeriesLine."Ending No." := 'RES-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;
        exit(NoSeriesCode);
    end;
}
