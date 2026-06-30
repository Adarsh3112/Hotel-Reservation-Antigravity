permissionset 50140 "BSB HOTEL FRONT"
{
    Assignable = true;
    Caption = 'Hotel Front Desk';

    Permissions =
        tabledata "BSB Hotel Room" = R,
        tabledata "BSB Hotel Reservation" = RIM,
        tabledata "BSB Hotel Service Line" = RIMD,
        tabledata "BSB Hotel Ledger Entry" = R,
        table "BSB Hotel Room" = X,
        table "BSB Hotel Reservation" = X,
        table "BSB Hotel Service Line" = X,
        table "BSB Hotel Ledger Entry" = X,
        page "BSB Hotel Room List" = X,
        page "BSB Hotel Room Card" = X,
        page "BSB Hotel Res. List" = X,
        page "BSB Hotel Res. Card" = X,
        page "BSB Hotel Service Lines" = X,
        codeunit "BSB Hotel Mgt." = X;
}
