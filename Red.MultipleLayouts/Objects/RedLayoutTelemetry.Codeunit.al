codeunit 11310870 "Red Layout Telemetry"
{
    procedure LogInstall()
    var
        EventDis: Dictionary of [Text, Text];
    begin
        EventDis.Add('Install', 'LogInstall');
        Session.LogMessage('Red001', 'Installed MultiLayout', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, EventDis);
    end;

    procedure LogUpgrade()
    var
        EventDis: Dictionary of [Text, Text];
    begin
        EventDis.Add('Install', 'LogUpgrade');
        Session.LogMessage('Red001', 'Installed MultiLayout', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, EventDis);
    end;

    procedure EmitExtensionTableTraceTags()
    var
        RedLayoutSelection: Record "Red Layout Selection";
        MessageTxt: Label 'Records of table %1: %2', Comment = '%1 = tablename %2 = No Of Records';
    begin
        Session.LogMessage('Red002', StrSubstNo(MessageTxt, RedLayoutSelection.TableName, RedLayoutSelection.Count), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'RedTableSize', 'ISV Table Size');
    end;
}