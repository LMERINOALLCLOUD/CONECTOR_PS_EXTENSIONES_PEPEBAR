query 60101 "Abonos Venta PS"
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; "Sales Cr.Memo Header")
        {
            column(No_; "No.")
            {

            }
            column(Posting_Date; "Posting Date")
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