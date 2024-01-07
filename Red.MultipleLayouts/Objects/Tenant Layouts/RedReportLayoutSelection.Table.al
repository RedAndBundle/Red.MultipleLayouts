// Copyright [2020] [Red and Bundle]
table 11310864 "Red Report Layout Selection"
{
    DataClassification = CustomerContent;
    Extensible = false;

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
        field(3; "Report Selection Usage"; Enum "Report Selection Usage")
        {
            Caption = 'Report Selection Usage';
            DataClassification = CustomerContent;
            InitValue = RedBlank;
        }
        field(4; "Default"; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateDefault();
            end;
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
            TableRelation = field."No." where(TableNo = field("Table No."));
            ValidateTableRelation = false;
            Caption = 'field No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                CalcFields("field Name");
            end;
        }
        field(8; "field Name"; Text[80])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
        field(9; "Value"; Code[50])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(11; "Layout Name"; Text[250])
        {
            Caption = 'Custom Report Layout';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; "Report Layout Description"; Text[250])
        {
            CalcFormula = Lookup("Tenant Report Layout".Description where(Name = field("Layout Name")));
            Caption = 'Report Layout Description';
            FieldClass = FlowField;
            NotBlank = true;
        }

    }

    keys { key(PK; "Report ID", "Report Selection Usage", "Table No.", "Field No.") { Clustered = true; } }

    var
        MustBeZeroErr: Label '%1 and %2 must be 0.', Comment = '%1 is table no caption %2 = field no caption';
        OnlyOneDefaultErr: Label 'Report %1 can only have one default layout', Comment = '%1 = report name';

    internal procedure MatchRecordVariable(RecRef: RecordRef): Boolean
    var
        RedReportLayoutSelectionMatchRec: Codeunit "Red Layout Selection Match Rec";
    begin
        exit(RedReportLayoutSelectionMatchRec.MatchRecordVariable("Field No.", Value, RecRef));
    end;

    procedure ImportFromFile()
    var
        RedRepLayoutSelectionImp: Codeunit "Red Rep Layout Selection Imp.";
    begin
        RedRepLayoutSelectionImp.Run(Rec);
    end;

    local procedure ValidateDefault()
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        if not Default then
            exit;

        if ("Table No." <> 0) or ("Field No." <> 0) then
            error(MustBeZeroErr, FieldCaption("Table No."), FieldCaption("Field No."));

        RedReportLayoutSelection.SetRange("Report ID", "Report ID");
        RedReportLayoutSelection.SetRange(Default, true);
        if not RedReportLayoutSelection.IsEmpty() then
            Error(OnlyOneDefaultErr, "Report Name");
    end;

    internal procedure LookupReportId()
    var
        AllObjWithCaption: Record "AllObjWithCaption";
        ReportSelections: Record "Report Selections";
        ObjectFilter: Text;
        ObjectFilterLbl: Label '|%1', Comment = '%1 = report id';
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);

        if "Report Selection Usage" <> "Report Selection Usage"::RedBlank then begin
            ReportSelections.SetRange(Usage, "Report Selection Usage");
            if ReportSelections.FindSet() then
                repeat
                    ObjectFilter += StrSubstNo(ObjectFilterLbl, ReportSelections."Report ID");
                until ReportSelections.Next() = 0;

            ObjectFilter := ObjectFilter.TrimStart('|');
            if ObjectFilter <> '' then
                AllObjWithCaption.SetFilter("Object ID", ObjectFilter);
        end;

        if Page.RunModal(Page::"All Objects with Caption", AllObjWithCaption) = ACTION::LookupOK then
            "Report ID" := AllObjWithCaption."Object ID";
    end;

    internal procedure CopyFromRedLayoutSelection(RedLayoutSelection: Record "Red Layout Selection")
    var
        RedTenantReportLayout: Codeunit "Red Tenant Report Layout";
    begin
        Init();
        "Report ID" := RedLayoutSelection."Report ID";
        "Report Selection Usage" := "Report Selection Usage"::RedBlank;
        "Table No." := RedLayoutSelection."Table No.";
        "Field No." := RedLayoutSelection."Field No.";
        "Value" := RedLayoutSelection."Value";
        Default := RedLayoutSelection.Default;
        Validate("Layout Name", RedTenantReportLayout.GetLayoutNameFromCustomLayoutCode(RedLayoutSelection."Custom Report Layout Code"));
        if Insert() then;
    end;
}