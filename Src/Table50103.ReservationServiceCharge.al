table 50103 "Reservation Service Charge"
{
    Caption = 'Reservation Service Charge';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reservation No."; Code[20])
        {
            Caption = 'Reservation No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Reservation Header"."Reservation No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                Amount := Quantity * "Unit Price";
            end;
        }
        field(5; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            MinValue = 0;
            AutoFormatType = 1;

            trigger OnValidate()
            begin
                Amount := Quantity * "Unit Price";
            end;
        }
        field(6; "Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Editable = false;
        }
        field(7; "Posted"; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(8; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(9; "Type"; Enum "Reservation Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Service;
        }
        field(10; "Service Type"; Enum "Hotel Service Type")
        {
            Caption = 'Service Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // Auto-populate Description from Service Type when not already set
                if "Service Type" <> "Hotel Service Type"::" " then
                    if Description = '' then
                        Description := CopyStr(Format("Service Type"), 1, MaxStrLen(Description));
            end;
        }
        field(11; "Validated"; Boolean)
        {
            Caption = 'Validated';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Validated By"; Code[50])
        {
            Caption = 'Validated By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
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
        field(15; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
            MaxValue = 100;
        }
    }

    keys
    {
        key(PK; "Reservation No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Reservation No.", "Line No.", "Description", "Amount") { }
    }

    trigger OnInsert()
    begin
        CheckIfReservationClosed();
        Amount := Quantity * "Unit Price";
    end;

    trigger OnModify()
    begin
        if xRec.Posted then
            if (Description <> xRec.Description) or
               (Quantity <> xRec.Quantity) or
               ("Unit Price" <> xRec."Unit Price") or
               (Type <> xRec.Type) or
               ("Service Type" <> xRec."Service Type")
            then
                Error('You cannot modify the core details (Description, Quantity, Price, Type) of a posted service charge.');

        CheckIfReservationClosed();
        Amount := Quantity * "Unit Price";
    end;

    trigger OnDelete()
    begin
        if Posted then
            Error('You cannot delete a posted service charge.');
        CheckIfReservationClosed();
    end;

    local procedure CheckIfReservationClosed()
    var
        ReservationHeader: Record "Reservation Header";
    begin
        if ReservationHeader.Get("Reservation No.") then
            if ReservationHeader.Status = ReservationHeader.Status::Closed then
                Error('You cannot add, modify, or delete service charges for a Closed reservation.');
    end;
}
