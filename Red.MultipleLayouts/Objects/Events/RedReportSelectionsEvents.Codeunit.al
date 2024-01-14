// Copyright [2020] [Red and Bundle]
codeunit 11310862 "Red Report Selections Events"
{
    Permissions = tabledata "Red Layout Setup" = R;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeSaveReportAsPDF', '', false, false)]
    local procedure OnBeforeEmailDocument(FilePath: Text[250]; RecordVariant: Variant; ReportUsage: Enum "Report Selection Usage"; SaveToBlob: Boolean; var IsHandled: Boolean; var LayoutCode: Code[20]; var ReportID: Integer; var TempBlob: Codeunit "Temp Blob")
    var
        RedLayoutSelection: Codeunit "Red Layout Selection";
        RedReportLayoutSelection: Codeunit "Red Report Layout Selection";
        RedLayoutRecorder: Codeunit "Red Layout Recorder";
    begin
        if IsHandled then
            exit;

        IsHandled := RedLayoutRecorder.RecordReportToLayoutSelection(ReportID, true, RecordVariant);

        if IsHandled then
            exit;

        if RedLayoutSelection.SetReportLayoutSelection(RecordVariant, ReportID) then
            exit;

        RedReportLayoutSelection.SetTenantReportLayoutSelection(RecordVariant, ReportID, ReportUsage);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforePrintDocument', '', false, false)]
    local procedure OnBeforePrintDocument(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecVarToPrint: Variant; var IsHandled: Boolean)
    var
        RedLayoutSelection: Codeunit "Red Layout Selection";
        RedReportLayoutSelection: Codeunit "Red Report Layout Selection";
        RedLayoutRecorder: Codeunit "Red Layout Recorder";
        UsedLayout: Text;
    begin
        if IsHandled then
            exit;

        IsHandled := RedLayoutRecorder.RecordReportToLayoutSelection(TempReportSelections, IsGUI, RecVarToPrint);
        if IsHandled then
            exit;

        IsHandled := RedLayoutSelection.RunReportWithLayoutSelection(TempReportSelections, IsGUI, RecVarToPrint);
        if IsHandled then
            exit;

        RedReportLayoutSelection.RunReportWithTenantLayoutSelection(TempReportSelections, IsGUI, RecVarToPrint, UsedLayout);
        IsHandled := UsedLayout <> '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Management", 'OnSendDailyTelemetry', '', true, true)]
    local procedure OnSendDailyTelemetry()
    var
        RedLayoutTelemetry: Codeunit "Red Layout Telemetry";
    begin
        RedLayoutTelemetry.EmitExtensionTableTraceTags();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post + Print", 'OnBeforeGetReport', '', false, false)]
    local procedure OnBeforePurchaseGetReport()
    var
        RedLayoutSetup: Record "Red Layout Setup";
    begin
        RedLayoutSetup.InitSetup();
        if RedLayoutSetup."Commit on Post" then
            Commit();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post + Print", 'OnBeforeGetReport', '', false, false)]
    local procedure OnBeforeSalesGetReport()
    var
        RedLayoutSetup: Record "Red Layout Setup";
    begin
        RedLayoutSetup.InitSetup();
        if RedLayoutSetup."Commit on Post" then
            Commit();
    end;
}