codeunit 80507 "Red Rep Layout Sel. Test Setup"
{
    Permissions =
        tabledata "Red Layout Setup" = RIMD,
        tabledata "Red Report Layout Selection" = RIMD;

    procedure CreateUnpostedInvoice(var PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
    begin
        Vendor.FindFirst();
        Item.SetRange("Item Tracking Code", '');
        Item.FindFirst();

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.Insert(true);
        PurchaseHeader."Vendor Invoice No." := PurchaseHeader."No.";
        PurchaseHeader.Modify(true);

        PurchaseLine.Init();
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Line No." := 10000;
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine.Validate("No.", Item."No.");
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Insert(true);
    end;

    procedure ActivateCommitonPost()
    var
        RedLayoutSetup: Record "Red Layout Setup";
    begin
        RedLayoutSetup.InitSetup();
        RedLayoutSetup."Commit on Post" := true;
        RedLayoutSetup.Modify();
    end;

    procedure EnsureCustomLayoutsForReport(ReportId: Integer; NoOfLayouts: Integer)
    var
        TenantReportLayout: Record "Tenant Report Layout";
        TempBlob: Codeunit "Temp Blob";
        RedTenantReportLayout: Codeunit "Red Tenant Report Layout";
        i: Integer;
        is: InStream;
    begin
        TenantReportLayout.SetRange("Report ID", ReportId);
        TenantReportLayout.DeleteAll();
        for i := 1 to NoOfLayouts do begin
            TenantReportLayout.Init();
            TenantReportLayout.Name := Format(i);
            TenantReportLayout."Report ID" := ReportId;
            TenantReportLayout.Description := Format(i);
            TenantReportLayout."Layout Format" := TenantReportLayout."Layout Format"::RDLC;
            if not RedTenantReportLayout.GetBuiltinLayout(ReportId, TempBlob) then
                RedTenantReportLayout.GetEmptyRdlcLayout(TempBlob);
            TempBlob.CreateInStream(is);
            TenantReportLayout.Layout.ImportStream(is, TenantReportLayout.Description);
            TenantReportLayout.Insert();
        end;
    end;

    procedure SelectFirstLayoutForReport(ReportId: Integer)
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        TenantReportLayout: Record "Tenant Report Layout";
        NullGuid: Guid;
    begin
        TenantReportLayout.SetRange("Report ID", ReportId);
        TenantReportLayout.FindFirst();

        if TenantReportLayoutSelection.Get(TenantReportLayout."Report ID", CompanyName, NullGuid) then
            TenantReportLayoutSelection.Delete();

        TenantReportLayoutSelection."Report ID" := TenantReportLayout."Report ID";
        TenantReportLayoutSelection."Layout Name" := TenantReportLayout.Name;
        TenantReportLayoutSelection."Company Name" := CompanyName;
        TenantReportLayoutSelection.Insert(true);
    end;

    procedure DeSelectLayoutForReport(ReportId: Integer)
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
    begin
        TenantReportLayoutSelection.SetRange("Report ID", ReportId);
        TenantReportLayoutSelection.DeleteAll();
    end;

    procedure EnsureNoLayoutInSelectionTable(ReportId: Integer)
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        RedReportLayoutSelection.SetRange(RedReportLayoutSelection."Report ID", ReportId);
        RedReportLayoutSelection.DeleteAll();
    end;

    procedure AddLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; LineNo: Integer; SourceFieldName: Text; Usage: Enum "Report Selection Usage"; UseFilter: Boolean)
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
        Field: Record Field;
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        RecRef.GetTable(RecVar);
        Field.SetRange(TableNo, RecRef.Number);
        Field.SetRange(FieldName, SourceFieldName);
        Field.FindFirst();
        FldRef := RecRef.Field(Field."No.");

        RedReportLayoutSelection.Validate("Report ID", ReportId);
        RedReportLayoutSelection."Line No." := LineNo;
        RedReportLayoutSelection."Layout Name" := Format(LineNo);
        RedReportLayoutSelection.Validate("Report Selection Usage", Usage);
        RedReportLayoutSelection.Validate("Table No.", RecRef.Number);
        RedReportLayoutSelection.Validate("Field No.", FldRef.Number);
        if UseFilter then
            RedReportLayoutSelection.Validate(Value, StrSubstNo('@*%1*', Format(FldRef.Value).Remove(4).ToLower()))
        else
            RedReportLayoutSelection.Validate(Value, FldRef.Value);
        RedReportLayoutSelection.Insert();
    end;

    procedure AddDefaultLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; TenantReportLayout: Text)
    begin
        AddDefaultLayoutToSelectionTable(RecVar, ReportId, TenantReportLayout, "Report Selection Usage"::RedBlank);
    end;

    procedure AddDefaultLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; TenantReportLayout: Text; Usage: Enum "Report Selection Usage")
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        RedReportLayoutSelection.Validate("Report ID", ReportId);
        if Evaluate(RedReportLayoutSelection."Line No.", TenantReportLayout) then;
        RedReportLayoutSelection.Validate("Report Selection Usage", Usage);
        RedReportLayoutSelection.Validate(Default, true);
        if TenantReportLayout <> '' then
            RedReportLayoutSelection."Layout Name" := TenantReportLayout;
        RedReportLayoutSelection.Insert();
    end;

    procedure GetTestSalesReportId(): Integer
    begin
        exit(Report::"Standard Sales - Invoice");
    end;

    procedure GetTestWhseReportId(): Integer
    begin
        exit(Report::"Red Test Whse. Shipment");
    end;

    procedure CreateWarehouseShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        TestShipmentNoTok: Label 'REDTEST01', Locked = true;
    begin
        if WarehouseShipmentHeader.Get(TestShipmentNoTok) then
            exit;

        WarehouseShipmentHeader.Init();
        WarehouseShipmentHeader."No." := TestShipmentNoTok;
        WarehouseShipmentHeader.Insert(false);
    end;

    procedure GetTestNoBuiltInLayoutReportId(): Integer
    begin
        exit(Report::"Red Test Sales Invoice");
    end;

    procedure GetTestPurchaseReportId(): Integer
    begin
        exit(Report::"Purchase - Invoice");
    end;

    procedure GetAltTestReportId(): Integer
    begin
        // BC29: the built-in RDLC of this report references GlobalLocationNumber columns that are missing
        // from its dataset and cannot be copied to a tenant layout; the import creates a blank layout instead.
        exit(Report::"Standard Sales - Order Conf.");
    end;

    procedure CreateTempRedReportLayoutSelection(var TempRedReportLayoutSelection: Record "Red Report Layout Selection"; ReportId: Integer; TableId: Integer; SourceFieldName: Text; NoOfLayouts: Integer)
    var
        Field: Record Field;
        i: Integer;
    begin
        Field.SetRange(TableNo, TableId);
        Field.SetRange(FieldName, SourceFieldName);
        Field.FindFirst();

        for i := 1 to NoOfLayouts do begin
            TempRedReportLayoutSelection.Init();
            TempRedReportLayoutSelection.Validate("Report ID", ReportId);
            TempRedReportLayoutSelection."Line No." := i;
            TempRedReportLayoutSelection."Layout Name" := Format(i);
            TempRedReportLayoutSelection.Validate("Table No.", TableId);
            TempRedReportLayoutSelection.Validate("Field No.", Field."No.");
            TempRedReportLayoutSelection.Insert();
        end;
    end;
}