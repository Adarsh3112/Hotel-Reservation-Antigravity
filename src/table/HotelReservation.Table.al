table 50101 "Hotel Reservation"
{
    DataClassification = CustomerContent;
    Caption = 'Hotel Reservation';
    LookupPageId = "Hotel Reservation List";
    DrillDownPageId = "Hotel Reservation List";

    fields
    {
        field(1; "Reservation No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reservation No.';
            NotBlank = true;
        }
        field(2; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(3; "Room No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Room No.';
            TableRelation = "Hotel Room" where(Occupied = const(false));

            trigger OnValidate()
            var
                HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
            begin
                HotelLifecycleMgt.CheckRoomAvailability("Room No.", "Check-in Date", "Check-out Date", "Reservation No.");
            end;
        }
        field(4; "Check-in Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Check-in Date';

            trigger OnValidate()
            var
                HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
            begin
                if ("Check-in Date" <> 0D) and ("Check-out Date" <> 0D) and ("Check-in Date" >= "Check-out Date") then
                    Error('Check-in Date must be before Check-out Date.');

                HotelLifecycleMgt.CheckRoomAvailability("Room No.", "Check-in Date", "Check-out Date", "Reservation No.");
            end;
        }
        field(5; "Check-out Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Check-out Date';

            trigger OnValidate()
            var
                HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
            begin
                if ("Check-in Date" <> 0D) and ("Check-out Date" <> 0D) and ("Check-in Date" >= "Check-out Date") then
                    Error('Check-in Date must be before Check-out Date.');

                HotelLifecycleMgt.CheckRoomAvailability("Room No.", "Check-in Date", "Check-out Date", "Reservation No.");
            end;
        }
        field(6; Status; Enum "Hotel Reservation Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(7; "Deposit Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Deposit Amount';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
        }
        field(8; "Deposit Paid"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Deposit Paid';
        }
        field(9; "Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Invoice No.';
            Editable = false;
        }
        field(10; Invoiced; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Invoiced';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Reservation No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Check-in Date" = 0D then
            "Check-in Date" := WorkDate();
        if "Check-out Date" = 0D then
            "Check-out Date" := WorkDate() + 1;
    end;
}
