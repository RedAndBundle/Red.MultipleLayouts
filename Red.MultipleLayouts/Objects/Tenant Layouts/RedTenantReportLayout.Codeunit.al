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

    //     procedure GetDefaultCode(ReportID: Integer): Code[20]
    //     var
    //         CustomReportLayout: Record "Custom Report Layout";
    //         NewCode: Code[20];
    //     begin
    // #pragma warning disable AA0217
    //         CustomReportLayout.SetRange("Report ID", ReportID);
    //         CustomReportLayout.SetFilter(Code, StrSubstNo('%1-*', ReportID));
    //         if CustomReportLayout.FindLast() then
    //             NewCode := IncStr(CustomReportLayout.Code)
    //         else
    //             NewCode := StrSubstNo('%1-000001', ReportID);

    //         exit(NewCode);
    // #pragma warning restore AA0217
    //     end;
}