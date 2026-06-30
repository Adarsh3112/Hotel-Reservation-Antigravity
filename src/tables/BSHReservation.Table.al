table 50112 "BSH Reservation"
{
    Caption = 'BSH Reservation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reservation No."; Code[20])
        {
            Caption = 'Reservation No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(3; "Room No."; Code[20])
        {
            Caption = 'Room No.';
            DataClassification = CustomerContent;
            TableRelation = "BSH Room"."Room No.";
        }
        field(4; "Check-in Date"; Date)
        {
            Caption = 'Check-in Date';
            DataClassification = CustomerContent;
        }
        field(5; "Check-out Date"; Date)
        {
            Caption = 'Check-out Date';
            DataClassification = CustomerContent;
        }
        field(6; Status; Enum "BSH Reservation Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(7; "Deposit Amount"; Decimal)
        {
            Caption = 'Deposit Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(8; "Deposit Status"; Enum "BSH Payment Status")
        {
            Caption = 'Deposit Status';
            DataClassification = CustomerContent;
        }
        field(9; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
        }
        field(10; "Final Paid"; Boolean)
        {
            Caption = 'Final Paid';
            DataClassification = CustomerContent;
        }
        field(11; "Closed At"; DateTime)
        {
            Caption = 'Closed At';
            DataClassification = CustomerContent;
        }
        field(12; "Lodging Amount"; Decimal)
        {
            Caption = 'Lodging Amount';
            DataClassification = CustomerContent;
        }
        field(13; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
            DataClassification = CustomerContent;
        }
        field(14; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
        }
        field(15; "Deposit Applied"; Decimal)
        {
            Caption = 'Deposit Applied';
            DataClassification = CustomerContent;
        }
        field(16; "Remaining Due"; Decimal)
        {
            Caption = 'Remaining Due';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Reservation No.")
        {
            Clustered = true;
        }
        key(RoomDates; "Room No.", "Check-in Date", "Check-out Date")
        {
        }
    }

    trigger OnInsert()
    begin
        if Status = Status::Closed then
            Error('New reservations cannot be closed.');
        ValidateDates();
    end;

    trigger OnModify()
    begin
        ValidateDates();
    end;

    procedure ValidateDates()
    begin
        if ("Check-in Date" <> 0D) and ("Check-out Date" <> 0D) then
            if "Check-out Date" <= "Check-in Date" then
                Error('Check-out date must be later than check-in date.');
    end;
}
