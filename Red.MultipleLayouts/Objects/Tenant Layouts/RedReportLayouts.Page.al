page 11310864 "Red Report Layouts"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Report Layouts';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Tenant Report Layout";
    SourceTableView = sorting("Report ID", Name, "App ID");
    UsageCategory = Administration;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the Name.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the report layout.';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Business Central company that the report layout applies to. You to create report layouts that can only be used on reports when they are run for a specific to a company. If the field is blank, then the layout will be available for use in all companies.';
                }
            }
        }
    }
}

