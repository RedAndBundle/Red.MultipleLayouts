codeunit 80506 "Red Rep Layout Selection Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure NoCustomLayoutForReport()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] No custom layouts for the report to run
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] No custom layouts in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 0);

        // [GIVEN] No records in the Layout Selection Table
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] The used layout is empty
        if TestResult <> '' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure OneCustomLayoutSelected()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] One custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Custom layout is selected
        RedRepLayoutSelTestSetup.SelectFirstLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Layout 1 is used
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandlerDefaultSales,SalesInvoiceReportHandler')]
    procedure OneCustomLayoutNotSelected()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] One custom layouts in system not selected
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] One custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Custom layout is not selected
        RedRepLayoutSelTestSetup.DeSelectLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Layout 1 is used
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandlerSales,SalesInvoiceReportHandler')]
    procedure TwoCustomLayoutSelected()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Two custom layouts in system, one is selected
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Two custom layouts in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Custom layout is selected
        RedRepLayoutSelTestSetup.SelectFirstLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Layout 1 is used
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandlerDefaultSales,SalesInvoiceReportHandler')]
    procedure TwoCustomLayoutNotSelected()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Two custom layouts in system, none is selected
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Two custom layouts in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Custom layout is not selected
        RedRepLayoutSelTestSetup.DeSelectLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Layout 1 is used
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure TwoLayoutsOneLayoutInLayoutSelection()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Two custom layouts in system, one is in layout selection
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Two custom layouts in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layout is selected in Selection Table
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code');

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Layout 1 is used
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure TwoLayoutsOneLayoutInLayoutSelectionWithOnlyUsage()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        Usage: Enum "Report Selection Usage";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] One selected custom layouts in system
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Report usage to test
        Usage := Usage::"S.Invoice";

        // [Given] Two custom layouts in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layout is selected in Selection Table
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code', Usage);

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Usage);

        // [THEN] Layout 1 is used
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandlerSales,SalesInvoiceReportHandler')]
    procedure TwoLayoutsTwoLayoutsInLayoutSelection()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Two custom layouts in system, two are in layout selection
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Two custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layouts are selected in Selection Table
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code');
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '2', 'Shortcut Dimension 2 Code');

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Layout 1 is used
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure TwoLayoutsOneSetAsDefault()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Two custom layouts in system, two are in layout selection
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Two custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] One Custom layout is selected as default in Selection Table
        RedRepLayoutSelTestSetup.AddDefaultLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '2');

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Layout 2 is default and should be used
        if TestResult <> '2' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure TwoLayoutsOneSetAsDefaultWithUsage()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        Usage: Enum "Report Selection Usage";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Two custom layouts in system, two are in layout selection
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Report usage to test
        Usage := Usage::"S.Invoice";

        // [Given] Two custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] One Custom layout is selected as default in Selection Table
        RedRepLayoutSelTestSetup.AddDefaultLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '2', Usage);

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Usage);

        // [THEN] Layout 2 is default and should be used
        if TestResult <> '2' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('SalesInvoiceReportHandler')]
    procedure TwoLayoutsOneSetAsDefaultWithoutLayoutCode()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Two custom layouts in system, two are in layout selection
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Two custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] One Custom layout is selected as default in Selection Table but without a selected custom layout
        RedRepLayoutSelTestSetup.AddDefaultLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '');

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Report should run with built in layout.
        if TestResult <> '' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    // [HandlerFunctions('HandleReportSelectionPage')]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandlerSales,SalesInvoiceReportHandler')]
    procedure TwoLayoutsTwoLayoutsInLayoutSelectionOneSetAsDefault()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Two custom layouts in system, two are in layout selection
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Two custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 3);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] One Custom layout is selected in Selection Table
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code');
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '2', 'Shortcut Dimension 2 Code');

        // [Given] One Custom layout is selected as default in Selection Table
        RedRepLayoutSelTestSetup.AddDefaultLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '3');

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, SalesInvoiceHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Report should run with selected layout, not the default.
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;


    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('CustomReportLayoutsSelectionPageHandlerDefaultPurchase,PurchaseInvoiceReportHandler')]
    procedure PurchasePostOneCustomLayoutNotSelected()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        RedLayoutSuppressCommit: Codeunit "Red Layout Suppress Commit";
        ReportId: Integer;
        TestResult: Code[20];
    begin
        // [FEATURE] Run Sales Post with one custom layouts in system not selected
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestPurchaseReportId();

        // [Given] One custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Custom layout is not selected
        RedRepLayoutSelTestSetup.DeSelectLayoutForReport(ReportId);

        // [GIVEN] No records in the Layout Selection Table
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);

        // [Given] Create Sales Invoice
        RedRepLayoutSelTestSetup.CreateUnpostedInvoice(PurchaseHeader);

        // [Given] Suppress Commit
        Session.BindSubscription(RedLayoutSuppressCommit);

        // [Given] Post Sales Invoice
        RedLayoutSuppressCommit.RunPurchasePost(PurchaseHeader);

        // [Given] Commit on Post activated
        RedRepLayoutSelTestSetup.ActivateCommitonPost();

        // [Given] Get sales invoice header
        GetPurchaseInvoiceHeader(PurchaseHeader, PurchInvHeader);

        // [WHEN] "Red Report Layout Selection".RunReportWithLayoutSelection is called 
        TestResult := RunReportWithLayoutSelection(ReportId, PurchInvHeader, Enum::"Report Selection Usage"::RedBlank);

        // [THEN] Layout 1 is used
        if TestResult <> '1' then
            Error(UnexpectedResultErr);
    end;

    local procedure RunReportWithLayoutSelection(ReportId: Integer; RecVarToPrint: Variant; Usage: Enum "Report Selection Usage") UsedLayout: Text
    var
        TempReportSelections: Record "Report Selections" temporary;
        RedLayoutSelection: Codeunit "Red Report Layout Selection";
    begin
        TempReportSelections.Usage := Usage;
        TempReportSelections."Report ID" := ReportId;
        TempReportSelections.Insert();
        RedLayoutSelection.RunReportWithTenantLayoutSelection(TempReportSelections, false, RecVarToPrint, UsedLayout);
    end;

    procedure GetSalesInvoiceHeader(SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        if SalesHeader."Last Posting No." = '' then
            SalesInvoiceHeader."No." := SalesHeader."No."
        else
            SalesInvoiceHeader."No." := SalesHeader."Last Posting No.";
        SalesInvoiceHeader.Find();
        SalesInvoiceHeader.SetRecFilter();
    end;

    local procedure GetPurchaseInvoiceHeader(PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        if PurchaseHeader."Last Posting No." = '' then
            PurchInvHeader."No." := PurchaseHeader."No."
        else
            PurchInvHeader."No." := PurchaseHeader."Last Posting No.";
        PurchInvHeader.SetRecFilter();
    end;

    [RequestPageHandler]
    procedure SalesInvoiceRequestPageHandler(var SalesInvoiceRequestPage: TestRequestPage "Standard Sales - Invoice")
    begin

    end;

    [ReportHandler]
    procedure SalesInvoiceReportHandler(var SalesInvoice: Report "Standard Sales - Invoice")
    begin

    end;

    [ReportHandler]
    procedure PurchaseInvoiceReportHandler(var PurchaseInvoice: Report "Purchase - Invoice")
    begin

    end;

    [ModalPageHandler]
    procedure CustomReportLayoutsSelectionPageHandlerSales(var RedReportLayouts: TestPage "Red Report Layouts")
    Var
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        NullGuid: Guid;
    begin
        // ToDo test with cancel
        RedReportLayouts.GoToKey(RedRepLayoutSelTestSetup.GetTestSalesReportId(), '1', NullGuid);
        RedReportLayouts.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CustomReportLayoutsSelectionPageHandlerDefaultSales(var RedReportLayouts: TestPage "Red Report Layouts")
    Var
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        NullGuid: Guid;
    begin
        // ToDo test with cancel
        RedReportLayouts.GoToKey(RedRepLayoutSelTestSetup.GetTestSalesReportId(), '1', NullGuid);
        RedReportLayouts.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CustomReportLayoutsSelectionPageHandlerPurchase(var RedReportLayouts: TestPage "Red Report Layouts")
    Var
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        NullGuid: Guid;
    begin
        // ToDo test with cancel
        RedReportLayouts.GoToKey(RedRepLayoutSelTestSetup.GetTestSalesReportId(), '1', NullGuid);
        RedReportLayouts.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CustomReportLayoutsSelectionPageHandlerDefaultPurchase(var RedReportLayouts: TestPage "Red Report Layouts")
    Var
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        NullGuid: Guid;
    begin
        // ToDo test with cancel
        RedReportLayouts.GoToKey(RedRepLayoutSelTestSetup.GetTestPurchaseReportId(), '1', NullGuid);
        RedReportLayouts.OK().Invoke();
    end;

    var
        UnexpectedResultErr: Label 'Unexpected result';
}