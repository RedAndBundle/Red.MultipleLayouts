codeunit 11310869 "Red Layout Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        RedLayoutTelemetry: Codeunit "Red Layout Telemetry";
    begin
        RedLayoutTelemetry.LogInstall();
    end;
}