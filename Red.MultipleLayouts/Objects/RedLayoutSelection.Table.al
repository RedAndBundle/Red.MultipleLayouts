// Copyright [2020] [Red and Bundle]
table 11310862 "Red Layout Selection"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            ValidateTableRelation = false;
            NotBlank = true;

            trigger OnValidate()
            begin
                CalcFields("Report Name");
            end;
        }
        field(2; "Report Name"; Text[50])
        {
            Caption = 'Report Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = const(Report), "Object ID" = field("Report ID")));
            Editable = false;
        }
        field(3; "Custom Report Layout Code"; Code[20])
        {
            Caption = 'Custom Report Layout Code';
            DataClassification = SystemMetadata;
            TableRelation = "Custom Report Layout" WHERE("Report ID" = FIELD("Report ID"));
        }
        field(4; "Report Layout Description"; Text[250])
        {
            CalcFormula = Lookup("Custom Report Layout".Description WHERE(Code = FIELD("Custom Report Layout Code")));
            Caption = 'Report Layout Description';
            FieldClass = FlowField;
            NotBlank = true;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));

            trigger OnValidate()
            begin
                CalcFields("Table Name");
            end;
        }
        field(6; "Table Name"; Text[50])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }
        field(7; "Field No."; Integer)
        {
            TableRelation = Field."No." where(TableNo = field("Table No."));
            ValidateTableRelation = false;
            Caption = 'Field No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(8; "Field Name"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
        field(9; "Value"; Code[50])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }

    }

    keys { key(PK; "Report ID", "Custom Report Layout Code", "Table No.", "Field No.") { Clustered = true; } }

    procedure MatchRecordVariable(RecRef: RecordRef): Boolean
    var
        RedLayoutSelectionMatchRec: Codeunit "Red Layout Selection Match Rec";
    begin
        exit(RedLayoutSelectionMatchRec.MatchRecordVariable(Rec, RecRef));
    end;

    procedure ImportFromFile()
    var
        RedLayoutSelectionImport: Codeunit "Red Layout Selection Import";
    begin
        RedLayoutSelectionImport.Run(Rec);
    end;
}