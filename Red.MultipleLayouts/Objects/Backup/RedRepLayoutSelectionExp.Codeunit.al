codeunit 11310875 "Red Rep Layout Selection Exp."
{
    TableNo = "Red Report Layout Selection";
    Access = Internal;

    trigger OnRun()
    var
        jArray: JsonArray;
    begin
        CreateJsonFromRecords(Rec, jArray, false, true);
        ExportFile(jArray);
    end;

    procedure CreateJsonFromRecords(Rec: Variant; var jArray: JsonArray; ExportSystemFields: Boolean; ExportFlowFields: Boolean)
    var
        Field: Record Field;
        RecRef: RecordRef;
        jObject: JsonObject;
    begin
        if not rec.IsRecord then
            exit;
        RecRef.GetTable(Rec);
        if RecRef.FindSet() then
            repeat
                Clear(jObject);
                Field.SetRange(TableNo, RecRef.Number);
                Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
                if not ExportFlowFields then
                    Field.SetRange(Class, Field.Class::Normal);
                if not ExportSystemFields then
                    Field.SetFilter("No.", '<2000000000');
                if Field.FindSet() then
                    repeat
                        AddFieldToJsonObject(Field, RecRef, jObject);
                    until Field.Next() = 0;
                jArray.Add(jObject);
            until RecRef.Next() = 0;
    end;

    local procedure AddFieldToJsonObject(Field: Record Field; var RecRef: RecordRef; var jObject: JsonObject)
    var
        FldRef: FieldRef;
        MyValue: JsonValue;
        MyBoolean: Boolean;
        MyOption: Option;
        MyInteger: Integer;
        MyDecimal: Decimal;
        MyDuration: Duration;
        MyDate: Date;
        MyTime: Time;
        MyDateTime: DateTime;
    begin
        FldRef := RecRef.Field(Field."No.");

        case true of
            FldRef.Class = FldRef.Class::FlowField,
            FldRef.Type = FldRef.Type::Blob:
                FldRef.CalcField();
        end;

        case FldRef.Type of
            FldRef.Type::Option:
                begin
                    MyOption := FldRef.Value;
                    MyValue.SetValue(MyOption);
                end;
            FldRef.Type::Boolean:
                begin
                    MyBoolean := FldRef.Value;
                    MyValue.SetValue(MyBoolean);
                end;
            FldRef.Type::Date:
                begin
                    MyDate := FldRef.Value;
                    MyValue.SetValue(MyDate);
                end;
            FldRef.Type::DateTime:
                begin
                    MyDateTime := FldRef.Value;
                    MyValue.SetValue(MyDateTime);
                end;
            FldRef.Type::Decimal:
                begin
                    MyDecimal := FldRef.Value;
                    MyValue.SetValue(MyDecimal);
                end;
            FldRef.Type::Integer:
                begin
                    MyInteger := FldRef.Value;
                    MyValue.SetValue(MyInteger);
                end;
            FldRef.Type::Time:
                begin
                    MyTime := FldRef.Value;
                    MyValue.SetValue(MyTime);
                end;
            FldRef.Type::Duration:
                begin
                    MyDuration := FldRef.Value;
                    MyValue.SetValue(MyDuration);
                end;
            else
                MyValue.SetValue(Format(FldRef.Value));
        end;
        jObject.Add(Field.FieldName, MyValue);
    end;

    local procedure ExportFile(jArray: JsonArray)
    var
        TempBlob: Codeunit "Temp Blob";
        jText: Text;
        Filename: Text;
        InStr: InStream;
        OutStr: OutStream;
    begin
        jArray.WriteTo(jText);
        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(jText);
        TempBlob.CreateInStream(InStr);
        Filename := 'MultipleLayout.json';
        DownloadFromStream(InStr, '', '', '', Filename);
    end;
}