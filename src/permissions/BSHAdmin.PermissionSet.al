permissionset 50152 "BSH Admin"
{
    Assignable = true;
    Caption = 'BSH Admin';
    Permissions =
        tabledata "BSH Hotel Setup" = RIMD,
        tabledata "BSH Room" = RIMD,
        tabledata "BSH Reservation" = RIMD,
        tabledata "BSH Service Charge" = RIMD,
        tabledata "BSH Payment Entry" = RIMD,
        table "BSH Hotel Setup" = X,
        table "BSH Room" = X,
        table "BSH Reservation" = X,
        table "BSH Service Charge" = X,
        table "BSH Payment Entry" = X,
        page "BSH Hotel Setup" = X,
        page "BSH Room List" = X,
        page "BSH Room Card" = X,
        page "BSH Reservation List" = X,
        page "BSH Reservation Card" = X,
        page "BSH Service Charges" = X,
        codeunit "BSH Reservation Mgt" = X;
}
