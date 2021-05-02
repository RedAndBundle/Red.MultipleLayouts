codeunit 80402 "Red Layout Import Export Test"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ExportReportLayoutSelection()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RedLayoutSelection: Record "Red Layout Selection";
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        RedLayoutSelectionExport: Codeunit "Red Layout Selection Export";
        ReportId: Integer;
        jArray: JsonArray;
    begin
        // [FEATURE] Multiple records in the Red Layout Selection table to export
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] Two custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);

        // [Given] Get first Sales Invoice
        SalesInvoiceHeader.FindFirst();

        // [Given] Custom layouts are selected in Selection Table
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code');
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '2', 'Shortcut Dimension 2 Code');

        // [WHEN] Codeunit 11310866 "Red Layout Selection Export" is run
        RedLayoutSelectionExport.CreateJsonFromRecords(RedLayoutSelection, jArray, false, false);

        // [THEN] JsonArray matches RedLayoutSelection records
        CheckExportMatchesOriginalRecords(RedLayoutSelection, jArray)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedCustomLayoutExistsInSystem()
    var
        TempRedLayoutSelection: Record "Red Layout Selection" temporary;
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        RedLayoutSelectionImport: Codeunit "Red Layout Selection Import";
        ReportId: Integer;
    begin
        // [FEATURE] Imported custom layout exists in the system
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Custom layout exists in import
        RedLayoutSelectTestSetup.CreateTempRedLayoutSelection(TempRedLayoutSelection, ReportId, Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported layouts are created
        RedLayoutSelectionImport.CreateCustomReportLayouts(TempRedLayoutSelection);

        // [THEN] No new custom layout created
        CheckCustomReportLayoutsCreated(ReportId, 1);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedCustomLayoutNotExistsInSystem()
    var
        TempRedLayoutSelection: Record "Red Layout Selection" temporary;
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        RedLayoutSelectionImport: Codeunit "Red Layout Selection Import";
        ReportId: Integer;
    begin
        // [FEATURE] Imported custom layout exists in the system
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] Custom layout exists in import
        RedLayoutSelectTestSetup.CreateTempRedLayoutSelection(TempRedLayoutSelection, ReportId, Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported layouts are created
        RedLayoutSelectionImport.CreateCustomReportLayouts(TempRedLayoutSelection);

        // [THEN] New custom layout created
        CheckCustomReportLayoutsCreated(ReportId, 1);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedCustomLayoutExistsInSystemForWrongReport()
    var
        TempRedLayoutSelection: Record "Red Layout Selection" temporary;
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        RedLayoutSelectionImport: Codeunit "Red Layout Selection Import";
        ReportId: Integer;
    begin
        // [FEATURE] Imported custom layout exists in the system with the wrong report id
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Custom layout exists in import
        RedLayoutSelectTestSetup.CreateTempRedLayoutSelection(TempRedLayoutSelection, RedLayoutSelectTestSetup.GetAltTestReportId(), Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported layouts are created
        asserterror RedLayoutSelectionImport.CreateCustomReportLayouts(TempRedLayoutSelection);

        // [THEN] Wrong report id error thrown
        VerifyCustReportLayoutDoesNotMatchReportIdErr('1');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedRedLayoutSelectionDoesNotExist()
    var
        TempRedLayoutSelection: Record "Red Layout Selection" temporary;
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        RedLayoutSelectionImport: Codeunit "Red Layout Selection Import";
        ReportId: Integer;
        QtyImported: Integer;
    begin
        // [FEATURE] Imported Red Layout Selection does not exist
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Imported red layout selection in Temp table
        RedLayoutSelectTestSetup.CreateTempRedLayoutSelection(TempRedLayoutSelection, ReportId, Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported red layout selection is created
        RedLayoutSelectionImport.InsertRedLayoutSelection(TempRedLayoutSelection, QtyImported);

        // [THEN] Wrong report id error thrown
        VerifyRedLayoutSelectionCreated(QtyImported, 1);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportedRedLayoutSelectionDoesExist()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempRedLayoutSelection: Record "Red Layout Selection" temporary;
        RedLayoutSelectTestSetup: Codeunit "Red Layout Select Test Setup";
        RedLayoutSelectionImport: Codeunit "Red Layout Selection Import";
        ReportId: Integer;
        QtyImported: Integer;
    begin
        // [FEATURE] Imported Red Layout Selection does exist
        // [Given] Report Id to test
        ReportId := RedLayoutSelectTestSetup.GetTestReportId();

        // [Given] One custom layout in system
        RedLayoutSelectTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);

        // [Given] Red layout selection exists
        RedLayoutSelectTestSetup.AddLayoutToSelectionTable(SalesInvoiceHeader, ReportId, '1', 'Shortcut Dimension 1 Code');

        // [Given] Imported red layout selection in Temp table
        RedLayoutSelectTestSetup.CreateTempRedLayoutSelection(TempRedLayoutSelection, ReportId, Database::"Sales Invoice Header", 'Shortcut Dimension 1 Code', 1);

        // [WHEN] Imported red layout selection is created
        RedLayoutSelectionImport.InsertRedLayoutSelection(TempRedLayoutSelection, QtyImported);

        // [THEN] Wrong report id error thrown
        VerifyRedLayoutSelectionCreated(QtyImported, 0);
    end;

    local procedure CheckExportMatchesOriginalRecords(RedLayoutSelection: Record "Red Layout Selection"; jArray: JsonArray): Boolean
    var
        TempRedLayoutSelection: Record "Red Layout Selection" temporary;
        RedLayoutSelectionImport: Codeunit "Red Layout Selection Import";
    begin
        RedLayoutSelectionImport.CreateTempRedLayoutSelectionFromJson(TempRedLayoutSelection, jArray);
        TempRedLayoutSelection.FindSet();
        repeat
            RedLayoutSelection.Get(TempRedLayoutSelection."Report ID", TempRedLayoutSelection."Custom Report Layout Code", TempRedLayoutSelection."Table No.", TempRedLayoutSelection."Field No.");
            if RedLayoutSelection.Value <> TempRedLayoutSelection.Value then
                Error(ValueMismatchErr);

        until TempRedLayoutSelection.Next() = 0;
    end;

    local procedure CheckCustomReportLayoutsCreated(ReportId: Integer; NoOfLayouts: Integer)
    var
        CustomReportLayout: Record "Custom Report Layout";
        i: Integer;
    begin

        for i := 1 to NoOfLayouts do begin
            CustomReportLayout.Get(Format(i));
            if CustomReportLayout."Report ID" <> ReportId then
                Error(WrongReportIdErr);
        end;
    end;

    local procedure VerifyCustReportLayoutDoesNotMatchReportIdErr(CustomLayoutCode: Code[20])
    var
        CustReportLayoutDoesNotMatchReportIdErr: Label 'Custom Report Layout %1 has the Wrong report ID', Comment = '%1 = the report layout for the new record';
    begin
        if GetLastErrorText <> StrSubstNo(CustReportLayoutDoesNotMatchReportIdErr, CustomLayoutCode) then
            Error(GetLastErrorText);
    end;

    local procedure VerifyRedLayoutSelectionCreated(QtyImported: Integer; QtyExpected: Integer)
    begin
        if QtyImported <> QtyExpected then
            Error(ImportQuantityMismatchErr);
    end;

    var
        ValueMismatchErr: Label 'Imported value does not match original value';
        WrongReportIdErr: Label 'The CUstom Report Layout has the wrong report id';
        ImportQuantityMismatchErr: Label 'Then imported quantity does not match the expected quantity';
}