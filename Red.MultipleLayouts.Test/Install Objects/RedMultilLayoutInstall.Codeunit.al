codeunit 80403 "Red Multi Layout Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        TestSuite: Codeunit "Test Suite Mgt.";
        ALTestSuite: Record "AL Test Suite";
        SuiteName: Code[10];
    begin
        SuiteName := 'RED';
        TestSuite.CreateTestSuite(SuiteName);
        ALTestSuite.Get(SuiteName);
        TestSuite.SelectTestMethodsByRange(ALTestSuite, '80400..80450');
    end;
}