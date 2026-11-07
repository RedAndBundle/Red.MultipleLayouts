codeunit 80509 "Red Whse. Layout Sel. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure WhseNoLayoutForReport()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
    begin
        // [FEATURE] Warehouse report without any layouts
        // [GIVEN] Warehouse test report without layouts and no layout selection records
        ReportId := RedRepLayoutSelTestSetup.GetTestWhseReportId();
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 0);
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);
        RedRepLayoutSelTestSetup.CreateWarehouseShipment(WarehouseShipmentHeader);

        // [WHEN] The report is run with layout selection for "any usage"
        // [THEN] No layout is used, so the standard print is not handled
        if RunReportWithLayoutSelection(ReportId, WarehouseShipmentHeader) <> '' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('WhseShipmentReportHandler')]
    procedure WhseOneLayoutUsed()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
    begin
        // [FEATURE] Warehouse report with one tenant layout
        // [GIVEN] One tenant layout and no layout selection records
        ReportId := RedRepLayoutSelTestSetup.GetTestWhseReportId();
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 1);
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);
        RedRepLayoutSelTestSetup.CreateWarehouseShipment(WarehouseShipmentHeader);

        // [WHEN] The report is run with layout selection
        // [THEN] Layout 1 is used
        if RunReportWithLayoutSelection(ReportId, WarehouseShipmentHeader) <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('WhseShipmentReportHandler')]
    procedure WhseRedBlankRowMatches()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
    begin
        // [FEATURE] A "Red Blank" (any usage) selection row applies to warehouse prints
        // [GIVEN] Two tenant layouts and a Red Blank row on the shipment No. pointing to layout 2
        ReportId := RedRepLayoutSelTestSetup.GetTestWhseReportId();
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);
        RedRepLayoutSelTestSetup.CreateWarehouseShipment(WarehouseShipmentHeader);
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(WarehouseShipmentHeader, ReportId, 2, 'No.', Enum::"Report Selection Usage"::RedBlank, false);

        // [WHEN] The report is run with layout selection
        // [THEN] Layout 2 is used
        if RunReportWithLayoutSelection(ReportId, WarehouseShipmentHeader) <> '2' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CustomReportLayoutsSelectionStrMenuDefault,WhseShipmentReportHandler')]
    procedure WhseSpecificUsageRowIgnored()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        ReportId: Integer;
    begin
        // [FEATURE] Selection rows with a specific usage do not apply to warehouse prints
        // [GIVEN] Two tenant layouts and a sales invoice usage row on the shipment No. pointing to layout 2
        ReportId := RedRepLayoutSelTestSetup.GetTestWhseReportId();
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);
        RedRepLayoutSelTestSetup.CreateWarehouseShipment(WarehouseShipmentHeader);
        RedRepLayoutSelTestSetup.AddLayoutToSelectionTable(WarehouseShipmentHeader, ReportId, 2, 'No.', Enum::"Report Selection Usage"::"S.Invoice", false);

        // [WHEN] The report is run with layout selection
        // [THEN] The row is ignored, the user picks from all layouts and layout 1 is chosen
        if RunReportWithLayoutSelection(ReportId, WarehouseShipmentHeader) <> '1' then
            Error(UnexpectedResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure WhseDefaultLayoutSelected()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        RedRepLayoutSelTestSetup: Codeunit "Red Rep Layout Sel. Test Setup";
        RedReportLayoutSelection: Codeunit "Red Report Layout Selection";
        DesignTimeReportSelection: Codeunit "Design-time Report Selection";
        ReportId: Integer;
        SelectedLayout: Text;
    begin
        // [FEATURE] The default layout is selected for a warehouse document, without running the report
        // [GIVEN] Two tenant layouts and a default layout 1 for "any usage"
        ReportId := RedRepLayoutSelTestSetup.GetTestWhseReportId();
        RedRepLayoutSelTestSetup.EnsureCustomLayoutsForReport(ReportId, 2);
        RedRepLayoutSelTestSetup.EnsureNoLayoutInSelectionTable(ReportId);
        RedRepLayoutSelTestSetup.CreateWarehouseShipment(WarehouseShipmentHeader);
        RedRepLayoutSelTestSetup.AddDefaultLayoutToSelectionTable(WarehouseShipmentHeader, ReportId, '1');

        // [WHEN] The layout is selected the way the warehouse print subscriber does it (usage Red Blank)
        RedReportLayoutSelection.SetTenantReportLayoutSelection(WarehouseShipmentHeader, ReportId, Enum::"Report Selection Usage"::RedBlank);
        SelectedLayout := DesignTimeReportSelection.GetSelectedLayout();
        DesignTimeReportSelection.ClearLayoutSelection();

        // [THEN] Layout 1 is selected
        if SelectedLayout <> '1' then
            Error(UnexpectedSelectionErr, SelectedLayout);
    end;

    local procedure RunReportWithLayoutSelection(ReportId: Integer; RecVarToPrint: Variant) UsedLayout: Text
    var
        RedReportLayoutSelection: Codeunit "Red Report Layout Selection";
    begin
        RedReportLayoutSelection.RunReportWithTenantLayoutSelection(ReportId, Enum::"Report Selection Usage"::RedBlank, false, RecVarToPrint, UsedLayout);
    end;

    [ReportHandler]
    procedure WhseShipmentReportHandler(var RedTestWhseShipment: Report "Red Test Whse. Shipment")
    begin
    end;

    [StrMenuHandler]
    procedure CustomReportLayoutsSelectionStrMenuDefault(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    var
        OptionList: List of [Text];
    begin
        OptionList := Options.Split(',');
        Choice := OptionList.IndexOf('1');
    end;

    var
        UnexpectedResultErr: Label 'Unexpected result';
        UnexpectedSelectionErr: Label 'Expected layout 1 to be selected, but the selected layout is ''%1''.', Comment = '%1 = selected layout name';
}
