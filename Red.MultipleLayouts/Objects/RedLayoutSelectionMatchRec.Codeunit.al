codeunit 11310864 "Red Layout Selection Match Rec"
{
    procedure MatchRecordVariable(RedLayoutSelection: Record "Red Layout Selection"; RecRef: RecordRef): Boolean
    var
        FldRef: FieldRef;
        TestValue: Code[256];
    begin
        FldRef := RecRef.Field(RedLayoutSelection."Field No.");
        if FldRef.Class = FldRef.Class::FlowField then
            FldRef.CalcField();
        Evaluate(TestValue, Format(FldRef.Value));
        exit(RedLayoutSelection.Value = TestValue);
    end;

    internal procedure MatchRecordVariable(RedReportLayoutSelection: Record "Red Report Layout Selection"; RecRef: RecordRef): Boolean
    var
        RecRef2: RecordRef;
    begin
        RecRef2.Open(RecRef.Number);
        RecRef2.Copy(RecRef);
        RecRef2.SetRecFilter();
        RecRef2.Field(RedReportLayoutSelection."Field No.").SetFilter(RedReportLayoutSelection.Value);
        exit(not RecRef2.IsEmpty());
    end;
}