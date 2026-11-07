report 80500 "Red Test Sales Invoice"
{
    // Test report without built-in layouts, so only the tenant layouts created by the tests show up in "Report Layout List".
    Caption = 'Red Test Sales Invoice';
    UsageCategory = None;

    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            column(No; "No.")
            {
            }
        }
    }
}
