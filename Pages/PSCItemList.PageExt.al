//7227680
pageextension 60103 P31ItemListExtension extends "Item List"
{
    layout
    {
        addlast(Control1)
        {
            field(IdPS; IdPS)
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Producto web"; "Producto web")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
    }
}