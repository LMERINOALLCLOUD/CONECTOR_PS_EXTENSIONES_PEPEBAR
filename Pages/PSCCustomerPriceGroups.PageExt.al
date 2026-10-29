pageextension 60108 PSCCustomerDiscGroups extends "Customer Disc. Groups"
{
    layout
    {
        addafter(Description)
        {
            field("Id Group PS"; Rec."Id Group PS")
            {
                ApplicationArea = All;
            }
        }
    }
}