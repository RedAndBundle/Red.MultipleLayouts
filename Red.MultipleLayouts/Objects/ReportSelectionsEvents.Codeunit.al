// Copyright [2020] [Red and Bundle]
codeunit 80000 "Red Report Selections Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforePrintDocument', '', false, false)]
    local procedure MyProcedure(TempReportSelections: Record "Report Selections" temporary; IsGUI: Boolean; RecVarToPrint: Variant; var IsHandled: Boolean)
    var
        LayoutSelection: Codeunit "Red Layout Selection";
    begin
        if IsHandled then
            exit;

        IsHandled := LayoutSelection.RunReportWithLayoutSelection(TempReportSelections, IsGUI, RecVarToPrint);
    end;
}