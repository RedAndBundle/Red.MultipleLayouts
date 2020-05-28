// Copyright [2020] [Red and Bundle]
codeunit 80401 "Red Layout Select Test Setup"
{
    procedure EnsureCustomLayoutsForReport(ReportId: Integer; NoOfLayouts: Integer)
    var
        CustomReportLayout: Record "Custom Report Layout";
        i: Integer;
    begin
        with CustomReportLayout do begin
            SetRange("Report ID", ReportId);
            DeleteAll();
            for i := 1 to NoOfLayouts do begin
                Init();
                Validate(Code, Format(i));
                Validate("Report ID", ReportId);
                Validate(Description, Format(i));
                Validate(Type, Type::RDLC);
                Insert();
            end;
        end;
    end;

    procedure SelectFirstLayoutForReport(ReportId: Integer)
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
    begin
        with CustomReportLayout do begin
            SetRange("Report ID", ReportId);
            FindFirst();
        end;

        with ReportLayoutSelection do begin
            if not Get(ReportId, CompanyName) then begin
                Validate("Report ID", ReportId);
                Validate("Company Name", CompanyName);
                Insert();
            end;
            Validate(Type, Type::"Custom Layout");
            Validate("Custom Report Layout Code", CustomReportLayout.Code);
            Modify();
        end;
    end;

    procedure DeSelectLayoutForReport(ReportId: Integer)
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        with ReportLayoutSelection do
            if Get(ReportId, CompanyName) then begin
                Validate(Type, Type::"RDLC (built-in)");
                Modify();
            end;
    end;

    procedure EnsureNoLayoutInSelectionTable(ReportId: Integer)
    var
        RedLayoutSelection: Record "Red Layout Selection";
        RecRef: RecordRef;
    begin
        with RedLayoutSelection do begin
            SetRange("Report ID", ReportId);
            DeleteAll();
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

        with RedLayoutSelection do begin
            Validate("Report ID", 206);
            Validate("Table No.", RecRef.Number);
            Validate("Field No.", FldRef.Number);
            Validate(Value, FldRef.Value);
            Validate("Custom Report Layout Code", CustomReportLayoutCode);
            Insert();
        end;
    end;
}