permissionset 50150 "BSH Front Desk"
{
    Assignable = true;
    Caption = 'BSH Front Desk';
    Permissions =
        tabledata "BSH Room" = R,
        tabledata "BSH Reservation" = RIMD,
        tabledata "BSH Service Charge" = RIMD,
        tabledata "BSH Payment Entry" = RIM,
        table "BSH Room" = X,
        table "BSH Reservation" = X,
        table "BSH Service Charge" = X,
        table "BSH Payment Entry" = X,
        page "BSH Room List" = X,
        page "BSH Reservation List" = X,
        page "BSH Reservation Card" = X,
        page "BSH Service Charges" = X,
        codeunit "BSH Reservation Mgt" = X,
        codeunit "BSH Payment Mgt" = X;
}
