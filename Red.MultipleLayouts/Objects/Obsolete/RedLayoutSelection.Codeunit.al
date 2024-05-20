
#pragma warning disable AL0432
codeunit 11310865 "Red Layout Selection"
{
    Permissions = tabledata "Red Layout Selection" = rimd, tabledata "red report layout selection" = rimd;

    [Obsolete('Use "Red Report Layout Selection" instead', '3.0.0.0')]
    procedure SetReportLayoutSelection(RecordVariant: Variant; ReportID: Integer)
    begin
        MoveToTenantLayout(ReportID);
    end;

    [Obsolete('Use "Red Report Layout Selection" instead', '3.1.0.0')]
    procedure SetReportLayoutSelectionReturn(RecordVariant: Variant; ReportID: Integer): Boolean
    begin
        MoveToTenantLayout(ReportID);
    end;

    [Obsolete('Use "Red Report Layout Selection" instead', '3.0.0.0')]
    procedure RunReportWithLayoutSelection(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant): Boolean
    begin
        MoveToTenantLayout(TempReportSelections."Report ID");
    end;

    [Obsolete('Use "Red Report Layout Selection" instead', '3.1.0.0')]
    procedure RunReportWithLayoutSelectionReturn(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant): Boolean
    begin
        MoveToTenantLayout(TempReportSelections."Report ID");
    end;

    [Obsolete('Use "Red Report Layout Selection" instead', '3.1.0.0')]
    procedure SetTempLayoutSelected(NewTempSelectedLayoutCode: Code[20])
    var
        DesignTimeReportSelection: Codeunit "Design-time Report Selection";
    begin
        DesignTimeReportSelection.SetSelectedCustomLayout(NewTempSelectedLayoutCode);
    end;

    internal procedure MoveToTenantLayout(): Boolean
    begin
        exit(MoveToTenantLayout(0, true));
    end;

    internal procedure MoveToTenantLayout(ReportId: Integer): Boolean
    begin
        exit(MoveToTenantLayout(ReportId, false));
    end;

    internal procedure MoveToTenantLayout(ReportId: Integer; SurpressCommit: Boolean): Boolean
    var
        RedLayoutSelection: Record "Red Layout Selection";
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        if ReportId <> 0 then
            RedLayoutSelection.SetRange("Report ID", ReportId);

        if RedLayoutSelection.IsEmpty() then
            exit(true);

        RedReportLayoutSelection.LockTable();
        if RedLayoutSelection.FindSet() then
            repeat
                if CopyFromRedLayoutSelection(RedLayoutSelection) then;
                RedLayoutSelection.Delete();
            until RedLayoutSelection.Next() = 0;

        if not SurpressCommit and GuiAllowed() then
            Commit();

        exit(true);
    end;

    internal procedure CopyFromRedLayoutSelection(RedLayoutSelection: Record "Red Layout Selection"): Boolean
    var
        TenantReportLayout: Record "Tenant Report Layout";
        RedReportLayoutSelection: Record "Red Report Layout Selection";
        RedTenantReportLayout: Codeunit "Red Tenant Report Layout";
        NullGuid: Guid;
    // CannotUpgradeAutomaticallyLbl: Label 'Cannot upgrade %1 %2 automatically', Comment = '%1 = table %2 = layoutscode';
    begin
        if RedLayoutSelection."Custom Report Layout Code" = '' then
            exit(false);

        RedReportLayoutSelection.Init();
        RedReportLayoutSelection."Report ID" := RedLayoutSelection."Report ID";
        RedReportLayoutSelection."Report Selection Usage" := "Report Selection Usage"::RedBlank;
        RedReportLayoutSelection."Table No." := RedLayoutSelection."Table No.";
        RedReportLayoutSelection."Field No." := RedLayoutSelection."Field No.";
        RedReportLayoutSelection."Value" := RedLayoutSelection."Value";
        RedReportLayoutSelection.Default := RedLayoutSelection.Default;
        RedReportLayoutSelection."Line No." := RedReportLayoutSelection.GetNextLineNo(RedReportLayoutSelection."Report ID");
        if not TenantReportLayout.Get(RedReportLayoutSelection."Report ID", RedTenantReportLayout.GetLayoutNameFromCustomLayoutCode(RedLayoutSelection."Custom Report Layout Code"), NullGuid) then
            if not TenantReportLayout.Get(RedReportLayoutSelection."Report ID", RedLayoutSelection."Custom Report Layout Code", NullGuid) then
                exit;
        // Error(CannotUpgradeAutomaticallyLbl, RedLayoutSelection.TableCaption, RedLayoutSelection."Custom Report Layout Code");

        RedReportLayoutSelection.Validate("Layout Name", TenantReportLayout.Name);
        exit(RedReportLayoutSelection.Insert());
    end;
}