page 60111 PSCSalesPricePSB2B
{
    Caption = 'PSC Sales Price List B2B';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Sales Line Discount";
    SourceTableView = where("Sales Type" = filter("Customer Disc. Group"));


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Id Group PS"; "Id Group PS")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}