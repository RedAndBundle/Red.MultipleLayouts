codeunit 11310865 "Red Layout Selection"
{
    procedure SetReportLayoutSelection(RecordVariant: Variant; ReportID: Integer)
    var
        TempCustomReportLayout: Record "Custom Report Layout" temporary;
        SelectedLayoutCode: code[20];
    begin
        if not GetLayoutsFromLayoutSelection(TempCustomReportLayout, RecordVariant, ReportID) then
            if not GetDefaultLayoutForReport(TempCustomReportLayout, ReportID) then begin
                if not GetTempCustomReportLayout(TempCustomReportLayout, ReportID) then
                    exit;

                GetSelectedLayoutCode(ReportID, SelectedLayoutCode);

                AddDefaultLayoutToList(TempCustomReportLayout, SelectedLayoutCode, ReportID);
            end;

        SetTempLayoutSelected(SelectLayout(TempCustomReportLayout));
    end;

    procedure RunReportWithLayoutSelection(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant): Boolean
    var
        TempCustomReportLayout: Record "Custom Report Layout" temporary;
        SelectedLayoutCode: code[20];
    begin
        if not GetLayoutsFromLayoutSelection(TempCustomReportLayout, RecordVariant, TempReportSelections."Report ID") then
            if not GetDefaultLayoutForReport(TempCustomReportLayout, TempReportSelections."Report ID") then begin
                if not GetTempCustomReportLayout(TempCustomReportLayout, TempReportSelections."Report ID") then
                    exit(false);

                GetSelectedLayoutCode(TempReportSelections."Report ID", SelectedLayoutCode);

                AddDefaultLayoutToList(TempCustomReportLayout, SelectedLayoutCode, TempReportSelections."Report ID");
            end;

        RunReportWithSelectedLayout(TempReportSelections, IsGUI, RecordVariant, SelectLayout(TempCustomReportLayout));
        exit(true);
    end;

    local procedure GetLayoutsFromLayoutSelection(var TempCustomReportLayout: Record "Custom Report Layout"; RecordVariant: Variant; ReportId: Integer) Success: Boolean
    var
        RedLayoutSelection: Record "Red Layout Selection";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecordVariant);

        RedLayoutSelection.SetRange("Report ID", ReportId);
        RedLayoutSelection.SetRange("Table No.", RecRef.Number);
        RedLayoutSelection.SetFilter("Field No.", '>0');
        RedLayoutSelection.SetFilter("Custom Report Layout Code", '<>%1', '');
        if RedLayoutSelection.FindSet() then
            repeat
                if RedLayoutSelection.MatchRecordVariable(RecRef) then
                    Success := AddLayoutSelectionToTempCustomReportLayout(TempCustomReportLayout, RedLayoutSelection."Custom Report Layout Code");
            until RedLayoutSelection.Next() = 0;
    end;

    local procedure GetDefaultLayoutForReport(var TempCustomReportLayout: Record "Custom Report Layout"; ReportId: Integer): Boolean
    var
        RedLayoutSelection: Record "Red Layout Selection";
    begin
        RedLayoutSelection.SetRange("Report ID", ReportId);
        RedLayoutSelection.SetRange(Default, true);
        RedLayoutSelection.SetFilter("Custom Report Layout Code", '<>%1', '');
        if RedLayoutSelection.FindFirst() then
            exit(AddLayoutSelectionToTempCustomReportLayout(TempCustomReportLayout, RedLayoutSelection."Custom Report Layout Code"));

        RedLayoutSelection.SetRange("Custom Report Layout Code");
        if not RedLayoutSelection.IsEmpty then
            exit(AddEmptyLayoutToTempCustomReportLayout(TempCustomReportLayout, ReportId));
    end;

    local procedure GetTempCustomReportLayout(var TempCustomReportLayout: Record "Custom Report Layout"; ReportId: Integer): Boolean
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        CustomReportLayout.SetRange("Report ID", ReportId);
        CustomReportLayout.SetFilter("Company Name", '%1|%2', CompanyName, '');
        CustomReportLayout.SetFilter(Description, '<>ForNAV BC preview*');
        if CustomReportLayout.FindSet() then
            repeat
                TempCustomReportLayout."Report ID" := CustomReportLayout."Report ID";
                TempCustomReportLayout.Code := CustomReportLayout.Code;
                TempCustomReportLayout.Description := CustomReportLayout.Description;
                TempCustomReportLayout."Company Name" := CustomReportLayout."Company Name";
                TempCustomReportLayout.Insert();
            until CustomReportLayout.Next() = 0;
        exit(not TempCustomReportLayout.IsEmpty());
    end;

    local procedure GetSelectedLayoutCode(ReportId: Integer; var SelectedLayoutCode: code[20])
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        ReportLayoutSelection.SetAutoCalcFields("Report Layout Description");
        if ReportLayoutSelection.Get(ReportId, CompanyName) then
            if (ReportLayoutSelection.Type = ReportLayoutSelection.Type::"Custom Layout") and (ReportLayoutSelection."Report Layout Description" <> '') then
                SelectedLayoutCode := ReportLayoutSelection."Custom Report Layout Code";
    end;

    local procedure AddDefaultLayoutToList(var TempCustomReportLayout: Record "Custom Report Layout"; SelectedLayoutCode: code[20]; ReportId: Integer)
    var
        DefaultLayoutMsg: Label 'Default Layout';
    begin
        if SelectedLayoutCode = '' then begin
            TempCustomReportLayout.Init();
            TempCustomReportLayout."Report ID" := ReportId;
            TempCustomReportLayout.Code := '';
            TempCustomReportLayout.Description := DefaultLayoutMsg;
            TempCustomReportLayout."Company Name" := CompanyName;
            TempCustomReportLayout.Insert();
        end;
    end;

    local procedure AddLayoutSelectionToTempCustomReportLayout(var TempCustomReportLayout: Record "Custom Report Layout"; CustomReportLayoutCode: Code[20]): Boolean
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        CustomReportLayout.Get(CustomReportLayoutCode);
        if not (CustomReportLayout."Company Name" in [CompanyName, '']) then
            exit;

        TempCustomReportLayout."Report ID" := CustomReportLayout."Report ID";
        TempCustomReportLayout.Code := CustomReportLayout.Code;
        TempCustomReportLayout.Description := CustomReportLayout.Description;
        TempCustomReportLayout."Company Name" := CustomReportLayout."Company Name";
        exit(TempCustomReportLayout.Insert());
    end;

    local procedure AddEmptyLayoutToTempCustomReportLayout(var TempCustomReportLayout: Record "Custom Report Layout"; ReportID: Integer): Boolean
    var
    // CustomReportLayout: Record "Custom Report Layout";
    begin
        // CustomReportLayout.Get(CustomReportLayoutCode);
        // if not (CustomReportLayout."Company Name" in [CompanyName, '']) then
        //     exit;

        TempCustomReportLayout."Report ID" := ReportID;
        // TempCustomReportLayout.Code := CustomReportLayout.Code;
        // TempCustomReportLayout.Description := CustomReportLayout.Description;
        // TempCustomReportLayout."Company Name" := CustomReportLayout."Company Name";
        exit(TempCustomReportLayout.Insert());
    end;

    local procedure SelectLayout(var TempCustomReportLayout: Record "Custom Report Layout"): Code[20]
    var
        SelectLayoutErr: Label 'No report layout selected';
    begin
        if TempCustomReportLayout.Count > 1 then
            if not (Page.RunModal(Page::"Custom Report Layouts", TempCustomReportLayout) = ACTION::LookupOK) then
                Error(SelectLayoutErr);

        if TempCustomReportLayout.Find() then
            exit(TempCustomReportLayout.Code);
    end;

    local procedure RunReportWithSelectedLayout(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecordVariant: Variant; CustomLayoutCode: Code[20])
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        ReportLayoutSelection.SetTempLayoutSelected(CustomLayoutCode);
        Report.RunModal(TempReportSelections."Report ID", IsGUI, false, RecordVariant);
        ReportLayoutSelection.SetTempLayoutSelected('');
    end;

    procedure SetTempLayoutSelected(NewTempSelectedLayoutCode: Code[20])
    var
        DesignTimeReportSelection: Codeunit "Design-time Report Selection";
    begin
        DesignTimeReportSelection.SetSelectedCustomLayout(NewTempSelectedLayoutCode);
    end;
}