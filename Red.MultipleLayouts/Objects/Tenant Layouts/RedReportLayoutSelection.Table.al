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
                if ("Table No." = 0) or ("Report ID" <> xRec."Report ID") then
                    SetDefaultTableForReport();
            end;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Report Name"; Text[50])
        {
            Caption = 'Report Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = const(Report), "Object ID" = field("Report ID")));
            Editable = false;
        }
        field(4; "Report Selection Usage"; Enum "Report Selection Usage")
        {
            Caption = 'Report Selection Usage';
            DataClassification = CustomerContent;
            InitValue = RedBlank;
        }
        field(5; "Default"; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateDefault();
            end;
        }
        field(6; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));

            trigger OnValidate()
            begin
                CalcFields("Table Name");
            end;
        }
        field(7; "Table Name"; Text[50])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }
        field(8; "Field No."; Integer)
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
        field(9; "field Name"; Text[80])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
        field(10; "Value"; Text[250])
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
            ObsoleteState = Pending;
            ObsoleteReason = 'Use field "Layout Description" instead';
            Caption = 'Report Layout Description';
            FieldClass = FlowField;
            NotBlank = true;
        }
        field(13; "Layout Description"; Text[250])
        {
            Caption = 'Report Layout Description';
            NotBlank = true;
        }
        field(14; "Runtime Package ID"; Guid)
        {
            Caption = 'Runtime Package ID';
            DataClassification = SystemMetadata;
        }

    }

    keys
    {
        key(PK; "Report ID", "Line No.") { Clustered = true; }
        key(Report; "Report ID", "Report Selection Usage", "Table No.", "Field No.", "Line No.") { Clustered = false; }
    }

    var
        OnlyOneDefaultErr: Label 'Report %1 can only have one default layout', Comment = '%1 = report name';

    internal procedure MatchRecordVariable(RecRef: RecordRef): Boolean
    var
        RedReportLayoutSelectionMatchRec: Codeunit "Red Layout Selection Match Rec";
    begin
        exit(RedReportLayoutSelectionMatchRec.MatchRecordVariable(Rec, RecRef));
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
        ActionableError: Codeunit "Red Actionable Error";
    begin
        if not Default then
            exit;

        // A table filled in automatically from the report, without a field, means nothing on a default row
        if "Field No." = 0 then
            Validate("Table No.", 0);

        RedReportLayoutSelection.SetRange("Report Selection Usage", "Report Selection Usage");
        RedReportLayoutSelection.SetRange("Report ID", "Report ID");
        RedReportLayoutSelection.SetRange(Default, true);
        if not RedReportLayoutSelection.IsEmpty() then
            Error(OnlyOneDefaultErr, "Report Name");

        ActionableError.SetDefaultTableFieldNotEmpty(Rec);
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

        if Page.RunModal(Page::"All Objects with Caption", AllObjWithCaption) <> ACTION::LookupOK then
            exit;

        Validate("Report ID", AllObjWithCaption."Object ID");
    end;

    local procedure SetDefaultTableForReport()
    var
        TenantReportLayout: Codeunit "Red Tenant Report Layout";
        TableNo: Integer;
    begin
        if Default then
            exit;

        TableNo := TenantReportLayout.GetDefaultTableForReport("Report ID");
        if TableNo = "Table No." then
            exit;

        Validate("Table No.", TableNo);
        "Field No." := 0;
        Value := '';
    end;

    internal procedure GetNextLineNo(ReportId: Integer): Integer
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        RedReportLayoutSelection.SetRange("Report ID", ReportId);
        if RedReportLayoutSelection.FindLast() then
            exit(RedReportLayoutSelection."Line No." + 10000);

        exit(10000);
    end;
}