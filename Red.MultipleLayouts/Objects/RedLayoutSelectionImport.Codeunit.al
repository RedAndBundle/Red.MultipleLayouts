codeunit 11310867 "Red Layout Selection Import"
{
    TableNo = "Red Layout Selection";

    trigger OnRun()
    var
        TempRedLayoutSelection: Record "Red Layout Selection" temporary;
        jArray: JsonArray;
    begin
        // What if exists, overwrite?
        // Create Cust Rep Layout when it does not exist
        GetJsonFromFile(jArray);
        // FillTempFileFromJson(TempRedLayoutSelection, jArray);
        RecFromJson(TempRedLayoutSelection, jArray);
        // Save Records
    end;

    var
        SelectFileMsg: Label 'Select a file to import';

    local procedure GetJsonFromFile(var jArray: JsonArray)
    var
        Filename: Text;
        jText: Text;
        InStr: InStream;
    begin
        UploadIntoStream(SelectFileMsg, '', 'Json files (*.json)|*.json|Text files (*.txt)|*.txt', Filename, InStr);
        if Filename = '' then
            exit;

        InStr.ReadText(jText);
        jArray.ReadFrom(jText);
    end;

    local procedure FillTempFileFromJson(var TempRedLayoutSelection: Record "Red Layout Selection"; jArray: JsonArray)
    var
        myInt: Integer;
    begin

    end;

    local procedure RecFromJson(Rec: Variant; var jArray: JsonArray)
    var
        Field: Record Field;
        RecRef: RecordRef;
        jObject: JsonObject;
        jToken: JsonToken;
        i: Integer;
    begin
        if not rec.IsRecord then
            exit;
        RecRef.GetTable(Rec);

        for i := 0 to jArray.Count - 1 do begin
            jArray.Get(i, jToken);
            if jToken.IsObject then begin
                jObject := jToken.AsObject();
                Message('%1', jObject);
                Field.SetRange(TableNo, RecRef.Number);
                Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
                Field.SetRange(Class, Field.Class::Normal);
                Field.SetFilter("No.", '<2000000000');
                if Field.FindSet() then
                    repeat
                        AddFieldFromJsonObject(Field, RecRef, jObject);
                    until Field.Next() = 0;
                RecRef.Insert();
            end;
        end;
    end;

    local procedure AddFieldFromJsonObject(Field: Record Field; var RecRef: RecordRef; var jObject: JsonObject)
    var
        FldRef: FieldRef;
        jToken: JsonToken;
    begin
        FldRef := RecRef.Field(Field."No.");
        jObject.Get(Field.FieldName, jToken);

        case FldRef.Type of
            FldRef.Type::Option:
                FldRef.Value := jToken.AsValue().AsOption();
            FldRef.Type::Boolean:
                FldRef.Value := jToken.AsValue().AsBoolean();
            FldRef.Type::Date:
                FldRef.Value := jToken.AsValue().AsDate();
            FldRef.Type::DateTime:
                FldRef.Value := jToken.AsValue().AsDateTime();
            FldRef.Type::Decimal:
                FldRef.Value := jToken.AsValue().AsDecimal();
            FldRef.Type::Integer:
                FldRef.Value := jToken.AsValue().AsInteger();
            FldRef.Type::Time:
                FldRef.Value := jToken.AsValue().AsTime();
            FldRef.Type::Duration:
                FldRef.Value := jToken.AsValue().AsDuration();
            else
                FldRef.Value := jToken.AsValue().AsText()
        end;

    end;

    // local procedure ValidateData(FieldKey: Integer; Data: JsonArray)
    // var
    //     FieldValidationRED: Codeunit "Field Validation RED";
    //     RecRef: RecordRef;
    //     FldRef: FieldRef;
    //     FieldList: JsonArray;
    //     FieldObject: JsonObject;
    //     JToken: JsonToken;
    //     i: Integer;
    //     LastError: Text;
    // // StreamOut: OutStream;
    // begin
    //     FieldList := GetArrayFromMetadata('fieldlist');
    //     GetRecRef(RecRef);
    //     FieldObject := GetFieldObjectFromFieldList(FieldList, FieldKey);
    //     FldRef := RecRef.Field(GetFieldNumberFromFieldObject(FieldObject));
    //     Data.Get(FieldKey, JToken);
    //     JToken.AsObject().Get('fieldvalue', JToken);
    //     Evaluate(FldRef, JToken.AsValue().AsText());

    //     FieldValidationRED.SetRecordRef(RecRef);
    //     FieldValidationRED.SetFieldRef(FldRef);
    //     if not FieldValidationRED.Run() then
    //         LastError := GetLastErrorText();
    //     RecRef.Find();

    //     Clear(Data);

    //     for i := 0 to FieldList.Count - 1 do begin
    //         FieldObject := GetFieldObjectFromFieldList(FieldList, i);
    //         Data.Add(AddFieldData(RecRef, GetFieldNumberFromFieldObject(FieldObject)));
    //     end;

    //     // Message('Field: %1, Data: %2', FieldNo, Data);
    //     Sleep(1000);

    //     CurrPage.ReactPageControlAddinRED.ValidationResult(FieldKey, Data, LastError);
    // end;
}