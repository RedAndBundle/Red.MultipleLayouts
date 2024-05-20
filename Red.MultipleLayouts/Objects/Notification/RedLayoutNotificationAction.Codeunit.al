codeunit 11310878 "Red Layout Notification Action"
{
    Access = Internal;

    procedure ObsoleteCustomLayout(var MyNotification: Notification)
    begin
        Hyperlink('https://multilayout.redandbundle.com/docs/06%20deprecated');
    end;
}