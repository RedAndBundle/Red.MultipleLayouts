Page 11310865 "Red Report Layout Selection"
{
    Caption = 'Red Report Layout Selection';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Red Report Layout Selection";
    Extensible = false;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field("Report Selection Usage"; Rec."Report Selection Usage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the usage of the report selection. If it is left to Red Blank, the layout selection will be used for all usages.';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the report number from the full list of installed reports.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupReportId();
                        CurrPage.Update();
                    end;
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
                        LookupTenantLayout();
                    end;

                    trigger OnValidate()
                    begin
                        ValidateTenantLayout();
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
        CustomLayoutDescription: Text;

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

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(Rec."Report Layout Description");
        CustomLayoutDescription := Rec."Report Layout Description";
    end;

    procedure RunCustomReport()
    var
        RedReportLayoutSelection: Codeunit "Red Report Layout Selection";
    begin
        if Rec."Report ID" = 0 then
            exit;

        RedReportLayoutSelection.SetTempTenantLayoutSelected(Rec."Layout Name");
        Report.RunModal(Rec."Report ID");
        RedReportLayoutSelection.SetTempTenantLayoutSelected('');
    end;

    local procedure ExportSelected()
    var
        RedReportLayoutSelection: Record "Red Report Layout Selection";
        RedRepLayoutSelectionExp: Codeunit "Red Rep Layout Selection Exp.";
    begin
        CurrPage.SetSelectionFilter(RedReportLayoutSelection);
        RedRepLayoutSelectionExp.Run(RedReportLayoutSelection);
    end;

    local procedure LookupTenantLayout()
    var
        TenantReportLayout: Record "Tenant Report Layout";
        WrongCompanyErr: Label 'You cannot select a layout that is specific to another company.';
    begin
        TenantReportLayout.FilterGroup(4);
        TenantReportLayout.SetRange("Report ID", Rec."Report ID");
        TenantReportLayout.FilterGroup(0);
        TenantReportLayout.SetFilter("Company Name", '%1|%2', CompanyName, '');
        if Page.RunModal(page::"Red Report Layouts", TenantReportLayout) = ACTION::LookupOK then begin
            if not (TenantReportLayout."Company Name" in [CompanyName, '']) then
                Error(WrongCompanyErr);
            Rec."Layout Name" := TenantReportLayout.Name;
            CustomLayoutDescription := TenantReportLayout.Description;
        end

    end;

    local procedure ValidateTenantLayout()
    var
        TenantReportLayout: Record "Tenant Report Layout";
        CouldNotFindTenantReportLayoutErr: Label 'There is no custom report layout with %1 in the description.', Comment = '%1 = CustomLayoutDescription';
        FilterLbl: Label '@*%1*', Comment = '%1 = text to filter';
    begin
        if CustomLayoutDescription = '' then begin
            Rec."Layout Name" := '';
            exit;
        end;

        TenantReportLayout.SetCurrentKey("Report ID", "Company Name", "Layout Format");
        TenantReportLayout.SetRange("Report ID", Rec."Report ID");
        TenantReportLayout.SetFilter("Company Name", '%1|%2', '', CompanyName);
        TenantReportLayout.SetFilter(
          Description, StrSubstNo(FilterLbl, CustomLayoutDescription));
        if not TenantReportLayout.FindFirst() then
            Error(CouldNotFindTenantReportLayoutErr, CustomLayoutDescription);

        if TenantReportLayout.Name <> Rec."Layout Name" then
            Rec.Validate(Rec."Layout Name", TenantReportLayout.Name);
    end;

    local procedure LookupFieldNo();
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, Rec."Table No.");
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
        Field.SetFilter(Type, '<>%1&<>%2&<>%3&<>%4', Field.Type::BLOB, Field.Type::MediaSet, Field.Type::Media, Field.Type::Binary);

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