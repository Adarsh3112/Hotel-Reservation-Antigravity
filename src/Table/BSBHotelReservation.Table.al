table 50112 "BSB Hotel Reservation"
{
    Caption = 'Hotel Reservation';
    DataClassification = CustomerContent;
    LookupPageId = "BSB Hotel Res. List";
    DrillDownPageId = "BSB Hotel Res. List";

    fields
    {
        field(1; "Reservation No."; Code[20])
        {
            Caption = 'Reservation No.';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                EnsureCanEditBeforeInvoice();
            end;
        }
        field(3; "Room No."; Code[20])
        {
            Caption = 'Room No.';
            TableRelation = "BSB Hotel Room";

            trigger OnValidate()
            var
                HotelMgt: Codeunit "BSB Hotel Mgt.";
            begin
                EnsureCanEditBeforeInvoice();
                HotelMgt.ValidateRoomAvailable(Rec);
            end;
        }
        field(4; "Check-in Date"; Date)
        {
            Caption = 'Check-in Date';

            trigger OnValidate()
            var
                HotelMgt: Codeunit "BSB Hotel Mgt.";
            begin
                EnsureCanEditBeforeInvoice();
                ValidateDateRange();
                HotelMgt.ValidateRoomAvailable(Rec);
            end;
        }
        field(5; "Check-out Date"; Date)
        {
            Caption = 'Check-out Date';

            trigger OnValidate()
            var
                HotelMgt: Codeunit "BSB Hotel Mgt.";
            begin
                EnsureCanEditBeforeInvoice();
                ValidateDateRange();
                HotelMgt.ValidateRoomAvailable(Rec);
            end;
        }
        field(6; Status; Enum "BSB Hotel Res. Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(7; "Deposit Amount"; Decimal)
        {
            Caption = 'Deposit Amount';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(8; "Deposit Captured"; Boolean)
        {
            Caption = 'Deposit Captured';
            Editable = false;
        }
        field(9; "Captured Deposit Amt."; Decimal)
        {
            Caption = 'Captured Deposit Amt.';
            AutoFormatType = 1;
            Editable = false;
        }
        field(10; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            Editable = false;
        }
        field(11; "Invoice Posted"; Boolean)
        {
            Caption = 'Invoice Posted';
            Editable = false;
        }
        field(12; "Invoice Amount"; Decimal)
        {
            Caption = 'Invoice Amount';
            AutoFormatType = 1;
            Editable = false;
        }
        field(13; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            AutoFormatType = 1;
            Editable = false;
        }
        field(14; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            AutoFormatType = 1;
            Editable = false;
        }
        field(15; "Final Payment Posted"; Boolean)
        {
            Caption = 'Final Payment Posted';
            Editable = false;
        }
        field(16; "Refund Amount"; Decimal)
        {
            Caption = 'Refund Amount';
            AutoFormatType = 1;
            Editable = false;
        }
        field(17; "Refund Posted"; Boolean)
        {
            Caption = 'Refund Posted';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Reservation No.")
        {
            Clustered = true;
        }
        key(RoomDates; "Room No.", "Check-in Date", "Check-out Date", Status)
        {
        }
    }

    trigger OnInsert()
    var
        HotelMgt: Codeunit "BSB Hotel Mgt.";
    begin
        if Status.AsInteger() = 0 then
            Status := Status::Confirmed;
        HotelMgt.AssignReservationNo(Rec);
        ValidateDateRange();
        HotelMgt.ValidateRoomAvailable(Rec);
    end;

    trigger OnModify()
    var
        HotelMgt: Codeunit "BSB Hotel Mgt.";
    begin
        ValidateDateRange();
        HotelMgt.ValidateRoomAvailable(Rec);
    end;

    procedure ValidateDateRange()
    begin
        if ("Check-in Date" = 0D) or ("Check-out Date" = 0D) then
            exit;
        if "Check-out Date" <= "Check-in Date" then
            Error('Check-out Date must be after Check-in Date.');
    end;

    procedure EnsureCanEditBeforeInvoice()
    begin
        if "Invoice No." <> '' then
            Error('Reservation %1 cannot be changed after invoice %2 has been generated.', "Reservation No.", "Invoice No.");
    end;
}
