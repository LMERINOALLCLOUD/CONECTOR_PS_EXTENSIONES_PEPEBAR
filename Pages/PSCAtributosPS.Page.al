//7227683
page 60106 "Atributos PS"
{
    Caption = 'Atributos PS';
    PageType = List;
    UsageCategory = None;
    SourceTable = "Item Attribute";
    SourceTableView = where(Name = filter(<> ''));

    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(general)
            {
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(IdPs; IdPs)
                {
                    ApplicationArea = All;
                }
            }
        }
    }


}