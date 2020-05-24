// Copyright [2020] [Red and Bundle]
codeunit 80400 "Red Layout Selection Test"
{
    Subtype = Test;

    trigger OnRun()
    begin

    end;

    local procedure NoCustomLayoutForReport()
    var
        myInt: Integer;
    begin
        // Given
        // No custom layouts in system

        // When
        // "Red Layout Selection".RunReportWithLayoutSelection is called 

        // Then
        // Gets Exit false
    end;

    local procedure OneCustomLayoutSelected()
    var
        myInt: Integer;
    begin
        // Given
        // One custom layouts in system
        // Custom report is selected for the report

        // When
        // "Red Layout Selection".RunReportWithLayoutSelection is called 

        // Then
        // Gets Exit false

    end;

    local procedure OneCustomLayoutNotSelected()
    var
        myInt: Integer;
    begin
        // Given
        // One custom layouts in system
        // Custom report is not selected for the report

        // When
        // "Red Layout Selection".RunReportWithLayoutSelection is called 

        // Then
        // 2 layouts in selection list
        // Layout needs to be selected from selection page
        // Report runs with selected layout
        // Gets Exit true

    end;

    local procedure TwoCustomLayoutSelected()
    var
        myInt: Integer;
    begin
        // Given
        // Two custom layouts in system
        // Custom report is selected for the report

        // When
        // "Red Layout Selection".RunReportWithLayoutSelection is called 

        // Then
        // 2 layouts in selection list
        // Layout needs to be selected from selection page
        // Report runs with selected layout
        // Gets Exit true

    end;

    local procedure TwoCustomLayoutNotSelected()
    var
        myInt: Integer;
    begin
        // Given
        // Two custom layouts in system
        // no custom report is selected for the report

        // When
        // "Red Layout Selection".RunReportWithLayoutSelection is called 

        // Then
        // 3 layouts in selection list
        // Layout needs to be selected from selection page
        // Report runs with selected layout
        // Gets Exit true

    end;

    local procedure OneLayoutInLayoutSelection()
    var
        myInt: Integer;
    begin
        // Given
        // Two custom layouts in system
        // One is selected through the Layout Selection Table

        // When
        // "Red Layout Selection".RunReportWithLayoutSelection is called 

        // Then
        // Report runs with selected layout
        // Gets Exit true
    end;

    local procedure TwoLayoutInLayoutSelection()
    var
        myInt: Integer;
    begin
        // Given
        // Two custom layouts in system
        // Two are selected through the Layout Selection Table

        // When
        // "Red Layout Selection".RunReportWithLayoutSelection is called 

        // Then
        // 2 layouts in selection list
        // Layout needs to be selected from selection page
        // Report runs with selected layout
        // Gets Exit true
    end;
}