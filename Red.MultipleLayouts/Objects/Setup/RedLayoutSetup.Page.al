page 11310863 "Red Layout Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Red Layout Setup";
    Caption = 'Multiple Layout Setup';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Commit on Post"; Rec."Commit on Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a commit is called when running the report selection after posting. This is only needed when an extension enables the CommitIsSuppressed option in a posting CodeUnit.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LayoutSelection)
            {
                ApplicationArea = All;
                Caption = 'Red Layout Selection';
                Image = "Report";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Red Layout Selection";
                ToolTip = 'Opens the Layout Selection page whenre you can setup which report layout is used in which circumstance.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitSetup();
    end;
}