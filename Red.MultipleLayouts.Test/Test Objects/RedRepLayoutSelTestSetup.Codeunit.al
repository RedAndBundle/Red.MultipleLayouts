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
        // TenantReportLayout: Record "Tenant Report Layout";
        TenantReportLayout: Record "Tenant Report Layout";
        TempBlob: Codeunit "Temp Blob";
        RedTenantReportLayout: Codeunit "Red Tenant Report Layout";
        // TenantReportLayout: Record "Tenant Report Layout";
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
            RedTenantReportLayout.GetBuiltinLayout(ReportId, TempBlob);
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

        if not TenantReportLayoutSelection.Get(TenantReportLayout."Report ID", CompanyName, NullGuid) then begin
            TenantReportLayoutSelection."Report ID" := TenantReportLayout."Report ID";
            TenantReportLayoutSelection.Insert(true);
        end;
        TenantReportLayoutSelection."Layout Name" := TenantReportLayout.Name;
        TenantReportLayoutSelection.Modify();

        // if not TenantReportLayoutSelection.Get(ReportId, CompanyName) then begin
        //     TenantReportLayoutSelection.Validate("Report ID", ReportId);
        //     TenantReportLayoutSelection.Validate("Company Name", CompanyName);
        //     TenantReportLayoutSelection.Insert();
        // end;
        // TenantReportLayoutSelection.Validate(Type, TenantReportLayoutSelection.Type::"Custom Layout");
        // TenantReportLayoutSelection.Validate("Custom Report Layout Code", TenantReportLayout.Code);
        // TenantReportLayoutSelection.Modify();
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

    procedure AddLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; TenantReportLayout: Text; SourceFieldName: Text)
    begin
        AddLayoutToSelectionTable(RecVar, ReportId, TenantReportLayout, SourceFieldName, "Report Selection Usage"::RedBlank);
    end;

    procedure AddLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; TenantReportLayout: Text; SourceFieldName: Text; Usage: Enum "Report Selection Usage")
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
        RedReportLayoutSelection."Layout Name" := TenantReportLayout;
        RedReportLayoutSelection.Validate("Report Selection Usage", Usage);
        RedReportLayoutSelection.Validate("Table No.", RecRef.Number);
        RedReportLayoutSelection.Validate("Field No.", FldRef.Number);
        RedReportLayoutSelection.Validate(Value, FldRef.Value);
        RedReportLayoutSelection.Insert();
    end;

    procedure AddDefaultLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; TenantReportLayout: Text)
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        RedReportLayoutSelection.Validate("Report ID", ReportId);
        RedReportLayoutSelection.Validate(Default, true);
        if TenantReportLayout <> '' then
            RedReportLayoutSelection."Layout Name" := TenantReportLayout;
        RedReportLayoutSelection.Insert();
    end;

    procedure AddDefaultLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; TenantReportLayout: Text; Usage: Enum "Report Selection Usage")
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
    begin
        RedReportLayoutSelection.Validate("Report ID", ReportId);
        RedReportLayoutSelection.Validate(Default, true);
        RedReportLayoutSelection.Validate("Report Selection Usage", Usage);
        if TenantReportLayout <> '' then
            RedReportLayoutSelection."Layout Name" := TenantReportLayout;
        RedReportLayoutSelection.Insert();
    end;

    // procedure EnsureReportSelectedInReportSelection(ReportId: Integer; Usage: Enum "Report Selection Usage")
    // var
    //     ReportSelections: Record "Report Selections";
    // begin
    //     ReportSelections.SetRange(Usage, Usage);
    //     ReportSelections.DeleteAll();
    //     ReportSelections.Init();
    //     ReportSelections.InsertRecord(Usage, '1', ReportId);
    // end;

    procedure GetTestSalesReportId(): Integer
    begin
        exit(Report::"Standard Sales - Invoice");
    end;

    procedure GetTestPurchaseReportId(): Integer
    begin
        exit(Report::"Purchase - Invoice");
    end;

    procedure GetAltTestReportId(): Integer
    begin
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
            TempRedReportLayoutSelection."Layout Name" := Format(i);
            TempRedReportLayoutSelection.Validate("Table No.", TableId);
            TempRedReportLayoutSelection.Validate("Field No.", Field."No.");
            TempRedReportLayoutSelection.Insert();
        end;
    end;
}