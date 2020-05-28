// Copyright [2020] [Red and Bundle]
codeunit 80400 "Red Layout Selection Test"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure NoCustomLayoutForReport()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        TestResult: Boolean;
    begin
        // [FEATURE] No custom layouts for the report to run
        // [Given] No custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(206, 0);
        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(206);
        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(206, SalesInvoiceHeader);

        // [THEN] Test Result is false
        if TestResult then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure OneCustomLayoutSelected()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        TestResult: Boolean;
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(206, 1);
        // [Given] Custom layout is selected
        RedLayoutSelectTestSetup.SelectFirstLayoutForReport(206);
        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(206);
        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(206, SalesInvoiceHeader);

        // [THEN] Test Result is false
        if not TestResult then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandlerDefault,SalesInvoiceReportHandler')]
    procedure OneCustomLayoutNotSelected()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        TestResult: Boolean;
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(206, 1);
        // [Given] Custom layout is not selected
        RedLayoutSelectTestSetup.DeSelectLayoutForReport(206);
        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(206);
        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(206, SalesInvoiceHeader);

        // [THEN] Test Result is false
        if not TestResult then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandler,SalesInvoiceReportHandler')]
    procedure TwoCustomLayoutSelected()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        TestResult: Boolean;
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] Two custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(206, 2);
        // [Given] Custom layout is selected
        RedLayoutSelectTestSetup.SelectFirstLayoutForReport(206);
        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(206);
        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(206, SalesInvoiceHeader);

        // [THEN] Test Result is false
        if not TestResult then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandlerDefault,SalesInvoiceReportHandler')]
    procedure TwoCustomLayoutNotSelected()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        TestResult: Boolean;
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] Two custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(206, 2);
        // [Given] Custom layout is not selected
        RedLayoutSelectTestSetup.DeSelectLayoutForReport(206);
        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(206);
        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(206, SalesInvoiceHeader);

        // [THEN] Test Result is false
        if not TestResult then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure TwoLayoutsOneLayoutInLayoutSelection()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        TestResult: Boolean;
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] Two custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(206, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layout is selected in Selection Table
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, 206, '1', 'Shortcut Dimension 1 Code');

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(206, SalesInvoiceHeader);

        // [THEN] Test Result is false
        if not TestResult then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandler,SalesInvoiceReportHandler')]
    procedure TwoLayoutsTwoLayoutsInLayoutSelection()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        TestResult: Boolean;
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(206, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layouts are selected in Selection Table
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, 206, '1', 'Shortcut Dimension 1 Code');
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, 206, '2', 'Shortcut Dimension 2 Code');

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(206, SalesInvoiceHeader);

        // [THEN] Test Result is false
        if not TestResult then
            Error(UnexpectedResultErr);
    end;

    local procedure RunReportWithLayoutSelection(ReportId: Integer; RecVarToPrint: Variant): Boolean
    var
        TempReportSelections: Record "Report Selections" temporary;
        RedLayoutSelection: Codeunit "Red Layout Selection";
        IsGUI: Boolean;
    begin
        TempReportSelections."Report ID" := ReportId;
        TempReportSelections.Insert();
        exit(RedLayoutSelection.RunReportWithLayoutSelection(TempReportSelections, false, RecVarToPrint));
    end;

    [RequestPageHandler]
    procedure SalesInvoiceRequestPageHandler(var SalesInvoiceRequestPage: TestRequestPage "Sales - Invoice")
    begin

    end;

    [ReportHandler]
    procedure SalesInvoiceReportHandler(var SalesInvoice: Report "Sales - Invoice")
    begin

    end;

    [ModalPageHandler]
    procedure CustomReportLayoutsSelectionPageHandler(var CustomReportLayouts: TestPage "Custom Report Layouts")
    begin
        // ToDo test with cancel
        CustomReportLayouts.GoToKey('1');
        CustomReportLayouts.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CustomReportLayoutsSelectionPageHandlerDefault(var CustomReportLayouts: TestPage "Custom Report Layouts")
    begin
        // ToDo test with cancel
        CustomReportLayouts.GoToKey('');
        CustomReportLayouts.OK().Invoke();
    end;

    var
        UnexpectedResultErr: Label 'Unexpected result';
}