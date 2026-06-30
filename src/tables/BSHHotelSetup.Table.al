table 50110 "BSH Hotel Setup"
{
    Caption = 'BSH Hotel Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "VAT Percent"; Decimal)
        {
            Caption = 'VAT Percent';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(3; "Room Nos."; Code[20])
        {
            Caption = 'Room Nos.';
            DataClassification = CustomerContent;
        }
        field(4; "Reservation Nos."; Code[20])
        {
            Caption = 'Reservation Nos.';
            DataClassification = CustomerContent;
        }
        field(5; "Deposit Item No."; Code[20])
        {
            Caption = 'Deposit Item No.';
            DataClassification = CustomerContent;
        }
        field(6; "Service Item No."; Code[20])
        {
            Caption = 'Service Item No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup()
    begin
        if not Get('HOTEL') then begin
            Init();
            "Primary Key" := 'HOTEL';
            "VAT Percent" := 0;
            Insert(true);
        end;
    end;
}
