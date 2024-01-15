codeunit 11310868 "Red Layout Recorder"
{
    SingleInstance = true;

    var
        DoRecord: Boolean;
        ReportRecordedMsg: Label 'Report %1 has been added to the %2', Comment = '%1 = report id, %2 = table caption';
        ReportAlreadyRecordedMsg: Label 'Report %1 has already been added to the %2', Comment = '%1 = report id, %2 = table caption';

    procedure SetRecord(NewValue: Boolean)
    begin
        DoRecord := NewValue;
    end;

    procedure IsRecording(): Boolean
    begin
        exit(DoRecord);
    end;

    [Obsolete('Use with ReportUsage', '3.0.0.0')]
    procedure RecordReportToLayoutSelection(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecVarToPrint: Variant): Boolean
    begin
        exit(RecordReportToLayoutSelection(TempReportSelections."Report ID", IsGUI, RecVarToPrint, TempReportSelections.Usage));
    end;

    [Obsolete('Use with ReportUsage', '3.0.0.0')]
    procedure RecordReportToLayoutSelection(ReportID: Integer; IsGUI: Boolean; RecordVariant: Variant): Boolean
    var
        RedLayoutSelection: Record "Red Layout Selection";
        RecRef: RecordRef;
    begin
        if not IsGUI then
            exit;

        if not DoRecord then
            exit;

        RecRef.GetTable(RecordVariant);
        RedLayoutSelection.Init();
        RedLayoutSelection.Validate("Report ID", ReportID);
        RedLayoutSelection.Validate("Table No.", RecRef.Number);
        if not RedLayoutSelection.Insert() then
            Message(ReportAlreadyRecordedMsg)
        else
            Message(ReportRecordedMsg, ReportID, RedLayoutSelection.TableCaption);
        exit(true);
    end;

    procedure RecordReportToLayoutSelection(ReportID: Integer; IsGUI: Boolean; RecordVariant: Variant; ReportUsage: Enum "Report Selection Usage"): Boolean
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
        RecRef: RecordRef;
    begin
        if not IsGUI then
            exit;

        if not DoRecord then
            exit;

        RecRef.GetTable(RecordVariant);
        RedReportLayoutSelection.Init();
        RedReportLayoutSelection.Validate("Report ID", ReportID);
        RedReportLayoutSelection.Validate("Table No.", RecRef.Number);
        if not RedReportLayoutSelection.Insert() then
            Message(ReportAlreadyRecordedMsg)
        else
            Message(ReportRecordedMsg, ReportID, RedReportLayoutSelection.TableCaption);
        exit(true);
    end;
}