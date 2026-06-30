permissionset 50101 "HOTEL-FRONTDESK"
{
    Caption = 'Hotel Front Desk';
    Assignable = true;

    // NOTE: 'Process Refund' codeunit is intentionally excluded from this
    // permission set.  Front Desk users are operationally blocked from
    // executing refunds:
    //   - The 'Process Refund' page action carries
    //       AccessByPermission = tabledata "Hotel Setup" = M
    //     which this role does not hold (only R), so the action is hidden.
    //   - Codeunit "Process Refund" is not listed here, so even a direct
    //     codeunit execution attempt will be denied by BC's permission system.
    //   - The codeunit itself calls HotelPermissionMgt.CheckRefundPermission()
    //     as a code-level guard, providing a third enforcement layer.
    Permissions =
        tabledata "Room" = RIM,
        table "Room" = X,
        page "Room List" = X,
        page "Room Card" = X,
        tabledata "Hotel Setup" = R,
        table "Hotel Setup" = X,
        page "Hotel Setup" = X,
        tabledata "Reservation Header" = RIMD,
        table "Reservation Header" = X,
        page "Reservation List" = X,
        page "Reservation Card" = X,
        tabledata "Reservation Service Charge" = RIMD,
        table "Reservation Service Charge" = X,
        page "Reservation Service Charges" = X,
        codeunit "Hotel Reservation Mgt" = X,
        codeunit "Reservation Check-In" = X,
        codeunit "Reservation Check-Out" = X,
        codeunit "Hotel Permission Mgt" = X,
        page "Room Lookup" = X,
        tabledata "Front Desk Cue Setup" = RIMD,
        table "Front Desk Cue Setup" = X,
        page "Hotel Front Desk Role Center" = X,
        page "Hotel Front Desk Cues" = X;
}
