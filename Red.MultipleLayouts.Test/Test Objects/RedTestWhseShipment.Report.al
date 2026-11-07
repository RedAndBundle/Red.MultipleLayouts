report 80501 "Red Test Whse. Shipment"
{
    // Warehouse test report without built-in layouts, so only the tenant layouts created by the tests show up in "Report Layout List".
    Caption = 'Red Test Whse. Shipment';
    UsageCategory = None;

    dataset
    {
        dataitem(WarehouseShipmentHeader; "Warehouse Shipment Header")
        {
            column(No; "No.")
            {
            }
        }
    }
}
