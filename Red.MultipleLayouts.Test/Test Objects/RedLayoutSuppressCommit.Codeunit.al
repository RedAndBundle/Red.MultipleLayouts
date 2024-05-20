codeunit 80504 "Red Layout Suppress Commit"
{
    EventSubscriberInstance = Manual;

    procedure RunSalesPost(var SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.Run(SalesHeader);
    end;

    procedure RunPurchasePost(var PurchaseHeader: Record "Purchase Header")
    var
        PurchPost: Codeunit "Purch.-Post";
    begin
        PurchPost.Run(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostCommitSalesDoc', '', false, false)]
    local procedure OnBeforePostCommitSalesDoc(PreviewMode: Boolean; var CommitIsSuppressed: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var ModifyHeader: Boolean; var SalesHeader: Record "Sales Header"; var TempSalesLineGlobal: Record "Sales Line")
    begin
        CommitIsSuppressed := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostCommitPurchaseDoc', '', false, false)]
    local procedure OnBeforePostCommitPurchaseDoc(ModifyHeader: Boolean; PreviewMode: Boolean; var CommitIsSupressed: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var PurchaseHeader: Record "Purchase Header"; var TempPurchLineGlobal: Record "Purchase Line")
    begin
        CommitIsSupressed := true;
    end;
}