codeunit 11310864 "Red Layout Selection Match Rec"
{
    procedure MatchRecordVariable(RedLayoutSelection: Record "Red Layout Selection"; RecRef: RecordRef): Boolean
    var
        FldRef: FieldRef;
        TestValue: Code[256];
    begin
        begin
            FldRef := RecRef.Field(RedLayoutSelection."Field No.");
            if FldRef.Class = FldRef.Class::FlowField then
                FldRef.CalcField();
            Evaluate(TestValue, Format(FldRef.Value));
            exit(RedLayoutSelection.Value = TestValue);
        end;
    end;

    internal procedure MatchRecordVariable(FieldNo: Integer; Value: Code[50]; RecRef: RecordRef): Boolean
    var
        FldRef: FieldRef;
        TestValue: Code[256];
    begin
        begin
            FldRef := RecRef.Field(FieldNo);
            if FldRef.Class = FldRef.Class::FlowField then
                FldRef.CalcField();
            Evaluate(TestValue, Format(FldRef.Value));
            exit(Value = TestValue);
        end;
    end;
}