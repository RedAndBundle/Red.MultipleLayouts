codeunit 80400 "Red Layout Selection Test"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure NoCustomLayoutForReport()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        ReportId: Integer;
        TestResult: Boolean;
    begin
        // [FEATURE] No custom layouts for the report to run
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] No custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 0);

        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader);

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
        ReportId: Integer;
        TestResult: Boolean;
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Custom layout is selected
        RedLayoutSelectTestSetup.SelectFirstLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader);

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
        ReportId: Integer;
        TestResult: Boolean;
    begin
        // [FEATURE] One custom layouts in system not selected
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Custom layout is not selected
        RedLayoutSelectTestSetup.DeSelectLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader);

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
        ReportId: Integer;
        TestResult: Boolean;
    begin
        // [FEATURE] Two custom layouts in system, one is selected
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] Two custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Custom layout is selected
        RedLayoutSelectTestSetup.SelectFirstLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader);

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
        ReportId: Integer;
        TestResult: Boolean;
    begin
        // [FEATURE] Two custom layouts in system, none is selected
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] Two custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Custom layout is not selected
        RedLayoutSelectTestSetup.DeSelectLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedLayoutSelectTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader);

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
        ReportId: Integer;
        TestResult: Boolean;
    begin
        // [FEATURE] Two custom layouts in system, one is in layout selection
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] Two custom layouts in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layout is selected in Selection Table
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code');

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader);

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
        ReportId: Integer;
        TestResult: Boolean;
    begin
        // [FEATURE] Two custom layouts in system, two are in layout selection
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] Two custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layouts are selected in Selection Table
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code');
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '2', 'Shortcut Dimension 2 Code');

        // [WHEN] "Red Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader);

        // [THEN] Test Result is false
        if not TestResult then
            Error(UnexpectedResultErr);
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

    [RequestPageHandler]
    procedure SalesInvoiceRequestPageHandler(var SalesInvoiceRequestPage: TestRequestPage "Standard Sales - Invoice")
    begin

    end;

    [ReportHandler]
    procedure SalesInvoiceReportHandler(var SalesInvoice: Report "Standard Sales - Invoice")
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