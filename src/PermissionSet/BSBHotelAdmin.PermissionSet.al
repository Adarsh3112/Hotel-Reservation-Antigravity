permissionset 50142 "BSB HOTEL ADMIN"
{
    Assignable = true;
    Caption = 'Hotel Admin';

    Permissions =
        tabledata "BSB Hotel Setup" = RIMD,
        tabledata "BSB Hotel Room" = RIMD,
        tabledata "BSB Hotel Reservation" = RIMD,
        tabledata "BSB Hotel Service Line" = RIMD,
        tabledata "BSB Hotel Ledger Entry" = RIMD,
        tabledata "BSB Hotel User Role" = RIMD,
        table "BSB Hotel Setup" = X,
        table "BSB Hotel Room" = X,
        table "BSB Hotel Reservation" = X,
        table "BSB Hotel Service Line" = X,
        table "BSB Hotel Ledger Entry" = X,
        table "BSB Hotel User Role" = X,
        page "BSB Hotel Setup" = X,
        page "BSB Hotel Room List" = X,
        page "BSB Hotel Room Card" = X,
        page "BSB Hotel Res. List" = X,
        page "BSB Hotel Res. Card" = X,
        page "BSB Hotel Service Lines" = X,
        page "BSB Hotel Ledger Entries" = X,
        page "BSB Hotel User Roles" = X,
        page "BSB Hotel Finance Res." = X,
        codeunit "BSB Hotel Mgt." = X,
        codeunit "BSB Hotel Refund Mgt." = X;
}
