codeunit 80403 "Red Multi Layout Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        ALTestSuite: Record "AL Test Suite";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        SuiteName: Code[10];
    begin
        SuiteName := 'REDMULTI';
        if ALTestSuite.Get(SuiteName) then begin
            TestSuiteMgt.DeleteAllMethods(ALTestSuite);
            if ALTestSuite.Delete() then;
        end;
        TestSuiteMgt.CreateTestSuite(SuiteName);
        ALTestSuite.Get(SuiteName);
        TestSuiteMgt.SelectTestMethodsByRange(ALTestSuite, '80400..80450');
    end;
}