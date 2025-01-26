// Copyright [2020] [Red and Bundle]
codeunit 11310863 "Red Layout Value Selection"
{
    procedure SelectCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        if Page.RunModal(Page::"Customer List", Customer) = ACTION::LookupOK then
            exit(Customer."No.");
    end;

    procedure SelectVendor(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        if Page.RunModal(Page::"Vendor List", Vendor) = ACTION::LookupOK then
            exit(Vendor."No.");
    end;

    procedure SelectDimension(FieldName: Text): Code[20]
    var
        DimensionValue: Record "Dimension Value";
    begin
        case true of
            FieldName.ToLower().Contains('dimension 1'):
                DimensionValue.SetRange("Global Dimension No.", 1);
            FieldName.ToLower().Contains('dimension 2'):
                DimensionValue.SetRange("Global Dimension No.", 2);
        end;
        DimensionValue.SetRange(Blocked, false);

        if Page.RunModal(Page::"Dimension Value List", DimensionValue) = ACTION::LookupOK then
            exit(DimensionValue.Code);
    end;

    procedure SelectContact(): Code[20]
    var
        Contact: Record Contact;
    begin
        if Page.RunModal(Page::"Contact List", Contact) = ACTION::LookupOK then
            exit(Contact."No.");
    end;

    procedure SelectPaymentTerms(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if Page.RunModal(Page::"Payment Terms", PaymentTerms) = ACTION::LookupOK then
            exit(PaymentTerms.Code);
    end;

    procedure SelectItem(): Code[20]
    var
        Item: Record Item;
    begin
        if Page.RunModal(Page::"Item List", Item) = ACTION::LookupOK then
            exit(Item."No.");
    end;

    procedure SelectBankAccount(): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        if Page.RunModal(Page::"Bank Account List", BankAccount) = ACTION::LookupOK then
            exit(BankAccount."No.");
    end;

    procedure SelectResponsibilityCenter(): Code[10]
    var
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        if Page.RunModal(Page::"Responsibility Center List", ResponsibilityCenter) = Action::LookupOK then
            exit(ResponsibilityCenter.Code);
    end;
}