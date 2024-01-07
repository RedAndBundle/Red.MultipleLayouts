// codeunit 11310872 "Red Layout Upgrade"
// {
//     Subtype = Upgrade;
//     Access = Internal;

//     trigger OnCheckPreconditionsPerCompany()
//     begin
//     end;

//     trigger OnUpgradePerCompany()
//     begin
//         Upgrade3000();
//     end;

//     trigger OnValidateUpgradePerCompany()
//     begin
//     end;

//     trigger OnUpgradePerDatabase()
//     begin
//     end;

//     local procedure Upgrade3000()
//     var
//         UpgradeTag: Codeunit "Upgrade Tag";
//         UpgradeTagLbl: Label 'Red Layout 3.0.0.0';
//     begin
//         if UpgradeTag.HasUpgradeTag(UpgradeTagLbl, CompanyName) then
//             exit;

//         UpgradeCustomLayoutToTenantLayout();
//         UpgradeTag.SetUpgradeTag(UpgradeTagLbl);
//     end;

//     local procedure UpgradeCustomLayoutToTenantLayout()
//     var
//         RedLayoutSelection: Record "Red Layout Selection";
//     begin
//         RedLayoutSelection.SetFilter("Custom Report Layout Code", '<>%1', '');
//         if RedLayoutSelection.FindSet() then
//             repeat
//                 RedLayoutSelection."Layout Name" := RedLayoutSelection."Layout Name";
//                 RedLayoutSelection.Modify();
//                 RedLayoutSelection."Layout Name" := '';
//                 RedLayoutSelection.Rename(RedLayoutSelection."Report ID", '', RedLayoutSelection."Table No.", RedLayoutSelection."Field No.");
//             until RedLayoutSelection.Next() = 0;
//     end;
// }