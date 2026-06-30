table 50110 "BSB Hotel Setup"
{
    Caption = 'Hotel Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Res. Nos."; Code[20])
        {
            Caption = 'Reservation Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Deposit Required"; Boolean)
        {
            Caption = 'Deposit Required';
        }
        field(4; "Default Deposit %"; Decimal)
        {
            Caption = 'Default Deposit %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
        field(5; "Room G/L Account"; Code[20])
        {
            Caption = 'Room G/L Account';
            TableRelation = "G/L Account";
        }
        field(6; "Service G/L Account"; Code[20])
        {
            Caption = 'Service G/L Account';
            TableRelation = "G/L Account";
        }
        field(7; "Deposit G/L Account"; Code[20])
        {
            Caption = 'Deposit G/L Account';
            TableRelation = "G/L Account";
        }
        field(8; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecord()
    begin
        if not Get() then begin
            Init();
            "Primary Key" := '';
            Insert();
        end;
    end;
}
