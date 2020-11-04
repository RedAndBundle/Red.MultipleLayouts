codeunit 11310865 "Red Layout Selection"
{
    procedure RunReportWithLayoutSelection(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecVarToPrint: Variant): Boolean
    var
        TempCustomReportLayout: Record "Custom Report Layout" temporary;
        SelectedLayoutCode: code[20];
    begin
        if not GetLayoutsFromLayoutSelection(TempCustomReportLayout, RecVarToPrint, TempReportSelections."Report ID") then begin
            if not GetTempCustomReportLayout(TempCustomReportLayout, TempReportSelections."Report ID") then
                exit(false);

            GetSelectedLayoutCode(TempReportSelections."Report ID", SelectedLayoutCode);

            AddDefaultLayoutToList(TempCustomReportLayout, SelectedLayoutCode, TempReportSelections."Report ID");
        end;

        RunReportWithSelectedLayout(TempReportSelections, IsGUI, RecVarToPrint, SelectLayout(TempCustomReportLayout));
        exit(true);
    end;

    local procedure GetTempCustomReportLayout(var TempCustomReportLayout: Record "Custom Report Layout"; ReportId: Integer): Boolean
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        with CustomReportLayout do begin
            SetRange("Report ID", ReportId);
            SetFilter("Company Name", '%1|%2', CompanyName, '');
            SetFilter(Description, '<>ForNAV BC preview*');
            if FindSet() then
                repeat
                    TempCustomReportLayout."Report ID" := "Report ID";
                    TempCustomReportLayout.Code := Code;
                    TempCustomReportLayout.Description := Description;
                    TempCustomReportLayout."Company Name" := "Company Name";
                    TempCustomReportLayout.Insert();
                until CustomReportLayout.Next() = 0;
        end;
        exit(not TempCustomReportLayout.IsEmpty());
    end;

    local procedure GetSelectedLayoutCode(ReportId: Integer; var SelectedLayoutCode: code[20])
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        with ReportLayoutSelection do
            if Get(ReportId, CompanyName) then
                SelectedLayoutCode := "Custom Report Layout Code";
    end;

    local procedure IsTheOnlyCustomLayoutSelected(var TempCustomReportLayout: Record "Custom Report Layout"; SelectedLayoutCode: code[20]): Boolean
    begin
        if TempCustomReportLayout.Count > 1 then
            exit(false);

        exit(SelectedLayoutCode <> '');
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

    local procedure GetLayoutsFromLayoutSelection(var TempCustomReportLayout: Record "Custom Report Layout"; RecVarToPrint: Variant; ReportId: Integer) Success: Boolean
    var
        RedLayoutSelection: Record "Red Layout Selection";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVarToPrint);

        with RedLayoutSelection do begin
            SetRange("Report ID", ReportId);
            SetRange("Table No.", RecRef.Number);
            SetFilter("Field No.", '>0');
            if FindSet() then
                repeat
                    if MatchRecordVariable(RecRef) then
                        Success := AddLayoutSelectionToTempCustomReportLayout(TempCustomReportLayout, "Custom Report Layout Code");
                until Next() = 0;
        end;
    end;

    local procedure AddLayoutSelectionToTempCustomReportLayout(var TempCustomReportLayout: Record "Custom Report Layout"; CustomReportLayoutCode: Code[20]): Boolean
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        CustomReportLayout.Get(CustomReportLayoutCode);
        if not (CustomReportLayout."Company Name" in [CompanyName, '']) then
            exit;

        with TempCustomReportLayout do begin
            TempCustomReportLayout."Report ID" := CustomReportLayout."Report ID";
            TempCustomReportLayout.Code := CustomReportLayout.Code;
            TempCustomReportLayout.Description := CustomReportLayout.Description;
            TempCustomReportLayout."Company Name" := CustomReportLayout."Company Name";
            exit(TempCustomReportLayout.Insert());
        end;
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

    local procedure RunReportWithSelectedLayout(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecVarToPrint: Variant; CustomLayoutCode: Code[20])
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        ReportLayoutSelection.SetTempLayoutSelected(CustomLayoutCode);
        Report.RunModal(TempReportSelections."Report ID", IsGUI, false, RecVarToPrint);
        ReportLayoutSelection.SetTempLayoutSelected('');
    end;
}