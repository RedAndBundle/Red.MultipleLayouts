codeunit 11310879 "Red Actionable Error"
{
    // SingleInstance = true;
    Access = Internal;

    procedure SetDefaultTableFieldNotEmpty(ReportLayoutSelection: Record "Red Report Layout Selection")
    var
        ActionTitleLbl: Label 'Reset table and field number fields.';
        MessageErrLbl: Label '%1 and %2 must be 0.', Comment = '%1 is table no caption %2 = field no caption';
        ErrorTitleLbl: Label 'Cannot set record to default.';
        DefaultErrorInfo: ErrorInfo;
    begin
        if not ReportLayoutSelection.Default then
            exit;

        if (ReportLayoutSelection."Table No." = 0) and (ReportLayoutSelection."Field No." = 0) then
            exit;

        DefaultErrorInfo.Title(ErrorTitleLbl);
        DefaultErrorInfo.Message(StrSubstNo(MessageErrLbl, ReportLayoutSelection.FieldCaption("Table No."), ReportLayoutSelection.FieldCaption("Field No.")));
        DefaultErrorInfo.RecordId(ReportLayoutSelection.RecordId);
        DefaultErrorInfo.AddAction(ActionTitleLbl, Codeunit::"Red Actionable Error", 'ResetTableField');
        Error(DefaultErrorInfo);
    end;

    procedure ResetTableField(ErrorInfo: ErrorInfo)
    var
        ReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        ReportLayoutSelection.Get(ErrorInfo.RecordId);
        ReportLayoutSelection."Table No." := 0;
        ReportLayoutSelection."Field No." := 0;
        ReportLayoutSelection.Modify(true);
    end;
}