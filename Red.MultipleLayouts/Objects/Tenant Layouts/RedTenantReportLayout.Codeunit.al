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
        if not GetBuiltinLayout(ReportId, TempBlob) then
            GetEmptyRdlcLayout(TempBlob);
        TempBlob.CreateInStream(is);
        TenantReportLayout.Layout.ImportStream(is, TenantReportLayout.Description);
        TenantReportLayout.Insert();
    end;

    /// <summary>
    /// Gets the first built-in RDLC layout of the report that matches the report dataset.
    /// Returns false if there is none, e.g. when the report only has Word layouts, or when the built-in
    /// RDLC references columns that are not in the dataset (BC29: Standard Sales - Order Conf., Quote,
    /// Credit Memo and Draft Invoice), which would fail when imported into a tenant layout.
    /// </summary>
    procedure GetBuiltinLayout(ReportId: Integer; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        ReportLayoutList: Record "Report Layout List";
        DatasetNames: List of [Text];
        os: OutStream;
    begin
        ReportLayoutList.SetRange("Report ID", ReportId);
        ReportLayoutList.SetRange("User Defined", false);
        ReportLayoutList.SetRange("Layout Format", ReportLayoutList."Layout Format"::RDLC);
        if not ReportLayoutList.FindSet() then
            exit(false);

        GetDatasetNames(ReportId, DatasetNames);
        repeat
            Clear(TempBlob);
            TempBlob.CreateOutStream(os);
            ReportLayoutList.Layout.ExportStream(os);
            if RdlcMatchesDataset(TempBlob, DatasetNames) then
                exit(true);
        until ReportLayoutList.Next() = 0;

        Clear(TempBlob);
        exit(false);
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

    local procedure GetDatasetNames(ReportId: Integer; var DatasetNames: List of [Text])
    var
        XmlPart: XmlDocument;
        Nodes: XmlNodeList;
        Node: XmlNode;
    begin
        // The Word XML part lists every data item, column and label of the report dataset as an element
        if not XmlDocument.ReadFrom(Report.WordXmlPart(ReportId), XmlPart) then
            exit;
        if not XmlPart.SelectNodes('//*', Nodes) then
            exit;
        foreach Node in Nodes do
            if not DatasetNames.Contains(Node.AsXmlElement().LocalName()) then
                DatasetNames.Add(Node.AsXmlElement().LocalName());
    end;

    local procedure RdlcMatchesDataset(var TempBlob: Codeunit "Temp Blob"; DatasetNames: List of [Text]): Boolean
    var
        Rdlc: XmlDocument;
        Nodes: XmlNodeList;
        Node: XmlNode;
        is: InStream;
    begin
        if DatasetNames.Count() = 0 then
            exit(true); // dataset unknown, keep the previous behavior and use the layout

        TempBlob.CreateInStream(is);
        if not XmlDocument.ReadFrom(is, Rdlc) then
            exit(false);
        if not Rdlc.SelectNodes('//*[local-name()=''DataField'']', Nodes) then
            exit(true);
        foreach Node in Nodes do
            if not IsDatasetName(Node.AsXmlElement().InnerText(), DatasetNames) then
                exit(false);
        exit(true);
    end;

    local procedure IsDatasetName(FieldName: Text; DatasetNames: List of [Text]): Boolean
    begin
        if DatasetNames.Contains(FieldName) then
            exit(true);
        // RDLC datasets get an extra <column>Format field for decimal columns
        if FieldName.EndsWith('Format') then
            exit(DatasetNames.Contains(FieldName.Substring(1, StrLen(FieldName) - StrLen('Format'))));
        exit(false);
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
