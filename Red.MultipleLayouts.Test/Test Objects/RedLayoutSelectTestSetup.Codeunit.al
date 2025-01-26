
#pragma warning disable AL0432
codeunit 80501 "Red Layout Select Test Setup"
{
    Permissions =
        tabledata "Red Layout Setup" = RIMD,
        tabledata "Red Layout Selection" = RIMD;

    procedure EnsureCustomLayoutsForReport(ReportId: Integer; NoOfLayouts: Integer)
    var
        CustomReportLayout: Record "Custom Report Layout";
        RedTenantReportLayout: Codeunit "Red Tenant Report Layout";
        TempBlob: Codeunit "Temp Blob";
        i: Integer;
    begin
        CustomReportLayout.SetRange("Report ID", ReportId);
        CustomReportLayout.DeleteAll();
        RedTenantReportLayout.GetBuiltinLayout(ReportId, TempBlob);

        for i := 1 to NoOfLayouts do begin
            CustomReportLayout.Init();
            CustomReportLayout.Validate(Code, Format(i));
            CustomReportLayout.Validate("Report ID", ReportId);
            CustomReportLayout.Validate(Description, Format(i));
            CustomReportLayout.Validate(Type, CustomReportLayout.Type::RDLC);
            CustomReportLayout.Insert();
            CustomReportLayout.SetLayoutBlob(TempBlob);
        end;
    end;

    procedure AddLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; CustomReportLayoutCode: Code[20]; SourceFieldName: Text)
    var
        RedLayoutSelection: Record "Red Layout Selection";
        Field: Record Field;
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        RecRef.GetTable(RecVar);
        Field.SetRange(TableNo, RecRef.Number);
        Field.SetRange(FieldName, SourceFieldName);
        Field.FindFirst();
        FldRef := RecRef.Field(Field."No.");

        RedLayoutSelection.Validate("Report ID", ReportId);
        RedLayoutSelection.Validate("Custom Report Layout Code", CustomReportLayoutCode);
        RedLayoutSelection.Validate("Table No.", RecRef.Number);
        RedLayoutSelection.Validate("Field No.", FldRef.Number);
        RedLayoutSelection.Validate(Value, FldRef.Value);
        RedLayoutSelection.Insert();
    end;

    procedure GetTestSalesReportId(): Integer
    begin
        exit(Report::"Standard Sales - Invoice");
    end;
}