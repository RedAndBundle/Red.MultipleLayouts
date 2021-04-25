// Copyright [2020] [Red and Bundle]
codeunit 11310862 "Red Report Selections Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforePrintDocument', '', false, false)]
    local procedure OnBeforePrintDocument(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecVarToPrint: Variant; var IsHandled: Boolean)
    var
        RedLayoutSelection: Codeunit "Red Layout Selection";
        RedLayoutRecorder: Codeunit "Red Layout Recorder";
    begin
        if IsHandled then
            exit;

        IsHandled := RedLayoutRecorder.RecordReportToLayoutSelection(TempReportSelections, IsGUI, RecVarToPrint);

        if IsHandled then
            exit;

        IsHandled := RedLayoutSelection.RunReportWithLayoutSelection(TempReportSelections, IsGUI, RecVarToPrint);
    end;
}