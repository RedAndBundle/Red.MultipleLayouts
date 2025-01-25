table 11310863 "Red Layout Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Multiple Layout Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Commit on Post"; Boolean)
        {
            Caption = 'Commit on Post';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure InitSetup()
    begin
        if Get() then
            exit;

        Init();
        Insert();
        Commit();
    end;
}