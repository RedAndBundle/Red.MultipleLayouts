codeunit 11310871 "Red Tenant Report Layout"
{
    Access = Internal;

    /// <summary>
    /// Creates a blank RDLC tenant layout as a placeholder, e.g. for layouts referenced in an import file.
    /// The built-in layout is not copied: its RDLC is validated against the report dataset on import and
    /// some BC29 standard layouts fail that validation (Standard Sales - Order Conf., Quote, Credit Memo, Draft Invoice).
    /// </summary>
    procedure InitBlankLayout(var TenantReportLayout: Record "Tenant Report Layout"; ReportId: Integer; Name: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        is: InStream;
    begin
        TenantReportLayout.Init();
        TenantReportLayout.Name := Name;
        TenantReportLayout."Report ID" := ReportId;
        TenantReportLayout.Description := TenantReportLayout.Name;
        TenantReportLayout."Layout Format" := TenantReportLayout."Layout Format"::RDLC;
        GetEmptyRdlcLayout(TempBlob);
        TempBlob.CreateInStream(is);
        TenantReportLayout.Layout.ImportStream(is, TenantReportLayout.Description);
        TenantReportLayout.Insert();
    end;

    /// <summary>
    /// Gets the first built-in RDLC layout of the report. Returns false if the report has none, e.g. when it only has Word layouts.
    /// </summary>
    procedure GetBuiltinLayout(ReportId: Integer; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        ReportLayoutList: Record "Report Layout List";
        os: OutStream;
    begin
        ReportLayoutList.SetRange("Report ID", ReportId);
        ReportLayoutList.SetRange("User Defined", false);
        ReportLayoutList.SetRange("Layout Format", ReportLayoutList."Layout Format"::RDLC);
        if not ReportLayoutList.FindFirst() then
            exit(false);

        Clear(TempBlob);
        TempBlob.CreateOutStream(os);
        ReportLayoutList.Layout.ExportStream(os);
        exit(true);
    end;

    /// <summary>
    /// Creates an empty RDLC layout without fields, used when a report has no usable built-in RDLC layout.
    /// </summary>
    procedure GetEmptyRdlcLayout(var TempBlob: Codeunit "Temp Blob")
    var
        Rdlc: TextBuilder;
        os: OutStream;
    begin
        Rdlc.Append('<?xml version="1.0" encoding="utf-8"?>');
        Rdlc.Append('<Report xmlns="http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition" xmlns:rd="http://schemas.microsoft.com/SQLServer/reporting/reportdesigner">');
        Rdlc.Append('<AutoRefresh>0</AutoRefresh>');
        Rdlc.Append('<DataSources><DataSource Name="DataSource"><ConnectionProperties><DataProvider>SQL</DataProvider><ConnectString /></ConnectionProperties></DataSource></DataSources>');
        Rdlc.Append('<ReportSections><ReportSection><Body><Height>1in</Height><Style /></Body><Width>6.5in</Width><Page><Style /></Page></ReportSection></ReportSections>');
        Rdlc.Append('<DataSets><DataSet Name="DataSet_Result"><Query><DataSourceName>DataSource</DataSourceName><CommandText /></Query></DataSet></DataSets>');
        Rdlc.Append('<rd:ReportUnitType>Inch</rd:ReportUnitType>');
        Rdlc.Append('</Report>');

        Clear(TempBlob);
        TempBlob.CreateOutStream(os, TextEncoding::UTF8);
        os.WriteText(Rdlc.ToText());
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
