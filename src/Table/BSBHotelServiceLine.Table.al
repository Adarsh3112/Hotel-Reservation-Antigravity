table 50113 "BSB Hotel Service Line"
{
    Caption = 'Hotel Service Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reservation No."; Code[20])
        {
            Caption = 'Reservation No.';
            TableRelation = "BSB Hotel Reservation";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Service Type"; Enum "BSB Hotel Service Type")
        {
            Caption = 'Service Type';
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(6; Billable; Boolean)
        {
            Caption = 'Billable';
            InitValue = true;
        }
        field(7; Posted; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Reservation No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Line No." = 0 then
            "Line No." := NextLineNo();
        TestField("Reservation No.");
        if Description = '' then
            Description := Format("Service Type");
    end;

    local procedure NextLineNo(): Integer
    var
        ServiceLine: Record "BSB Hotel Service Line";
    begin
        ServiceLine.SetRange("Reservation No.", "Reservation No.");
        if ServiceLine.FindLast() then
            exit(ServiceLine."Line No." + 10000);
        exit(10000);
    end;
}
