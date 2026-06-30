codeunit 50102 "Hotel Security Mgt."
{
    SingleInstance = true;

    var
        MockRole: Code[20];
        IsMocking: Boolean;

    procedure SetMockRole(Role: Code[20])
    begin
        MockRole := Role;
        IsMocking := true;
    end;

    procedure ClearMockRole()
    begin
        IsMocking := false;
    end;

    procedure CheckFinancePermission()
    var
        AccessControl: Record "Access Control";
    begin
        if IsMocking then begin
            if (MockRole <> 'HOTEL-FINANCE') and (MockRole <> 'HOTEL-ADMIN') then
                Error('Only Finance or Admin users are authorized to perform this action.');
            exit;
        end;

        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetFilter("Role ID", '%1|%2', 'HOTEL-FINANCE', 'HOTEL-ADMIN');
        if AccessControl.IsEmpty() then
            Error('Only Finance or Admin users are authorized to perform this action.');
    end;
}
