//7227678
pageextension 60101 P22CustomerListExtension extends "Customer List"
{
    layout
    {
        addlast(Control1)
        {
            field(fechaAltaClientePS; Rec.fechaAltaClientePS)
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(IdClientePS; Rec.IdClientePS)
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(EsClientePS; Rec.EsClientePS)
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Pendiente sincro B2B"; Rec."Pendiente sincro B2B")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}