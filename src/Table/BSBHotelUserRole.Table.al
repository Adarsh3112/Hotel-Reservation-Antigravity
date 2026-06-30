table 50115 "BSB Hotel User Role"
{
    Caption = 'Hotel User Role';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
        }
        field(2; Role; Enum "BSB Hotel User Role")
        {
            Caption = 'Role';
        }
    }

    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
    }
}
