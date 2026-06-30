permissionset 50141 "BSB HOTEL FINANCE"
{
    Assignable = true;
    Caption = 'Hotel Finance';

    Permissions =
        tabledata "BSB Hotel Setup" = R,
        tabledata "BSB Hotel Room" = R,
        tabledata "BSB Hotel Reservation" = RIM,
        tabledata "BSB Hotel Service Line" = R,
        tabledata "BSB Hotel Ledger Entry" = RIM,
        tabledata "BSB Hotel User Role" = R,
        table "BSB Hotel Setup" = X,
        table "BSB Hotel Room" = X,
        table "BSB Hotel Reservation" = X,
        table "BSB Hotel Service Line" = X,
        table "BSB Hotel Ledger Entry" = X,
        table "BSB Hotel User Role" = X,
        page "BSB Hotel Setup" = X,
        page "BSB Hotel Finance Res." = X,
        page "BSB Hotel Ledger Entries" = X,
        codeunit "BSB Hotel Mgt." = X,
        codeunit "BSB Hotel Refund Mgt." = X;
}
