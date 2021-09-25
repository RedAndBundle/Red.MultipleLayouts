// Copyright [2020] [Red and Bundle]
codeunit 11310862 "Red Report Selections Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeSaveReportAsPDF', '', false, false)]
    local procedure OnBeforeEmailDocument(FilePath: Text[250]; RecordVariant: Variant; ReportUsage: Enum "Report Selection Usage"; SaveToBlob: Boolean; var IsHandled: Boolean; var LayoutCode: Code[20]; var ReportID: Integer; var TempBlob: Codeunit "Temp Blob")
    var
        RedLayoutSelection: Codeunit "Red Layout Selection";
        RedLayoutRecorder: Codeunit "Red Layout Recorder";
    begin
        if IsHandled then
            exit;

        IsHandled := RedLayoutRecorder.RecordReportToLayoutSelection(ReportID, true, RecordVariant);

        if IsHandled then
            exit;

        RedLayoutSelection.SetReportLayoutSelection(RecordVariant, ReportID);
    end;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Generate Activity Telemetry", 'OnActivityTelemetry', '', false, false)]
    local procedure EmitExtensionTableTraceTags()
    var
        RedLayoutTelemetry: Codeunit "Red Layout Telemetry";
    begin
        RedLayoutTelemetry.EmitExtensionTableTraceTags();
    end;
}