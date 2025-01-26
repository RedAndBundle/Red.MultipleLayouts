codeunit 11310873 "Red Report Layout Selection"
{
    Access = Internal;

    procedure SetTenantReportLayoutSelection(RecordVariant: Variant; ReportID: Integer; Usage: Enum "Report Selection Usage")
    var
        TempTenantReportLayout: Record "Tenant Report Layout" temporary;
        SelectedLayoutCode: Text;
    begin
        if not GetLayoutsFromLayoutSelection(TempTenantReportLayout, RecordVariant, ReportID, Usage) then
            if not GetDefaultLayoutForReport(TempTenantReportLayout, ReportID, Usage) then begin
                if not GetTempCustomReportLayout(TempTenantReportLayout, ReportID) then
                    exit;

                GetSelectedLayoutCode(ReportID, SelectedLayoutCode);

                if SelectedLayoutCode = '' then
                    AddBuiltInLayoutToList(TempTenantReportLayout, ReportID);
            end;

        SetTempTenantLayoutSelected(SelectLayout(TempTenantReportLayout));
    end;

    procedure RunReportWithTenantLayoutSelection(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant; var UsedLayoutCode: Text)
    var
        TempTenantReportLayout: Record "Tenant Report Layout" temporary;
        TenantReportLayout: Record "Tenant Report Layout";
        SelectedLayoutCode: Text;
    begin
        if not GetLayoutsFromLayoutSelection(TempTenantReportLayout, RecordVariant, TempReportSelections."Report ID", TempReportSelections.Usage) then
            if not GetDefaultLayoutForReport(TempTenantReportLayout, TempReportSelections."Report ID", TempReportSelections.Usage) then begin
                if not GetTempCustomReportLayout(TempTenantReportLayout, TempReportSelections."Report ID") then
                    exit;

                GetSelectedLayoutCode(TempReportSelections."Report ID", SelectedLayoutCode);

                if SelectedLayoutCode = '' then
                    AddBuiltInLayoutToList(TempTenantReportLayout, TempReportSelections."Report ID");
            end;

        TenantReportLayout := SelectLayout(TempTenantReportLayout);
        RunReportWithSelectedLayout(TempReportSelections, IsGUI, RecordVariant, TenantReportLayout);
        UsedLayoutCode := TenantReportLayout.Name;
    end;

    local procedure GetLayoutsFromLayoutSelection(var TempTenantReportLayout: Record "Tenant Report Layout"; RecordVariant: Variant; ReportId: Integer; Usage: Enum "Report Selection Usage") Success: Boolean
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecordVariant);
        RedReportLayoutSelection.SetRange("Report ID", ReportId);
        RedReportLayoutSelection.SetRange("Table No.", RecRef.Number);
        RedReportLayoutSelection.SetFilter("Field No.", '>0');
        RedReportLayoutSelection.SetFilter("Layout Name", '<>%1', '');
        RedReportLayoutSelection.SetFilter("Report Selection Usage", '%1|%2', Usage, Usage::RedBlank);
        if RedReportLayoutSelection.FindSet() then
            repeat
                if RedReportLayoutSelection.MatchRecordVariable(RecRef) then
                    Success := AddLayoutSelectionToTempCustomReportLayout(TempTenantReportLayout, RedReportLayoutSelection);
            until RedReportLayoutSelection.Next() = 0;
    end;

    local procedure GetDefaultLayoutForReport(var TempTenantReportLayout: Record "Tenant Report Layout"; ReportId: Integer; Usage: Enum "Report Selection Usage"): Boolean
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        RedReportLayoutSelection.SetRange("Report ID", ReportId);
        RedReportLayoutSelection.SetRange(Default, true);
        RedReportLayoutSelection.SetFilter("Layout Name", '<>%1', '');
        RedReportLayoutSelection.SetRange("Report Selection Usage", Usage);
        if RedReportLayoutSelection.FindFirst() then
            exit(AddLayoutSelectionToTempCustomReportLayout(TempTenantReportLayout, RedReportLayoutSelection));

        RedReportLayoutSelection.SetRange("Report Selection Usage", Usage::RedBlank);
        if RedReportLayoutSelection.FindFirst() then
            exit(AddLayoutSelectionToTempCustomReportLayout(TempTenantReportLayout, RedReportLayoutSelection));

        RedReportLayoutSelection.SetFilter("Report Selection Usage", '%1|%2', Usage, Usage::RedBlank);
        RedReportLayoutSelection.SetRange("Layout Name");
        if not RedReportLayoutSelection.IsEmpty then
            exit(AddEmptyLayoutToTempCustomReportLayout(TempTenantReportLayout, ReportId));
    end;

    local procedure GetTempCustomReportLayout(var TempTenantReportLayout: Record "Tenant Report Layout"; ReportId: Integer): Boolean
    var
        TenantReportLayout: Record "Tenant Report Layout";
    begin
        TenantReportLayout.SetRange("Report ID", ReportId);
        TenantReportLayout.SetFilter("Company Name", '%1|%2', CompanyName, '');
        TenantReportLayout.SetFilter(Description, '<>ForNAV BC preview*');
        TenantReportLayout.SetFilter(Name, '<>@*email*');
        if TenantReportLayout.FindSet() then
            repeat
                TempTenantReportLayout."Report ID" := TenantReportLayout."Report ID";
                TempTenantReportLayout.Name := TenantReportLayout.Name;
                TempTenantReportLayout.Description := TenantReportLayout.Description;
                TempTenantReportLayout."Company Name" := TenantReportLayout."Company Name";
                TenantReportLayout."App ID" := TenantReportLayout."App ID";
                TempTenantReportLayout.Insert();
            until TenantReportLayout.Next() = 0;

        exit(not TempTenantReportLayout.IsEmpty());
    end;

    local procedure GetSelectedLayoutCode(ReportId: Integer; var SelectedLayoutCode: Text)
    var
        DesignTimeReportSelection: Record "Tenant Report Layout Selection";
        NullGuid: Guid;
    begin
        if DesignTimeReportSelection.Get(ReportId, CompanyName, NullGuid) then
            SelectedLayoutCode := DesignTimeReportSelection."Layout Name";
    end;

    procedure AddBuiltInLayoutToList(var TempTenantReportLayout: Record "Tenant Report Layout"; ReportId: Integer)
    var
        ReportLayoutList: Record "Report Layout List";
        NullGuid: Guid;
    begin
        ReportLayoutList.SetFilter("Application ID", '<>%1', NullGuid);
        ReportLayoutList.SetRange("Report ID", ReportId);
        if ReportLayoutList.FindSet() then
            repeat
                TempTenantReportLayout.Init();
                TempTenantReportLayout."Report ID" := ReportLayoutList."Report ID";
                TempTenantReportLayout.Name := ReportLayoutList.Name;
                TempTenantReportLayout.Description := RemoveFilenamePath(ReportLayoutList.Description);
                TempTenantReportLayout."App ID" := ReportLayoutList."Runtime Package ID";
                TempTenantReportLayout."Company Name" := CompanyName;
                TempTenantReportLayout.Insert();
            until ReportLayoutList.Next() = 0;
    end;

    local procedure AddLayoutSelectionToTempCustomReportLayout(var TempTenantReportLayout: Record "Tenant Report Layout"; RedReportLayoutSelection: Record "Red Report Layout Selection"): Boolean
    var
        ReportLayoutList: Record "Report Layout List";
        TenantReportLayout: Record "Tenant Report Layout";
    begin
        if IsNullGuid(RedReportLayoutSelection."Runtime Package ID") then begin
            TenantReportLayout.Get(RedReportLayoutSelection."Report ID", RedReportLayoutSelection."Layout Name");
            if not (TenantReportLayout."Company Name" in [CompanyName, '']) then
                exit;

            TempTenantReportLayout."Report ID" := TenantReportLayout."Report ID";
            TempTenantReportLayout.Name := TenantReportLayout.Name;
            TempTenantReportLayout.Description := TenantReportLayout.Description;
            TempTenantReportLayout."Company Name" := TenantReportLayout."Company Name";
            exit(TempTenantReportLayout.Insert());
        end;

        ReportLayoutList.Get(RedReportLayoutSelection."Report ID", RedReportLayoutSelection."Layout Name", RedReportLayoutSelection."Runtime Package ID");

        TempTenantReportLayout."Report ID" := ReportLayoutList."Report ID";
        TempTenantReportLayout.Name := ReportLayoutList.Name;
        TempTenantReportLayout.Description := RemoveFilenamePath(ReportLayoutList.Description);
        TempTenantReportLayout."App ID" := ReportLayoutList."Runtime Package ID";
        exit(TempTenantReportLayout.Insert());
    end;

    local procedure AddEmptyLayoutToTempCustomReportLayout(var TempTenantReportLayout: Record "Tenant Report Layout"; ReportID: Integer): Boolean
    begin
        TempTenantReportLayout."Report ID" := ReportID;
        exit(TempTenantReportLayout.Insert());
    end;

    local procedure SelectLayout(var TempTenantReportLayout: Record "Tenant Report Layout"): Record "Tenant Report Layout"
    var
        Layouts: List of [Text];
        Options: Text;
        Selected: Integer;
        ChooseLayoutQst: Label 'Choose one of these layouts:';
        SelectLayoutErr: Label 'No report layout selected';
    begin
        if not GuiAllowed() then begin
            if TempTenantReportLayout.FindFirst() then
                exit(TempTenantReportLayout);
            exit;
        end;

        case true of
            TempTenantReportLayout.IsEmpty():
                exit;
            not GuiAllowed,
            TempTenantReportLayout.Count = 1:
                begin
                    TempTenantReportLayout.FindFirst();
                    exit(TempTenantReportLayout);
                end;
            IsInWriteTransaction():
                begin
                    TempTenantReportLayout.FindSet();
                    repeat
                        Layouts.Add(TempTenantReportLayout.Name);
                        Options += TempTenantReportLayout.Description + ',';
                    until TempTenantReportLayout.Next() = 0;

                    Selected := Dialog.StrMenu(Options, 1, ChooseLayoutQst);
                    if Selected = 0 then
                        Error(SelectLayoutErr);

                    TempTenantReportLayout.SetRange(Name, Layouts.Get(Selected));
                    TempTenantReportLayout.FindFirst();
                    exit(TempTenantReportLayout);
                end;
        end;

        if not (Page.RunModal(Page::"Red Report Layouts", TempTenantReportLayout) = ACTION::LookupOK) then
            Error(SelectLayoutErr);

        if TempTenantReportLayout.Find() then
            exit(TempTenantReportLayout);
    end;

    local procedure RunReportWithSelectedLayout(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant; TempTenantReportLayout: Record "Tenant Report Layout" temporary)
    begin
        SetTempTenantLayoutSelected(TempTenantReportLayout);
        Report.RunModal(TempReportSelections."Report ID", IsGUI, false, RecordVariant);
        SetTempTenantLayoutSelected('');
    end;

    internal procedure SetTempTenantLayoutSelected(TempTenantReportLayout: Record "Tenant Report Layout" temporary)
    var
        List: Record "Report Layout List";
        DesignTimeReportSelection: Codeunit "Design-time Report Selection";
        NullGuid: Guid;
    begin
        case true of
            not IsNullGuid(TempTenantReportLayout."App ID"):
                begin
                    List.SetFilter("Application ID", '<>%1', NullGuid);
                    List.SetRange(List."Report ID", TempTenantReportLayout."Report ID");
                    List.SetRange(List.Name, TempTenantReportLayout.Name);
                    if List.Get(TempTenantReportLayout."Report ID", TempTenantReportLayout.Name, TempTenantReportLayout."App ID") then
                        DesignTimeReportSelection.SetSelectedLayout(List.Name, List."Application ID");
                end;
            else
                DesignTimeReportSelection.SetSelectedLayout(TempTenantReportLayout.Name);
        end;
    end;

    internal procedure SetTempTenantLayoutSelected(NewTempSelectedLayoutCode: Text)
    var
        DesignTimeReportSelection: Codeunit "Design-time Report Selection";
    begin
        DesignTimeReportSelection.SetSelectedLayout(NewTempSelectedLayoutCode);
    end;

    procedure RemoveFilenamePath(Input: Text) Result: Text[250]
    var
        pos: Integer;
    begin
        pos := Input.LastIndexOf('/');
        if pos = 0 then
            exit(CopyStr(Input, 1, MaxStrLen(Result)));

        Result := CopyStr(Input, pos + 1, MaxStrLen(Result));
    end;
}