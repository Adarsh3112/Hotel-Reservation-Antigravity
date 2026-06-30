table 50107 "Finance Cue Setup"
{
    Caption = 'Finance Cue Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Pending Invoices"; Integer)
        {
            Caption = 'Pending Invoices';
            FieldClass = FlowField;
            CalcFormula = count("Reservation Header" where(
                Status = const(Closed),
                "Invoice No." = const('')));
            Editable = false;
            ToolTip = 'Specifies the number of Closed reservations that do not yet have a Sales Invoice generated.';
        }
        field(3; "Deposits Pending Reconciliation"; Integer)
        {
            Caption = 'Deposits Pending Reconciliation';
            FieldClass = FlowField;
            CalcFormula = count("Reservation Header" where(
                "Deposit Amount" = filter(> 0),
                "Deposit Captured" = const(false)));
            Editable = false;
            ToolTip = 'Specifies the number of reservations that have a Deposit Amount but the deposit has not yet been captured/reconciled.';
        }
        field(4; "Payments Pending"; Integer)
        {
            Caption = 'Payments Pending';
            FieldClass = FlowField;
            CalcFormula = count("Reservation Header" where(
                "Payment Status" = const(Pending)));
            Editable = false;
            ToolTip = 'Specifies the number of reservations with a Pending payment status.';
        }
        field(5; "Failed Payments"; Integer)
        {
            Caption = 'Failed Payments';
            FieldClass = FlowField;
            CalcFormula = count("Reservation Header" where(
                "Payment Status" = const(Failed)));
            Editable = false;
            ToolTip = 'Specifies the number of reservations with a Failed payment status requiring attention.';
        }
        field(6; "Invoiced Reservations"; Integer)
        {
            Caption = 'Invoiced Reservations';
            FieldClass = FlowField;
            CalcFormula = count("Reservation Header" where(
                Status = const(Closed),
                "Invoice No." = filter(<> '')));
            Editable = false;
            ToolTip = 'Specifies the number of Closed reservations that have been invoiced.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecordOrInitialize()
    begin
        if not Get('') then begin
            Init();
            "Primary Key" := '';
            Insert();
        end;
    end;
}
