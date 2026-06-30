permissionset 50100 "HOTEL-ADMIN"
{
    Assignable = true;
    Caption = 'Hotel Admin';

    Permissions =
        tabledata "Hotel Room" = RIMD,
        tabledata "Hotel Reservation" = RIMD,
        tabledata "Hotel Service Charge" = RIMD,
        tabledata "Hotel Setup" = RIMD,
        tabledata "Hotel Ledger Entry" = RIMD,
        table "Hotel Room" = X,
        table "Hotel Reservation" = X,
        table "Hotel Service Charge" = X,
        table "Hotel Setup" = X,
        table "Hotel Ledger Entry" = X,
        codeunit "Hotel Lifecycle Mgt." = X,
        codeunit "Hotel Security Mgt." = X,
        page "Hotel Room List" = X,
        page "Hotel Room Card" = X,
        page "Hotel Reservation List" = X,
        page "Hotel Reservation Card" = X,
        page "Hotel Service Charges" = X,
        page "Hotel Setup" = X,
        page "Hotel Ledger Entries" = X;
}

permissionset 50101 "HOTEL-FRONTDESK"
{
    Assignable = true;
    Caption = 'Hotel Front Desk';

    Permissions =
        tabledata "Hotel Room" = RIMD,
        tabledata "Hotel Reservation" = RIMD,
        tabledata "Hotel Service Charge" = RIMD,
        tabledata "Hotel Ledger Entry" = R,
        table "Hotel Room" = X,
        table "Hotel Reservation" = X,
        table "Hotel Service Charge" = X,
        table "Hotel Ledger Entry" = X,
        codeunit "Hotel Lifecycle Mgt." = X,
        codeunit "Hotel Security Mgt." = X,
        page "Hotel Room List" = X,
        page "Hotel Room Card" = X,
        page "Hotel Reservation List" = X,
        page "Hotel Reservation Card" = X,
        page "Hotel Service Charges" = X,
        page "Hotel Ledger Entries" = X;
}

permissionset 50102 "HOTEL-FINANCE"
{
    Assignable = true;
    Caption = 'Hotel Finance';

    Permissions =
        tabledata "Hotel Room" = R,
        tabledata "Hotel Reservation" = RIMD,
        tabledata "Hotel Service Charge" = RIMD,
        tabledata "Hotel Setup" = RIMD,
        tabledata "Hotel Ledger Entry" = RIMD,
        table "Hotel Room" = X,
        table "Hotel Reservation" = X,
        table "Hotel Service Charge" = X,
        table "Hotel Setup" = X,
        table "Hotel Ledger Entry" = X,
        codeunit "Hotel Lifecycle Mgt." = X,
        codeunit "Hotel Security Mgt." = X,
        page "Hotel Room List" = X,
        page "Hotel Room Card" = X,
        page "Hotel Reservation List" = X,
        page "Hotel Reservation Card" = X,
        page "Hotel Service Charges" = X,
        page "Hotel Setup" = X,
        page "Hotel Ledger Entries" = X;
}
