page 50105 "Hotel Setup"
{
    Caption = 'Hotel Setup';
    PageType = Card;
    SourceTable = "Hotel Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Reservation Nos."; Rec."Reservation Nos.")
                {
                    ApplicationArea = All;
                    // Front Desk users have only R on Hotel Setup; this field is
                    // editable only for Finance/Admin who hold MODIFY permission.
                    Editable = HasFinancePermission;
                    ToolTip = 'Specifies the No. Series used to assign Reservation numbers.';
                }
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';

                field("Room Charge Item No."; Rec."Room Charge Item No.")
                {
                    ApplicationArea = All;
                    Editable = HasFinancePermission;
                    ToolTip = 'Specifies the Item No. used as the Sales Line item for room charges when generating a Sales Invoice.';
                }
                field("Service Charge Item No."; Rec."Service Charge Item No.")
                {
                    ApplicationArea = All;
                    Editable = HasFinancePermission;
                    ToolTip = 'Specifies the Item No. used as the Sales Line item for service charges when generating a Sales Invoice.';
                }
                field("Deposit Item No."; Rec."Deposit Item No.")
                {
                    ApplicationArea = All;
                    Editable = HasFinancePermission;
                    ToolTip = 'Specifies the Item No. used as the Sales Line item for deposit credits when generating a Sales Invoice.';
                }
            }
            group(VATPostingGroups)
            {
                Caption = 'VAT / Posting Groups';

                field("Default Room VAT %"; Rec."Default Room VAT %")
                {
                    ApplicationArea = All;
                    Editable = HasFinancePermission;
                    ToolTip = 'Specifies the default VAT percentage applied to room charges. Used as the fallback rate when no VAT Product Posting Group override is present. Changing this value will trigger recalculation of VAT on all un-invoiced reservations.';

                    trigger OnValidate()
                    begin
                        // Track that a VAT-relevant field was modified on this page
                        // session so the SaveSetup action can warn appropriately.
                        VATSetupModifiedOnPage := true;
                    end;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = HasFinancePermission;
                    ToolTip = 'Specifies the General Product Posting Group applied to hotel charge Sales Lines. Front Desk users may view but not change this setting.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = HasFinancePermission;
                    ToolTip = 'Specifies the VAT Product Posting Group applied to hotel charge Sales Lines. Changing this value will trigger recalculation of VAT on all un-invoiced reservations. Front Desk users may view but not change this setting.';

                    trigger OnValidate()
                    begin
                        // Track that a VAT-relevant field was modified on this page
                        // session so the SaveSetup action can warn appropriately.
                        VATSetupModifiedOnPage := true;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SaveSetup)
            {
                Caption = 'Save Setup';
                ApplicationArea = All;
                Image = Save;
                // AccessByPermission: only HOTEL-FINANCE / HOTEL-ADMIN may save changes.
                AccessByPermission = tabledata "Hotel Setup" = M;
                ToolTip = 'Save the current Hotel Setup configuration. When VAT-related fields (VAT Prod. Posting Group or Default Room VAT %%) have been changed a warning is shown and VAT is recalculated on all un-invoiced reservations. Restricted to HOTEL-FINANCE and HOTEL-ADMIN users.';

                trigger OnAction()
                var
                    HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
                    HotelVATCalculation: Codeunit "Hotel VAT Calculation";
                    UpdatedCount: Integer;
                begin
                    // Code-level guard: Front Desk users receive an explicit error.
                    HotelPermissionMgt.CheckTaxSetupPermission();

                    // When the user has changed a VAT-relevant field during this
                    // page session, warn them that un-invoiced reservations will be
                    // recalculated and give them the option to cancel.
                    if VATSetupModifiedOnPage then begin
                        if not Confirm(
                            'You have changed VAT setup fields (VAT Prod. Posting Group and/or Default Room VAT %%).\\' +
                            'Saving will trigger a recalculation of VAT on all un-invoiced reservations.\\' +
                            'Do you want to save and recalculate now?',
                            true)
                        then begin
                            // User chose not to proceed — discard in-page changes.
                            CurrPage.Update(false);
                            Error('VAT setup change was not saved. No reservations were updated.');
                        end;
                    end;

                    // Persist the record; OnModify on the table will also fire the
                    // bulk recalculation and display a confirmation message when it
                    // detects VAT field changes.
                    Rec.Modify(true);
                    VATSetupModifiedOnPage := false;

                    if (Rec."VAT Prod. Posting Group" = xRec."VAT Prod. Posting Group") and
                       (Rec."Default Room VAT %" = xRec."Default Room VAT %") 
                    then
                        Message('Hotel Setup has been saved successfully.');
                end;
            }
            action(RecalculateAllVAT)
            {
                Caption = 'Recalculate VAT on All Reservations';
                ApplicationArea = All;
                Image = Calculate;
                // AccessByPermission: only HOTEL-FINANCE / HOTEL-ADMIN may run this.
                AccessByPermission = tabledata "Hotel Setup" = M;
                ToolTip = 'Manually triggers a recalculation of VAT on all un-invoiced reservations using the current VAT setup. Use this after changing VAT configuration outside of the Hotel Setup page.';

                trigger OnAction()
                var
                    HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
                    HotelVATCalculation: Codeunit "Hotel VAT Calculation";
                    UpdatedCount: Integer;
                begin
                    HotelPermissionMgt.CheckTaxSetupPermission();

                    if not Confirm(
                        'This will recalculate VAT on all un-invoiced reservations using the current VAT setup.\\' +
                        'Do you want to continue?',
                        true)
                    then
                        exit;

                    UpdatedCount := HotelVATCalculation.BulkRecalcUnInvoicedReservations();

                    Message(
                        'VAT recalculation complete.\\' +
                        '%1 un-invoiced reservation(s) have been updated.',
                        UpdatedCount);
                end;
            }
        }
        area(Promoted)
        {
            actionref(SaveSetup_Promoted; SaveSetup) { }
            actionref(RecalculateAllVAT_Promoted; RecalculateAllVAT) { }
        }
    }

    trigger OnOpenPage()
    begin
        // Singleton pattern: ensure exactly one record exists before the page renders.
        Rec.GetRecordOnce();
        // Evaluate Finance permission once when the page opens so the
        // Editable expressions on fields are resolved from a page variable.
        HasFinancePermission    := FinancePermissionCheck();
        VATSetupModifiedOnPage  := false;
    end;

    trigger OnAfterGetRecord()
    begin
        HasFinancePermission := FinancePermissionCheck();
    end;

    var
        HasFinancePermission   : Boolean;
        /// <summary>
        /// Tracks whether the user has modified a VAT-relevant field (VAT Prod.
        /// Posting Group or Default Room VAT %%) during the current page session.
        /// Set to TRUE in the OnValidate triggers of those fields; reset to FALSE
        /// after SaveSetup completes or when the page re-opens.
        /// </summary>
        VATSetupModifiedOnPage : Boolean;

    local procedure FinancePermissionCheck(): Boolean
    var
        HotelPermissionMgt: Codeunit "Hotel Permission Mgt";
    begin
        exit(HotelPermissionMgt.HasFinancePermission());
    end;
}
