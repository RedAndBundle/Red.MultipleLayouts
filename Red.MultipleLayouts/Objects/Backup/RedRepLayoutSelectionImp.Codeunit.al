codeunit 11310874 "Red Rep Layout Selection Imp."
{
    TableNo = "Red Report Layout Selection";
    Access = Internal;

    trigger OnRun()
    var
        TempRedReportLayoutSelection: Record "Red Report Layout Selection" temporary;
        jArray: JsonArray;
        QtyImported: Integer;
    begin
        GetJsonFromFile(jArray);
        CreateTempRedReportLayoutSelectionFromJson(TempRedReportLayoutSelection, jArray);
        CreateCustomReportLayouts(TempRedReportLayoutSelection);
        InsertRedReportLayoutSelection(TempRedReportLayoutSelection, QtyImported);
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

    procedure CreateTempRedReportLayoutSelectionFromJson(var TempRedReportLayoutSelection: Record "Red Report Layout Selection"; var jArray: JsonArray)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempRedReportLayoutSelection);
        CreateRecordsFromJson(RecRef, jArray);
        RecRef.SetTable(TempRedReportLayoutSelection);
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

    procedure CreateCustomReportLayouts(var TempRedReportLayoutSelection: Record "Red Report Layout Selection")
    var
        TenantReportLayout: Record "Tenant Report Layout";
        // CustomReportLayout: Record "Custom Report Layout";
        RedTenantReportLayout: Codeunit "Red Tenant Report Layout";
    begin
        if TempRedReportLayoutSelection.FindSet() then
            repeat
                if TenantReportLayout.Get(TempRedReportLayoutSelection."Report ID", TempRedReportLayoutSelection."Layout Name") then begin
                    if TenantReportLayout."Report ID" <> TempRedReportLayoutSelection."Report ID" then
                        Error(CustReportLayoutDoesNotMatchReportIdErr, TempRedReportLayoutSelection."Layout Name");
                end else begin
                    RedTenantReportLayout.InitBuiltInLayout(TenantReportLayout, TempRedReportLayoutSelection."Report ID", TempRedReportLayoutSelection."Layout Name");
                    // TenantReportLayout.Rename(TempRedReportLayoutSelection."Layout Name");
                    TenantReportLayout.Description := CreatedFromImportMsg;
                    TenantReportLayout.Modify();
                end;
            until TempRedReportLayoutSelection.Next() = 0;
    end;

    procedure InsertRedReportLayoutSelection(var TempRedReportLayoutSelection: Record "Red Report Layout Selection"; var QtyImported: Integer)
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        if TempRedReportLayoutSelection.FindSet() then
            repeat
                RedReportLayoutSelection.Init();
                RedReportLayoutSelection := TempRedReportLayoutSelection;
                RedReportLayoutSelection.Validate("Report ID");
                RedReportLayoutSelection.Validate("Layout Name");
                RedReportLayoutSelection.Validate("Table No.");
                RedReportLayoutSelection.Validate("Field No.");
                if RedReportLayoutSelection.Insert() then
                    QtyImported += 1;
            until TempRedReportLayoutSelection.Next() = 0;
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
        if not jObject.Get(Field.FieldName, jToken) then
            exit;

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