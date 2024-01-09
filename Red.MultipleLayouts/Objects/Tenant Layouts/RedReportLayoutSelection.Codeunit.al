codeunit 11310873 "Red Report Layout Selection"
{
    Access = Internal;

    procedure SetTenantReportLayoutSelection(RecordVariant: Variant; ReportID: Integer; Usage: Enum "Report Selection Usage")
    var
        TempCustomReportLayout: Record "Tenant Report Layout" temporary;
        SelectedLayoutCode: Text;
    begin
        if not GetLayoutsFromLayoutSelection(TempCustomReportLayout, RecordVariant, ReportID, Usage) then
            if not GetDefaultLayoutForReport(TempCustomReportLayout, ReportID, Usage) then begin
                if not GetTempCustomReportLayout(TempCustomReportLayout, ReportID) then
                    exit;

                GetSelectedLayoutCode(ReportID, SelectedLayoutCode);

                if SelectedLayoutCode = '' then
                    AddDefaultLayoutToList(TempCustomReportLayout, ReportID);
            end;

        SetTempTenantLayoutSelected(SelectLayout(TempCustomReportLayout));
    end;

    [Obsolete('Use with var UsedLayoutCode', '3.0.0.0')]
    procedure RunReportWithLayoutSelection(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant): Boolean
    var
        UsedLayoutCode: Text;
    begin
        RunReportWithTenantLayoutSelection(TempReportSelections, IsGUI, RecordVariant, UsedLayoutCode);
        exit(UsedLayoutCode <> '');
    end;

    procedure RunReportWithTenantLayoutSelection(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant; var UsedLayoutCode: Text)
    var
        TempCustomReportLayout: Record "Tenant Report Layout" temporary;
        SelectedLayoutCode: Text;
    begin
        if not GetLayoutsFromLayoutSelection(TempCustomReportLayout, RecordVariant, TempReportSelections."Report ID", TempReportSelections.Usage) then
            if not GetDefaultLayoutForReport(TempCustomReportLayout, TempReportSelections."Report ID", TempReportSelections.Usage) then begin
                if not GetTempCustomReportLayout(TempCustomReportLayout, TempReportSelections."Report ID") then
                    exit;

                GetSelectedLayoutCode(TempReportSelections."Report ID", SelectedLayoutCode);

                if SelectedLayoutCode = '' then
                    AddDefaultLayoutToList(TempCustomReportLayout, TempReportSelections."Report ID");
            end;

        UsedLayoutCode := SelectLayout(TempCustomReportLayout);
        RunReportWithSelectedLayout(TempReportSelections, IsGUI, RecordVariant, UsedLayoutCode);
    end;

    local procedure GetLayoutsFromLayoutSelection(var TempCustomReportLayout: Record "Tenant Report Layout"; RecordVariant: Variant; ReportId: Integer; Usage: Enum "Report Selection Usage") Success: Boolean
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecordVariant);
        RedReportLayoutSelection.SetRange("Report ID", ReportId);
        RedReportLayoutSelection.SetRange("Table No.", RecRef.Number);
        RedReportLayoutSelection.SetFilter("Field No.", '>0');
        RedReportLayoutSelection.SetFilter("Layout Name", '<>%1', '');
        RedReportLayoutSelection.SetRange("Report Selection Usage", Usage);
        if not RedReportLayoutSelection.FindSet() then begin
            RedReportLayoutSelection.SetRange("Report Selection Usage");
            if not RedReportLayoutSelection.FindSet() then
                exit;
        end;

        repeat
            if RedReportLayoutSelection.MatchRecordVariable(RecRef) then
                Success := AddLayoutSelectionToTempCustomReportLayout(TempCustomReportLayout, RedReportLayoutSelection."Layout Name", ReportId);
        until RedReportLayoutSelection.Next() = 0;
    end;

    local procedure GetDefaultLayoutForReport(var TempCustomReportLayout: Record "Tenant Report Layout"; ReportId: Integer; Usage: Enum "Report Selection Usage"): Boolean
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        RedReportLayoutSelection.SetRange("Report ID", ReportId);
        RedReportLayoutSelection.SetRange(Default, true);
        RedReportLayoutSelection.SetFilter("Layout Name", '<>%1', '');
        RedReportLayoutSelection.SetRange("Report Selection Usage", Usage);
        if RedReportLayoutSelection.FindFirst() then
            exit(AddLayoutSelectionToTempCustomReportLayout(TempCustomReportLayout, RedReportLayoutSelection."Layout Name", ReportId));

        RedReportLayoutSelection.SetRange("Report Selection Usage");
        if RedReportLayoutSelection.FindFirst() then
            exit(AddLayoutSelectionToTempCustomReportLayout(TempCustomReportLayout, RedReportLayoutSelection."Layout Name", ReportId));

        RedReportLayoutSelection.SetRange("Layout Name");
        if not RedReportLayoutSelection.IsEmpty then
            exit(AddEmptyLayoutToTempCustomReportLayout(TempCustomReportLayout, ReportId));
    end;

    local procedure GetTempCustomReportLayout(var TempCustomReportLayout: Record "Tenant Report Layout"; ReportId: Integer): Boolean
    var
        CustomReportLayout: Record "Tenant Report Layout";
    begin
        CustomReportLayout.SetRange("Report ID", ReportId);
        CustomReportLayout.SetFilter("Company Name", '%1|%2', CompanyName, '');
        CustomReportLayout.SetFilter(Description, '<>ForNAV BC preview*');
        CustomReportLayout.SetFilter(Name, '<>@*email*');
        if CustomReportLayout.FindSet() then
            repeat
                TempCustomReportLayout."Report ID" := CustomReportLayout."Report ID";
                TempCustomReportLayout.Name := CustomReportLayout.Name;
                TempCustomReportLayout.Description := CustomReportLayout.Description;
                TempCustomReportLayout."Company Name" := CustomReportLayout."Company Name";
                TempCustomReportLayout.Insert();
            until CustomReportLayout.Next() = 0;

        exit(not TempCustomReportLayout.IsEmpty());
    end;

    local procedure GetSelectedLayoutCode(ReportId: Integer; var SelectedLayoutCode: Text)
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        NullGuid: Guid;
    begin
        if TenantReportLayoutSelection.Get(ReportId, CompanyName, NullGuid) then
            SelectedLayoutCode := TenantReportLayoutSelection."Layout Name";
    end;

    local procedure AddDefaultLayoutToList(var TempCustomReportLayout: Record "Tenant Report Layout"; ReportId: Integer)
    var
        DefaultLayoutMsg: Label 'Default Layout';
    begin
        TempCustomReportLayout.Init();
        TempCustomReportLayout."Report ID" := ReportId;
        TempCustomReportLayout.Name := '';
        TempCustomReportLayout.Description := DefaultLayoutMsg;
        TempCustomReportLayout."Company Name" := CompanyName;
        TempCustomReportLayout.Insert();
    end;

    local procedure AddLayoutSelectionToTempCustomReportLayout(var TempCustomReportLayout: Record "Tenant Report Layout"; CustomReportLayoutCode: Text; ReportId: Integer): Boolean
    var
        CustomReportLayout: Record "Tenant Report Layout";
    begin
        CustomReportLayout.Get(ReportId, CustomReportLayoutCode);
        if not (CustomReportLayout."Company Name" in [CompanyName, '']) then
            exit;

        TempCustomReportLayout."Report ID" := CustomReportLayout."Report ID";
        TempCustomReportLayout.Name := CustomReportLayout.Name;
        TempCustomReportLayout.Description := CustomReportLayout.Description;
        TempCustomReportLayout."Company Name" := CustomReportLayout."Company Name";
        exit(TempCustomReportLayout.Insert());
    end;

    local procedure AddEmptyLayoutToTempCustomReportLayout(var TempCustomReportLayout: Record "Tenant Report Layout"; ReportID: Integer): Boolean
    begin
        TempCustomReportLayout."Report ID" := ReportID;
        exit(TempCustomReportLayout.Insert());
    end;

    local procedure SelectLayout(var TempCustomReportLayout: Record "Tenant Report Layout"): Text
    var
        SelectLayoutErr: Label 'No report layout selected';
    begin
        if not GuiAllowed() then begin
            if TempCustomReportLayout.FindFirst() then
                exit(TempCustomReportLayout.Name);
            exit;
        end;

        if TempCustomReportLayout.Count > 1 then
            if not (Page.RunModal(Page::"Red Report Layouts", TempCustomReportLayout) = ACTION::LookupOK) then
                Error(SelectLayoutErr);

        if TempCustomReportLayout.Find() then
            exit(TempCustomReportLayout.Name);
    end;

    local procedure RunReportWithSelectedLayout(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant; CustomLayout: Text)
    begin
        SetTempTenantLayoutSelected(CustomLayout);
        Report.RunModal(TempReportSelections."Report ID", IsGUI, false, RecordVariant);
        SetTempTenantLayoutSelected('');
    end;

    internal procedure SetTempTenantLayoutSelected(NewTempSelectedLayoutCode: Text)
    var
        DesignTimeReportSelection: Codeunit "Design-time Report Selection";
    begin
        DesignTimeReportSelection.SetSelectedLayout(NewTempSelectedLayoutCode);
    end;
}