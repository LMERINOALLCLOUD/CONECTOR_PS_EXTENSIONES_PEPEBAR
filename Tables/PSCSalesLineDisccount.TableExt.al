tableextension 60112 "PSC Sales Line Disccount" extends "Sales Line Discount"
{
    fields
    {
        field(60100; "Id Group PS"; Integer)
        {
            Caption = 'Id grupo PS';
            FieldClass = FlowField;
            CalcFormula = Lookup("Customer Discount Group"."Id Group PS" WHERE(Code = FIELD("Sales Code")));
        }
    }

}