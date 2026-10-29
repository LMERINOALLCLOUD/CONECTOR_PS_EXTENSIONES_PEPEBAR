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
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(IdPs; Rec.IdPs)
                {
                    ApplicationArea = All;
                }
            }
        }
    }


}