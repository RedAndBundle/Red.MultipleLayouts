// Copyright [2020] [Red and Bundle]
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
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the report number from the full list of installed reports.';
                }
                field("Report Name"; "Report Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the selected report.';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the table the report is run from. For instance the Sales Invoice uses table 112, the Sales Order uses table 36 etc.';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the selected table.';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field that you want to use to determine wether or not to use the Custom Report Layout.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupFieldNo();
                    end;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the selected field.';
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the field that determines if the Custom Report Layout should be used.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupFieldValue();
                    end;
                }
                // field("Custom Report Layout Code"; "Custom Report Layout Code") { ApplicationArea = All; }
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
    }

    procedure RunCustomReport()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        if "Report ID" = 0 then
            exit;

        ReportLayoutSelection.SetTempLayoutSelected("Custom Report Layout Code");
        REPORT.RunModal("Report ID");
        ReportLayoutSelection.SetTempLayoutSelected('');
    end;

    var
        CustomLayoutDescription: Text;

    trigger OnAfterGetRecord()
    begin
        CalcFields("Report Layout Description");
        CustomLayoutDescription := "Report Layout Description";
    end;

    local procedure LookupCustomLayout()
    var
        CustomReportLayout: Record "Custom Report Layout";
        WrongCompanyErr: Label 'You cannot select a layout that is specific to another company.';
    begin
        CustomReportLayout.FilterGroup(4);
        CustomReportLayout.SetRange("Report ID", "Report ID");
        CustomReportLayout.FilterGroup(0);
        CustomReportLayout.SetFilter("Company Name", '%1|%2', CompanyName, '');
        if Page.RunModal(Page::"Custom Report Layouts", CustomReportLayout) = ACTION::LookupOK then
            if CustomReportLayout.Find() then begin
                if not (CustomReportLayout."Company Name" in [CompanyName, '']) then
                    Error(WrongCompanyErr);
                "Custom Report Layout Code" := CustomReportLayout.Code;
                CustomLayoutDescription := CustomReportLayout.Description;
            end

    end;

    local procedure ValidateCustomLayout()
    var
        CustomReportLayout: Record "Custom Report Layout";
        CouldNotFindCustomReportLayoutErr: Label 'There is no custom report layout with %1 in the description.', Comment = '%1 = CustomLayoutDescription';
    begin
        CustomReportLayout.SetCurrentKey("Report ID", "Company Name", Type);
        CustomReportLayout.SetRange("Report ID", "Report ID");
        CustomReportLayout.SetFilter("Company Name", '%1|%2', '', CompanyName);
        CustomReportLayout.SetFilter(
          Description, StrSubstNo('@*%1*', CustomLayoutDescription));
        if not CustomReportLayout.FindFirst() then
            Error(CouldNotFindCustomReportLayoutErr, CustomLayoutDescription);

        if CustomReportLayout.Code <> "Custom Report Layout Code" then
            Validate("Custom Report Layout Code", CustomReportLayout.Code);
    end;

    local procedure LookupFieldNo();
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, "Table No.");

        if Page.RunModal(Page::"Fields Lookup", Field) = Action::LookupOK then
            Validate("Field No.", Field."No.");
    end;

    local procedure LookupFieldValue()
    var
        LayoutValueSelection: Codeunit "Red Layout Value Selection";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        case 0 of
            "Table No.",
            "Field No.":
                exit;
        end;

        RecRef.Open("Table No.");
        FldRef := RecRef.Field("Field No.");

        case FldRef.Relation() of
            Database::Customer:
                Value := LayoutValueSelection.SelectCustomer();
            Database::Vendor:
                Value := LayoutValueSelection.SelectVendor();
            Database::"Dimension Value":
                Value := LayoutValueSelection.SelectDimension(FldRef.Name);
            Database::Contact:
                Value := LayoutValueSelection.SelectContact();
            Database::"Payment Terms":
                Value := LayoutValueSelection.SelectPaymentTerms();
            Database::Item:
                Value := LayoutValueSelection.SelectItem();
        end;
    end;
}