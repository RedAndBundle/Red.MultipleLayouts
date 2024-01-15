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
    // FldRef: FieldRef;
    // TestValue: Code[256];
    begin
        RecRef.SetRecFilter();
        RecRef.Field(RedReportLayoutSelection."Field No.").SetFilter(RedReportLayoutSelection.Value);
        exit(not RecRef.IsEmpty());

        // FldRef := RecRef.Field(RedReportLayoutSelection."Field No.");
        // if FldRef.Class = FldRef.Class::FlowField then
        //     FldRef.CalcField();
        // Evaluate(TestValue, Format(FldRef.Value));
        // exit(RedReportLayoutSelection.Value = TestValue);
    end;
}