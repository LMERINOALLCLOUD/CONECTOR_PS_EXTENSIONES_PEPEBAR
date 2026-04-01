//7227682
page 60105 "Categorias PS"
{
    Caption = 'Categorias PS';
    PageType = List;
    UsageCategory = None;
    SourceTable = "Item Category";

    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(general)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field("Parent Category"; "Parent Category")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Indentation; Indentation)
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