codeunit 11310867 "Red Layout Selection Import"
{
    TableNo = "Red Layout Selection";
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit is no longer used because the custom report layouts are discontinued. It is replaced by the table Red Report Layout Selection.';
    ObsoleteTag = '3.1.0.0';

    trigger OnRun()
    var
        TempRedLayoutSelection: Record "Red Layout Selection" temporary;
        jArray: JsonArray;
        QtyImported: Integer;
    begin
        GetJsonFromFile(jArray);
        CreateTempRedLayoutSelectionFromJson(TempRedLayoutSelection, jArray);
        CreateCustomReportLayouts(TempRedLayoutSelection);
        InsertRedLayoutSelection(TempRedLayoutSelection, QtyImported);
        DisplayResultsMessage(QtyImported);
    end;

    var
        SelectFileMsg: Label 'Select a file to import';
        CompletedMsg: Label 'Import completed, %1 new records were created', Comment = '%1 = no of records created';
        CreatedFromImportMsg: Label 'Blank layout, created from Red Layout Selection import';
        CustReportLayoutDoesNotMatchReportIdErr: Label 'Custom Report Layout %1 has the Wrong report ID', Comment = '%1 = the report layout for the new record';

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

    procedure CreateTempRedLayoutSelectionFromJson(var TempRedLayoutSelection: Record "Red Layout Selection"; var jArray: JsonArray)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempRedLayoutSelection);
        CreateRecordsFromJson(RecRef, jArray);
        RecRef.SetTable(TempRedLayoutSelection);
    end;

    procedure CreateRecordsFromJson(var RecRef: RecordRef; var jArray: JsonArray)
    var
        Field: Record Field;
        jObject: JsonObject;
        jToken: JsonToken;
        i: Integer;
    begin
        for i := 0 to jArray.Count - 1 do begin
            jArray.Get(i, jToken);
            if jToken.IsObject then begin
                jObject := jToken.AsObject();
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

    procedure CreateCustomReportLayouts(var TempRedLayoutSelection: Record "Red Layout Selection")
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        if TempRedLayoutSelection.FindSet() then
            repeat
                if CustomReportLayout.Get(TempRedLayoutSelection."Custom Report Layout Code") then begin
                    if CustomReportLayout."Report ID" <> TempRedLayoutSelection."Report ID" then
                        Error(CustReportLayoutDoesNotMatchReportIdErr, TempRedLayoutSelection."Custom Report Layout Code");
                end else begin
                    CustomReportLayout.Get(CustomReportLayout.InitBuiltInLayout(TempRedLayoutSelection."Report ID", CustomReportLayout.Type::Word.AsInteger()));
                    CustomReportLayout.Rename(TempRedLayoutSelection."Custom Report Layout Code");
                    CustomReportLayout.Description := CreatedFromImportMsg;
                    CustomReportLayout.Modify();
                end;
            until TempRedLayoutSelection.Next() = 0;
    end;

    procedure InsertRedLayoutSelection(var TempRedLayoutSelection: Record "Red Layout Selection"; var QtyImported: Integer)
    var
        RedLayoutSelection: Record "Red Layout Selection";
    begin
        if TempRedLayoutSelection.FindSet() then
            repeat
                RedLayoutSelection.Init();
                RedLayoutSelection := TempRedLayoutSelection;
                RedLayoutSelection.Validate("Report ID");
                RedLayoutSelection.Validate("Custom Report Layout Code");
                RedLayoutSelection.Validate("Table No.");
                RedLayoutSelection.Validate("Field No.");
                if RedLayoutSelection.Insert() then
                    QtyImported += 1;
            until TempRedLayoutSelection.Next() = 0;
    end;

    local procedure DisplayResultsMessage(QtyImported: Integer)
    begin
        Message(CompletedMsg, QtyImported);
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
}