query 60100 "Facturas Venta PS"
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; "Sales Invoice Header")
        {
            //DataItemTableFilter = EsPedidoPS = const(true);
            //al ser B2B mostramos todas las facturas del cliente, filtramos en el conector por fecha inicio facturas web
            column(No_; "No.")
            {

            }
            column(Posting_Date; "Posting Date")
            {

            }
            column(Ref__pedido_PS; "Ref. pedido PS")
            {

            }
            column(Amount; Amount)
            {

            }
            column(Amount_Including_VAT; "Amount Including VAT")
            {

            }
            column(Bill_to_Customer_No_; "Bill-to Customer No.")
            {

            }
            column(Bill_to_Name; "Bill-to Name")
            {

            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}