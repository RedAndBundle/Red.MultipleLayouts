codeunit 80401 "Red Layout Select Test Setup"
{
    procedure EnsureCustomLayoutsForReport(ReportId: Integer; NoOfLayouts: Integer)
    var
        CustomReportLayout: Record "Custom Report Layout";
        i: Integer;
    begin
        begin
            CustomReportLayout.SetRange("Report ID", ReportId);
            CustomReportLayout.DeleteAll();
            for i := 1 to NoOfLayouts do begin
                CustomReportLayout.Init();
                CustomReportLayout.Validate(Code, Format(i));
                CustomReportLayout.Validate("Report ID", ReportId);
                CustomReportLayout.Validate(Description, Format(i));
                CustomReportLayout.Validate(Type, CustomReportLayout.Type::RDLC);
                CustomReportLayout.Insert();
            end;
        end;
    end;

    procedure SelectFirstLayoutForReport(ReportId: Integer)
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
    begin
        begin
            CustomReportLayout.SetRange("Report ID", ReportId);
            CustomReportLayout.FindFirst();
        end;

        begin
            if not ReportLayoutSelection.Get(ReportId, CompanyName) then begin
                ReportLayoutSelection.Validate("Report ID", ReportId);
                ReportLayoutSelection.Validate("Company Name", CompanyName);
                ReportLayoutSelection.Insert();
            end;
            ReportLayoutSelection.Validate(Type, ReportLayoutSelection.Type::"Custom Layout");
            ReportLayoutSelection.Validate("Custom Report Layout Code", CustomReportLayout.Code);
            ReportLayoutSelection.Modify();
        end;
    end;

    procedure DeSelectLayoutForReport(ReportId: Integer)
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        if ReportLayoutSelection.Get(ReportId, CompanyName) then begin
            ReportLayoutSelection.Validate(Type, ReportLayoutSelection.Type::"RDLC (built-in)");
            ReportLayoutSelection.Modify();
        end;
    end;

    procedure EnsureNoLayoutInSelectionTable(ReportId: Integer)
    var
        RedLayoutSelection: Record "Red Layout Selection";
    begin
        begin
            RedLayoutSelection.SetRange(RedLayoutSelection."Report ID", ReportId);
            RedLayoutSelection.DeleteAll();
        end;
    end;

    procedure AddLayoutToSelectionTable(RecVar: Variant; ReportId: Integer; CustomReportLayoutCode: Code[50]; SourceFieldName: Text)
    var
        RedLayoutSelection: Record "Red Layout Selection";
        Field: Record Field;
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        RecRef.GetTable(RecVar);

        Field.SetRange(TableNo, RecRef.Number);
        Field.SetRange(FieldName, SourceFieldName);
        Field.FindFirst();

        FldRef := RecRef.Field(Field."No.");

        begin
            RedLayoutSelection.Validate(RedLayoutSelection."Report ID", ReportId);
            RedLayoutSelection.Validate(RedLayoutSelection."Table No.", RecRef.Number);
            RedLayoutSelection.Validate(RedLayoutSelection."Field No.", FldRef.Number);
            RedLayoutSelection.Validate(RedLayoutSelection.Value, FldRef.Value);
            RedLayoutSelection.Validate(RedLayoutSelection."Custom Report Layout Code", CustomReportLayoutCode);
            RedLayoutSelection.Insert();
        end;
    end;
}