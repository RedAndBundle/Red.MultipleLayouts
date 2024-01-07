codeunit 80505 "Red Layout Conversion Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure RedLayoutSelectionWithConvertedLayout()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        ReportId: Integer;
        TestResult: Boolean;
    begin
        // [FEATURE] Red Layout Selection exists while custom layout is converted to tenant layout
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestSalesReportId();

        // [Given] Two custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layout is selected in Selection Table
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code');

        // [Given] Convert Custom Layout To Tenant Layout
        // TODO

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader);

        // [THEN] LayoutSelection converted to ReportLayoutSelection
        if TestResult or not LayoutSelectionConverted(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code') then
            error('Test failed');
    end;

    local procedure RunReportWithLayoutSelection(ReportId: Integer; RecVarToPrint: Variant): Boolean
    var
        TempReportSelections: Record "Report Selections" temporary;
        RedLayoutSelection: Codeunit "Red Layout Selection";
    begin
        TempReportSelections."Report ID" := ReportId;
        TempReportSelections.Insert();
        exit(RedLayoutSelection.RunReportWithLayoutSelection(TempReportSelections, false, RecVarToPrint));
    end;

    local procedure LayoutSelectionConverted(RecVar: Variant; ReportId: Integer; ReportLayout: Text; SourceFieldName: Text): Boolean
    var
        RedLayoutSelection: Record "Red Layout Selection";
        RedReportLayoutSelection: Record "Red Report Layout Selection";
        Field: Record Field;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVar);
        Field.SetRange(TableNo, RecRef.Number);
        Field.SetRange(FieldName, SourceFieldName);
        Field.FindFirst();

        RedLayoutSelection.SetRange("Report ID", ReportId);
        RedLayoutSelection.SetRange("Custom Report Layout Code", ReportLayout);
        RedLayoutSelection.SetRange("Table No.", RecRef.Number);
        RedLayoutSelection.SetRange("Field No.", Field."No.");

        RedReportLayoutSelection.SetRange("Report ID", ReportId);
        RedReportLayoutSelection.SetRange("Layout Name", ReportLayout);
        RedReportLayoutSelection.SetRange("Table No.", RecRef.Number);
        RedReportLayoutSelection.SetRange("Field No.", Field."No.");
        exit(RedLayoutSelection.IsEmpty() and not (RedReportLayoutSelection.IsEmpty()));
    end;

    [ReportHandler]
    procedure SalesInvoiceReportHandler(var SalesInvoice: Report "Standard Sales - Invoice")
    begin

    end;
}