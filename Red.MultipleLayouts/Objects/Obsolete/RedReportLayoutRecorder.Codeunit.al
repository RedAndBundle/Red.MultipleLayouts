codeunit 11310876 "Red Report Layout Recorder"
{
    SingleInstance = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit is no longer used because the custom report layouts are discontinued. It is replaced by the table Red Report Layout Selection.';
    ObsoleteTag = '3.1.0.0';

    procedure SetRecord(NewValue: Boolean)
    begin
        DoRecord := NewValue;
    end;

    procedure IsRecording(): Boolean
    begin
        exit(DoRecord);
    end;

    procedure RecordReportToLayoutSelection(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecVarToPrint: Variant): Boolean
    begin
        // exit(RecordReportToLayoutSelection(TempReportSelections."Report ID", IsGUI, RecVarToPrint));
    end;

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

    var
        DoRecord: Boolean;
        ReportRecordedMsg: Label 'Report %1 has been added to the %2', Comment = '%1 = report id, %2 = table caption';
        ReportAlreadyRecordedMsg: Label 'Report %1 has already been added to the %2', Comment = '%1 = report id, %2 = table caption';
}