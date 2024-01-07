codeunit 11310878 "Red Layout Notification Action"
{
    Access = Internal;

    procedure ObsoleteCustomLayout(var MyNotification: Notification)
    begin
        // TODO add url and open docs website
        Hyperlink('https://redandbundle.com/');
    end;
}