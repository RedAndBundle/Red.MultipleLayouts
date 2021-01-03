codeunit 11310868 "Red ForNAV Layout Multiple" implements "ForNAV Layout"
{
    procedure OnDrillDown(ForNAVReports: Record "ForNAV Reports"): Boolean
    begin
        OpenMultipleLayouts(ForNAVReports);
    end;

    procedure GetStyle(): Text
    begin
        exit('strongaccent');
    end;

    local procedure OpenMultipleLayouts(ForNAVReports: Record "ForNAV Reports")
    var
        RedLayoutSelection: Record "Red Layout Selection";
    begin
        RedLayoutSelection.SetRange("Report ID", ForNAVReports.ID);
        Page.RunModal(0, RedLayoutSelection);
    end;
}