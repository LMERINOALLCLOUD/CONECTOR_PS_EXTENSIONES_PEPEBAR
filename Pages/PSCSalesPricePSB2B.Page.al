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
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Id Group PS"; Rec."Id Group PS")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}