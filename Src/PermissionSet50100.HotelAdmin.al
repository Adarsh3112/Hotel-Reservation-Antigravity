permissionset 50100 "HOTEL-ADMIN"
{
    Caption = 'Hotel Admin';
    Assignable = true;

    Permissions =
        tabledata "Room" = RIMD,
        table "Room" = X,
        page "Room List" = X,
        page "Room Card" = X,
        tabledata "Hotel Setup" = RIMD,
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
        codeunit "Generate Hotel Invoice" = X,
        codeunit "Hotel VAT Calculation" = X,
        codeunit "Hotel Permission Mgt" = X,
        codeunit "Process Refund" = X,
        page "Room Lookup" = X;
}
