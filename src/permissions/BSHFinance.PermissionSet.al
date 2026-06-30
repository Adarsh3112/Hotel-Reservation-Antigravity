permissionset 50151 "BSH Finance"
{
    Assignable = true;
    Caption = 'BSH Finance';
    Permissions =
        tabledata "BSH Hotel Setup" = R,
        tabledata "BSH Room" = R,
        tabledata "BSH Reservation" = RM,
        tabledata "BSH Service Charge" = R,
        tabledata "BSH Payment Entry" = RIMD,
        table "BSH Hotel Setup" = X,
        table "BSH Room" = X,
        table "BSH Reservation" = X,
        table "BSH Service Charge" = X,
        table "BSH Payment Entry" = X,
        page "BSH Reservation List" = X,
        page "BSH Reservation Card" = X,
        page "BSH Service Charges" = X,
        codeunit "BSH Billing Mgt" = X,
        codeunit "BSH Payment Mgt" = X,
        codeunit "BSH Refund Mgt" = X;
}
