//7227678
pageextension 60101 P22CustomerListExtension extends "Customer List"
{
    layout
    {
        addlast(Control1)
        {
            field(fechaAltaClientePS; fechaAltaClientePS)
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(IdClientePS; IdClientePS)
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(EsClientePS; EsClientePS)
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Pendiente sincro B2B"; "Pendiente sincro B2B")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}