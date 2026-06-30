codeunit 50105 "Hotel Permission Mgt"
{
    /// <summary>
    /// Centralized permission-check helper for the Hotel extension.
    /// All financial-action guards call into this codeunit so that
    /// enforcement is consistent regardless of the UI entry point.
    ///
    /// Role model:
    ///   HOTEL-ADMIN     – full access to everything
    ///   HOTEL-FINANCE   – may execute financial actions (refunds, invoicing,
    ///                     tax recalculation, Hotel Setup modifications)
    ///   HOTEL-FRONTDESK – operational tasks only (check-in, check-out,
    ///                     service charges); blocked from financial actions
    ///
    /// Detection strategy:
    ///   We test whether the current user has MODIFY permission on the
    ///   "Hotel Setup" table (tabledata).  HOTEL-FINANCE and HOTEL-ADMIN
    ///   are the only permission sets that grant this, so a positive result
    ///   means "Finance or Admin" — the only roles allowed to perform
    ///   financial actions.  Front-Desk users have only READ (R) on that
    ///   table and will therefore fail the test.
    /// </summary>

    /// <summary>
    /// Returns TRUE when the current user holds a Finance-level or
    /// Admin-level permission set (i.e. has MODIFY on "Hotel Setup").
    /// </summary>
    procedure HasFinancePermission(): Boolean
    var
        HotelSetup: Record "Hotel Setup";
    begin
        exit(HotelSetup.WritePermission());
    end;

    /// <summary>
    /// Raises an error and blocks execution when the calling user does NOT
    /// hold the HOTEL-FINANCE or HOTEL-ADMIN permission set.
    /// Call this at the start of every financial action trigger:
    ///   - Refund / deposit reversal actions
    ///   - Generate Invoice
    ///   - Recalculate Tax
    ///   - Any direct modification of Hotel Setup fields
    /// </summary>
    procedure CheckFinancePermission()
    begin
        if not HasFinancePermission() then
            Error(
                'Access denied.\\' +
                'Only users with the ''HOTEL-FINANCE'' or ''HOTEL-ADMIN'' permission set ' +
                'are authorised to perform financial actions (refunds, invoicing, tax recalculation).\\' +
                'Please contact your system administrator.');
    end;

    /// <summary>
    /// Returns TRUE when the current user has INSERT permission on the
    /// "Hotel Setup" table, which is granted exclusively to HOTEL-ADMIN.
    /// HOTEL-FINANCE users have RIMD (Insert included) in the updated
    /// permission set, so this check now targets full RIMD (Delete) as
    /// the Admin-exclusive indicator instead — specifically, Delete on Room.
    /// </summary>
    procedure HasAdminPermission(): Boolean
    var
        HotelSetup: Record "Hotel Setup";
        Room: Record Room;
    begin
        // AL does not have a specific DeletePermission method on the Record variable.
        // In this extension's permission model:
        // - HOTEL-ADMIN has Write (RIMD) on both Room and Hotel Setup.
        // - HOTEL-FINANCE has Write on Hotel Setup but only Read on Room.
        // - HOTEL-FRONTDESK has Write on Room but only Read on Hotel Setup.
        // Therefore, having WritePermission on both tables uniquely identifies the Admin.
        exit(HotelSetup.WritePermission() and Room.WritePermission());
    end;

    /// <summary>
    /// Raises an error when the current user does not hold the
    /// HOTEL-ADMIN permission set.
    /// </summary>
    procedure CheckAdminPermission()
    begin
        if not HasAdminPermission() then
            Error(
                'Access denied.\\' +
                'Only users with the ''HOTEL-ADMIN'' permission set are authorised ' +
                'to perform administrative actions.\\' +
                'Please contact your system administrator.');
    end;

    /// <summary>
    /// Dedicated guard for refund/deposit-reversal actions.
    /// Produces a targeted error message that specifically mentions
    /// the refund context so the user understands why they are blocked.
    /// </summary>
    procedure CheckRefundPermission()
    begin
        if not HasFinancePermission() then
            Error(
                'Access denied.\\' +
                'Processing refunds is restricted to users with the ''HOTEL-FINANCE'' ' +
                'or ''HOTEL-ADMIN'' permission set.\\' +
                'Front Desk users are not authorised to process refunds.\\' +
                'Please contact your Finance department.');
    end;

    /// <summary>
    /// Dedicated guard for Tax Setup modifications.
    /// Front Desk users (HOTEL-FRONTDESK) have read-only access to
    /// Hotel Setup and must not be able to change VAT/posting group
    /// configuration.
    /// </summary>
    procedure CheckTaxSetupPermission()
    begin
        if not HasFinancePermission() then
            Error(
                'Access denied.\\' +
                'Modifying Tax / VAT setup is restricted to users with the ''HOTEL-FINANCE'' ' +
                'or ''HOTEL-ADMIN'' permission set.\\' +
                'Front Desk users are not authorised to change Tax setup.\\' +
                'Please contact your Finance department.');
    end;
}
