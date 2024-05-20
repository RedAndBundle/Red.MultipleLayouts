codeunit 11310871 "Red Tenant Report Layout"
{
    Access = Internal;

    procedure InitBuiltInLayout(var TenantReportLayout: Record "Tenant Report Layout"; ReportId: Integer; Name: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        is: InStream;
    begin
        TenantReportLayout.Init();
        TenantReportLayout.Name := Name;
        TenantReportLayout."Report ID" := ReportId;
        TenantReportLayout.Description := TenantReportLayout.Name;
        TenantReportLayout."Layout Format" := TenantReportLayout."Layout Format"::RDLC;
        GetBuiltinLayout(ReportId, TempBlob);
        TempBlob.CreateInStream(is);
        TenantReportLayout.Layout.ImportStream(is, TenantReportLayout.Description);
        TenantReportLayout.Insert();
    end;

    procedure GetBuiltinLayout(ReportId: Integer; var TempBlob: Codeunit "Temp Blob")
    var
        ReportLayoutList: Record "Report Layout List";
        os: OutStream;
    begin
        ReportLayoutList.SetRange("Report ID", ReportId);
        ReportLayoutList.SetRange("User Defined", false);
        ReportLayoutList.SetRange("Layout Format", ReportLayoutList."Layout Format"::RDLC);
        ReportLayoutList.FindFirst();
        TempBlob.CreateOutStream(os);
        ReportLayoutList.Layout.ExportStream(os);
    end;

    procedure GetLayoutNameFromCustomLayoutCode(CustomLayoutCode: Code[50]): Text
    var
        CustomReportLayoutTokLbl: Label 'CRL';
    begin
        exit(CustomLayoutCode + '-' + CustomReportLayoutTokLbl);
    end;

    procedure GetDefaultTableForReport(ReportId: Integer) TableNo: Integer
    var
        ReportDataItems: Record "Report Data Items";
    begin
        ReportDataItems.SetRange("Report ID", ReportId);
        ReportDataItems.SetRange("Indentation Level", 0);
        ReportDataItems.SetFilter(Name, '<>@*args*');
        if ReportDataItems.FindFirst() then
            exit(ReportDataItems."Related Table ID");
    end;
}