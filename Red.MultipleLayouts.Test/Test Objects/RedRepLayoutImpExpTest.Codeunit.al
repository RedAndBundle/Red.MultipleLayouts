codeunit 80508 "Red Rep. Layout Imp. Exp. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ExportTenantReportLayoutSelection()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedReportLayoutSelection: Record "Red Report Layout Selection";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        RedRepLayoutSelectionExp: Codeunit "Red Rep Layout Selection Exp.";
        ReportId: Integer;
        jArray: JsonArray;
    begin
        // [FEATURE] Multiple records in the Red Layout Selection table to export
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Two custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layouts are selected in Selection Table
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, 1, 'Shortcut Dimension 1 Code', Enum::"Report Selection Usage"::RedBlank, false);
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, 2, 'Shortcut Dimension 2 Code', Enum::"Report Selection Usage"::RedBlank, false);

        // [WHEN] Codeunit 11310866 "Red Layout Selection Export" is run
        RedRepLayoutSelectionExp.CreateJsonFromRecords(RedReportLayoutSelection, jArray, false, false);

        // [THEN] JsonArray matches RedReportLayoutSelection records
        CheckExportMatchesOriginalRecords(RedReportLayoutSelection, jArray)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedCustomLayoutExistsInSystem()
    var
        TempRedReportLayoutSelection: Record "Red Report Layout Selection" temporary;
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        RedRepLayoutSelectionImp: Codeunit "Red Rep Layout Selection Imp.";
        ReportId: Integer;
    begin
        // [FEATURE] Imported custom layout exists in the system
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] One custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Custom layout exists in import
        RedRepLayoutSelTestSetup.CreateTempRedReportLayoutSelection(TempRedReportLayoutSelection, ReportId, Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported layouts are created
        RedRepLayoutSelectionImp.CreateCustomReportLayouts(TempRedReportLayoutSelection);

        // [THEN] No new custom layout created
        CheckCustomReportLayoutsCreated(ReportId, 1);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedCustomLayoutNotExistsInSystem()
    var
        TempRedReportLayoutSelection: Record "Red Report Layout Selection" temporary;
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        RedRepLayoutSelectionImp: Codeunit "Red Rep Layout Selection Imp.";
        ReportId: Integer;
    begin
        // [FEATURE] Imported custom layout exists in the system
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] Custom layout exists in import
        RedRepLayoutSelTestSetup.CreateTempRedReportLayoutSelection(TempRedReportLayoutSelection, ReportId, Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported layouts are created
        RedRepLayoutSelectionImp.CreateCustomReportLayouts(TempRedReportLayoutSelection);

        // [THEN] New custom layout created
        CheckCustomReportLayoutsCreated(ReportId, 1);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedCustomLayoutExistsInSystemForWrongReport()
    var
        TempRedReportLayoutSelection: Record "Red Report Layout Selection" temporary;
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        RedRepLayoutSelectionImp: Codeunit "Red Rep Layout Selection Imp.";
        ReportId: Integer;
    begin
        // [FEATURE] Imported custom layout exists in the system with the wrong report id
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] One custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [When] Custom layout exists in import
        RedRepLayoutSelTestSetup.CreateTempRedReportLayoutSelection(TempRedReportLayoutSelection, RedRepLayoutSelTestSetup.GetAltTestReportId(), Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [Then] Imported layouts are created
        RedRepLayoutSelectionImp.CreateCustomReportLayouts(TempRedReportLayoutSelection);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedRedReportLayoutSelectionDoesNotExist()
    var
        TempRedReportLayoutSelection: Record "Red Report Layout Selection" temporary;
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        RedRepLayoutSelectionImp: Codeunit "Red Rep Layout Selection Imp.";
        ReportId: Integer;
        QtyImported: Integer;
    begin
        // [FEATURE] Imported Red Layout Selection does not exist
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] One custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Imported red layout selection in Temp table
        RedRepLayoutSelTestSetup.CreateTempRedReportLayoutSelection(TempRedReportLayoutSelection, ReportId, Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported red layout selection is created
        RedRepLayoutSelectionImp.InsertRedReportLayoutSelection(TempRedReportLayoutSelection, QtyImported);

        // [THEN] Wrong report id error thrown
        VerifyRedReportLayoutSelectionCreated(QtyImported, 1);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedRedReportLayoutSelectionDoesExist()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempRedReportLayoutSelection: Record "Red Report Layout Selection" temporary;
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        RedRepLayoutSelectionImp: Codeunit "Red Rep Layout Selection Imp.";
        ReportId: Integer;
        QtyImported: Integer;
    begin
        // [FEATURE] Imported Red Layout Selection does exist
        // [Given] Report Id to test
        ReportId := RedRepLayoutSelTestSetup.GetTestSalesReportId();

        // [Given] One custom layout in system
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Red layout selection exists
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, 1, 'Shortcut Dimension 1 Code', Enum::"Report Selection Usage"::RedBlank, false);

        // [Given] Imported red layout selection in Temp table
        RedRepLayoutSelTestSetup.CreateTempRedReportLayoutSelection(TempRedReportLayoutSelection, ReportId, Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported red layout selection is created
        RedRepLayoutSelectionImp.InsertRedReportLayoutSelection(TempRedReportLayoutSelection, QtyImported);

        // [THEN] Wrong report id error thrown
        VerifyRedReportLayoutSelectionCreated(QtyImported, 0);
    end;

    local procedure CheckExportMatchesOriginalRecords(RedReportLayoutSelection: Record "Red Report Layout Selection"; jArray: JsonArray): Boolean
    var
        TempRedReportLayoutSelection: Record "Red Report Layout Selection" temporary;
        RedRepLayoutSelectionImp: Codeunit "Red Rep Layout Selection Imp.";
    begin
        RedRepLayoutSelectionImp.CreateTempRedReportLayoutSelectionFromJson(TempRedReportLayoutSelection, jArray);
        TempRedReportLayoutSelection.FindSet();
        repeat
            RedReportLayoutSelection.Get(TempRedReportLayoutSelection."Report ID", TempRedReportLayoutSelection."Line No.");
            if RedReportLayoutSelection.Value <> TempRedReportLayoutSelection.Value then
                Error(ValueMismatchErr);

        until TempRedReportLayoutSelection.Next() = 0;
    end;

    local procedure CheckCustomReportLayoutsCreated(ReportId: Integer; NoOfLayouts: Integer)
    var
        TenantReportLayout: Record "Tenant Report Layout";
        i: Integer;
    begin

        for i := 1 to NoOfLayouts do begin
            TenantReportLayout.Get(ReportId, Format(i));
            if TenantReportLayout."Report ID" <> ReportId then
                Error(WrongReportIdErr);
        end;
    end;

    local procedure VerifyRedReportLayoutSelectionCreated(QtyImported: Integer; QtyExpected: Integer)
    begin
        if QtyImported <> QtyExpected then
            Error(ImportQuantityMismatchErr);
    end;

    var
        ValueMismatchErr: Label 'Imported value does not match original value';
        WrongReportIdErr: Label 'The CUstom Report Layout has the wrong report id';
        ImportQuantityMismatchErr: Label 'Then imported quantity does not match the expected quantity';
}