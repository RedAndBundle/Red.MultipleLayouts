// Copyright [2020] [Red and Bundle]
codeunit 80002 "Red Layout Selection Match Rec"
{
    procedure MatchRecordVariable(LayoutSelection: Record "Red Layout Selection"; RecRef: RecordRef): Boolean
    var
        FldRef: FieldRef;
        TestValue: Code[50];
    begin
        with LayoutSelection do begin
            FldRef := RecRef.Field("Field No.");
            if FldRef.Class = FldRef.Class::FlowField then
                FldRef.CalcField();
            Evaluate(TestValue, Format(FldRef.Value));
            exit(Value = TestValue);
        end;
    end;
}