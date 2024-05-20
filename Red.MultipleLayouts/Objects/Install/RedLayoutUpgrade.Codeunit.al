codeunit 11310872 "Red Layout Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnCheckPreconditionsPerCompany()
    begin
    end;

    trigger OnUpgradePerCompany()
    var
        RedLayoutTelemetry: Codeunit "Red Layout Telemetry";
        RedLayoutSelection: Codeunit "Red Layout Selection";
    begin
        RedLayoutTelemetry.LogInstall();
        RedLayoutSelection.MoveToTenantLayout();
    end;

    trigger OnValidateUpgradePerCompany()
    begin
    end;

    trigger OnUpgradePerDatabase()
    begin
    end;

    // local procedure Upgrade3000()
    // var
    //     UpgradeTag: Codeunit "Upgrade Tag";
    //     UpgradeTagLbl: Label 'Red Layout 3.0.0.0';
    // begin
    //     if UpgradeTag.HasUpgradeTag(UpgradeTagLbl, CompanyName) then
    //         exit;

    //     UpgradeTag.SetUpgradeTag(UpgradeTagLbl);
    // end;

    procedure MigrateCustomReportLayouts(ReportId: Integer)
    var
        CustomReportLayout: Record "Custom Report Layout";
        TenantReportLayout: Record "Tenant Report Layout";
        RedTenantReportLayout: CodeUnit "Red Tenant Report Layout";
        InStreamLayout: Instream;
    begin
        if ReportId <> 0 then
            CustomReportLayout.SetRange("Report ID", ReportId);
        CustomReportLayout.SetRange("Built-In", false);
        CustomReportLayout.SetAutoCalcFields(Layout);
        if CustomReportLayout.FindSet() then
            repeat
                TenantReportLayout.Init();
                CustomReportLayout.Layout.CreateInStream(InStreamLayout);
                TenantReportLayout.Layout.ImportStream(InStreamLayout, CustomReportLayout.Description);

                TenantReportLayout."Report ID" := CustomReportLayout."Report ID";

                TenantReportLayout.Name := RedTenantReportLayout.GetLayoutNameFromCustomLayoutCode(CustomReportLayout.Code);
                TenantReportLayout.Description := CustomReportLayout.Description;
                TenantReportLayout."Company Name" := CustomReportLayout."Company Name";

                // Assign the Layout-Format.
                case CustomReportLayout.Type of
                    CustomReportLayout.Type::RDLC:
                        TenantReportLayout."Layout Format" := TenantReportLayout."Layout Format"::RDLC;
                    CustomReportLayout.Type::Word:
                        TenantReportLayout."Layout Format" := TenantReportLayout."Layout Format"::Word
                    else
                        TenantReportLayout."Layout Format" := TenantReportLayout."Layout Format"::Custom;
                end;

                // Assign the File-Format if the layout format is 'Custom'/'External' (UI)
                if (CustomReportLayout."File Extension" <> '') and (TenantReportLayout."Layout Format" = TenantReportLayout."Layout Format"::Custom) then
                    TenantReportLayout."MIME Type" := 'reportlayout/' + CustomReportLayout."File Extension";

                if TenantReportLayout.Insert() then
                    CustomReportLayout.Delete();
            until (CustomReportLayout.Next() = 0);
    end;
}