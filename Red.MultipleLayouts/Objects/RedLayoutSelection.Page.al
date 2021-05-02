Page 11310862 "Red Layout Selection"
{
    Caption = 'Red Layout Selection';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Red Layout Selection";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the report number from the full list of installed reports.';
                }
                field("Report Name"; Rec."Report Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the selected report.';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the layout is the default layout. No layout selection will pop up even if there are many in the system.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the table the report is run from. For instance the Sales Invoice uses table 112, the Sales Order uses table 36 etc.';
                    Editable = not Rec.Default;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the selected table.';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field that you want to use to determine whether or not to use the Custom Report Layout.';
                    Editable = not Rec.Default;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupFieldNo();
                    end;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the selected field.';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the field that determines if the Custom Report Layout should be used.';
                    Editable = not Rec.Default;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupFieldValue();
                    end;
                }
                field(CustomLayoutDescription; CustomLayoutDescription)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Custom Layout Description';
                    ToolTip = 'Specifies the Custom Report Layout to use.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupCustomLayout();
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCustomLayout();
                    end;
                }

            }

        }
    }

    actions
    {
        area(reporting)
        {
            action(RunReport)
            {
                ApplicationArea = All;
                Caption = 'Run Report';
                Image = "Report";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Run a test report.';

                trigger OnAction()
                begin
                    RunCustomReport();
                end;
            }
        }
        area(Processing)
        {
            action(Export)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Export the selected records to a json file.';

                trigger OnAction()
                begin
                    ExportSelected();
                end;
            }
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Import Layout Seelctions from a file.';

                trigger OnAction()
                begin
                    Rec.ImportFromFile();
                end;
            }
            action(DoRecord)
            {
                ApplicationArea = All;
                Caption = 'Record';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Records the Report ID and Source Table No when running a report.';
                Visible = not IsRecording;

                trigger OnAction()
                begin
                    ToggleRecord();
                    CurrPage.Update();
                end;
            }
            action(UndoRecord)
            {
                ApplicationArea = All;
                Caption = 'Stop Record';
                Image = Stop;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Stops recording the Report ID and Source Table No when running a report.';
                Visible = IsRecording;

                trigger OnAction()
                begin
                    ToggleRecord();
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        IsRecording: Boolean;

    trigger OnOpenPage()
    var
        RedLayoutRecorder: Codeunit "Red Layout Recorder";
    begin
        IsRecording := RedLayoutRecorder.IsRecording();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CustomLayoutDescription := '';
    end;

    procedure RunCustomReport()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        if Rec."Report ID" = 0 then
            exit;

        ReportLayoutSelection.SetTempLayoutSelected(Rec."Custom Report Layout Code");
        Report.RunModal(Rec."Report ID");
        ReportLayoutSelection.SetTempLayoutSelected('');
    end;

    local procedure ExportSelected()
    var
        RedLayoutSelection: Record "Red Layout Selection";
        RedLayoutSelectionExport: Codeunit "Red Layout Selection Export";
    begin
        CurrPage.SetSelectionFilter(RedLayoutSelection);
        RedLayoutSelectionExport.Run(RedLayoutSelection);
    end;

    var
        CustomLayoutDescription: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(Rec."Report Layout Description");
        CustomLayoutDescription := Rec."Report Layout Description";
    end;

    local procedure LookupCustomLayout()
    var
        CustomReportLayout: Record "Custom Report Layout";
        WrongCompanyErr: Label 'You cannot select a layout that is specific to another company.';
    begin
        CustomReportLayout.FilterGroup(4);
        CustomReportLayout.SetRange("Report ID", Rec."Report ID");
        CustomReportLayout.FilterGroup(0);
        CustomReportLayout.SetFilter("Company Name", '%1|%2', CompanyName, '');
        if Page.RunModal(Page::"Custom Report Layouts", CustomReportLayout) = ACTION::LookupOK then begin
            if not (CustomReportLayout."Company Name" in [CompanyName, '']) then
                Error(WrongCompanyErr);
            Rec."Custom Report Layout Code" := CustomReportLayout.Code;
            CustomLayoutDescription := CustomReportLayout.Description;
        end

    end;

    local procedure ValidateCustomLayout()
    var
        CustomReportLayout: Record "Custom Report Layout";
        CouldNotFindCustomReportLayoutErr: Label 'There is no custom report layout with %1 in the description.', Comment = '%1 = CustomLayoutDescription';
        FilterLbl: Label '@*%1*', Comment = '%1 = text to filter';
    begin
        CustomReportLayout.SetCurrentKey("Report ID", "Company Name", Type);
        CustomReportLayout.SetRange("Report ID", Rec."Report ID");
        CustomReportLayout.SetFilter("Company Name", '%1|%2', '', CompanyName);
        CustomReportLayout.SetFilter(
          Description, StrSubstNo(FilterLbl, CustomLayoutDescription));
        if not CustomReportLayout.FindFirst() then
            Error(CouldNotFindCustomReportLayoutErr, CustomLayoutDescription);

        if CustomReportLayout.Code <> Rec."Custom Report Layout Code" then
            Rec.Validate(Rec."Custom Report Layout Code", CustomReportLayout.Code);
    end;

    local procedure LookupFieldNo();
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, Rec."Table No.");

        if Page.RunModal(Page::"Fields Lookup", Field) = Action::LookupOK then
            Rec.Validate(Rec."Field No.", Field."No.");
    end;

    local procedure LookupFieldValue()
    var
        LayoutValueSelection: Codeunit "Red Layout Value Selection";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        case 0 of
            Rec."Table No.",
            Rec."Field No.":
                exit;
        end;

        RecRef.Open(Rec."Table No.");
        FldRef := RecRef.Field(Rec."Field No.");

        case FldRef.Relation() of
            Database::Customer:
                Rec.Value := LayoutValueSelection.SelectCustomer();
            Database::Vendor:
                Rec.Value := LayoutValueSelection.SelectVendor();
            Database::"Dimension Value":
                Rec.Value := LayoutValueSelection.SelectDimension(FldRef.Name);
            Database::Contact:
                Rec.Value := LayoutValueSelection.SelectContact();
            Database::"Payment Terms":
                Rec.Value := LayoutValueSelection.SelectPaymentTerms();
            Database::Item:
                Rec.Value := LayoutValueSelection.SelectItem();
            Database::"Bank Account":
                Rec.Value := LayoutValueSelection.SelectBankAccount();
        end;
    end;

    local procedure ToggleRecord()
    var
        RedLayoutRecorder: Codeunit "Red Layout Recorder";
    begin
        IsRecording := RedLayoutRecorder.IsRecording();
        IsRecording := not IsRecording;
        RedLayoutRecorder.SetRecord(IsRecording);
    end;
}