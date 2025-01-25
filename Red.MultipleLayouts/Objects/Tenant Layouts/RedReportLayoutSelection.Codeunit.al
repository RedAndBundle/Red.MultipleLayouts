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
                    AddDefaultLayoutToList(TempTenantReportLayout, ReportID);
            end;

        SetTempTenantLayoutSelected(SelectLayout(TempTenantReportLayout));
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
        TempTenantReportLayout: Record "Tenant Report Layout" temporary;
        SelectedLayoutCode: Text;
    begin
        if not GetLayoutsFromLayoutSelection(TempTenantReportLayout, RecordVariant, TempReportSelections."Report ID", TempReportSelections.Usage) then
            if not GetDefaultLayoutForReport(TempTenantReportLayout, TempReportSelections."Report ID", TempReportSelections.Usage) then begin
                if not GetTempCustomReportLayout(TempTenantReportLayout, TempReportSelections."Report ID") then
                    exit;

                GetSelectedLayoutCode(TempReportSelections."Report ID", SelectedLayoutCode);

                if SelectedLayoutCode = '' then
                    AddDefaultLayoutToList(TempTenantReportLayout, TempReportSelections."Report ID");
            end;

        UsedLayoutCode := SelectLayout(TempTenantReportLayout);
        RunReportWithSelectedLayout(TempReportSelections, IsGUI, RecordVariant, UsedLayoutCode);
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
                    Success := AddLayoutSelectionToTempCustomReportLayout(TempTenantReportLayout, RedReportLayoutSelection."Layout Name", ReportId);
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
            exit(AddLayoutSelectionToTempCustomReportLayout(TempTenantReportLayout, RedReportLayoutSelection."Layout Name", ReportId));

        RedReportLayoutSelection.SetRange("Report Selection Usage", Usage::RedBlank);
        if RedReportLayoutSelection.FindFirst() then
            exit(AddLayoutSelectionToTempCustomReportLayout(TempTenantReportLayout, RedReportLayoutSelection."Layout Name", ReportId));

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
                TempTenantReportLayout.Insert();
            until TenantReportLayout.Next() = 0;

        exit(not TempTenantReportLayout.IsEmpty());
    end;

    local procedure GetSelectedLayoutCode(ReportId: Integer; var SelectedLayoutCode: Text)
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        NullGuid: Guid;
    begin
        if TenantReportLayoutSelection.Get(ReportId, CompanyName, NullGuid) then
            SelectedLayoutCode := TenantReportLayoutSelection."Layout Name";
    end;

    local procedure AddDefaultLayoutToList(var TempTenantReportLayout: Record "Tenant Report Layout"; ReportId: Integer)
    var
        DefaultLayoutMsg: Label 'Default Layout';
    begin
        TempTenantReportLayout.Init();
        TempTenantReportLayout."Report ID" := ReportId;
        TempTenantReportLayout.Name := '';
        TempTenantReportLayout.Description := DefaultLayoutMsg;
        TempTenantReportLayout."Company Name" := CompanyName;
        TempTenantReportLayout.Insert();
    end;

    local procedure AddLayoutSelectionToTempCustomReportLayout(var TempTenantReportLayout: Record "Tenant Report Layout"; ReportLayout: Text; ReportId: Integer): Boolean
    var
        TenantReportLayout: Record "Tenant Report Layout";
    begin
        TenantReportLayout.Get(ReportId, ReportLayout);
        if not (TenantReportLayout."Company Name" in [CompanyName, '']) then
            exit;

        TempTenantReportLayout."Report ID" := TenantReportLayout."Report ID";
        TempTenantReportLayout.Name := TenantReportLayout.Name;
        TempTenantReportLayout.Description := TenantReportLayout.Description;
        TempTenantReportLayout."Company Name" := TenantReportLayout."Company Name";
        exit(TempTenantReportLayout.Insert());
    end;

    local procedure AddEmptyLayoutToTempCustomReportLayout(var TempTenantReportLayout: Record "Tenant Report Layout"; ReportID: Integer): Boolean
    begin
        TempTenantReportLayout."Report ID" := ReportID;
        exit(TempTenantReportLayout.Insert());
    end;

    local procedure SelectLayout(var TempTenantReportLayout: Record "Tenant Report Layout"): Text
    var
        Setup: Record "Red Layout Setup";
        SelectLayoutErr: Label 'No report layout selected';

        Options: Text;
        Selected: Integer;
        Text000: Label 'Save,Delete,Exit,Find';
        Text001: Label 'You selected option %1.';
        Text002: Label 'Choose one of the following layouts:';
    begin
        if not GuiAllowed() then begin
            if TempTenantReportLayout.FindFirst() then
                exit(TempTenantReportLayout.Name);
            exit;
        end;

        Setup.InitSetup();
        Setup."Commit on Post" := not Setup."Commit on Post";
        Setup.Modify();

        if TempTenantReportLayout.IsEmpty() then
            exit('');

        if TempTenantReportLayout.Count = 1 then begin
            TempTenantReportLayout.FindFirst();
            exit(TempTenantReportLayout.Name);
        end;

        if IsInWriteTransaction() then begin
            if TempTenantReportLayout.FindSet() then
                repeat
                    Options += TempTenantReportLayout.Description + ',';
                until TempTenantReportLayout.Next() = 0;

            Selected := Dialog.StrMenu(Options, 1, Text002);
            Error(Text001, Selected);
            // error(Selected);
        end;

        if not (Page.RunModal(Page::"Red Report Layouts", TempTenantReportLayout) = ACTION::LookupOK) then
            Error(SelectLayoutErr);

        if TempTenantReportLayout.Find() then
            exit(TempTenantReportLayout.Name);
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