//7227679
page 60102 "Lista Estados Pedido PS"
{
    CaptionML = ESP = 'Lista Estados Pedido PS', ENU = 'PS Order State List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Relacion de estados pedido PS";
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(idEstadoPS; idEstadoPS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(nombreEstadoPS; nombreEstadoPS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(moduloPagoPS; moduloPagoPS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(formaPagoNAV; formaPagoNAV)
                {
                    ApplicationArea = All;
                }
                field("Error Pago"; "Error Pago")
                {
                    ApplicationArea = All;
                }
                field("Pte Pago"; "Pte Pago")
                {
                    ApplicationArea = All;
                }
                field(Lanzado; Lanzado)
                {
                    ApplicationArea = All;
                }
                field(Registrado; Registrado)
                {
                    ApplicationArea = All;
                }
                field("Conf. fabrica"; "Conf. fabrica")
                {
                    ApplicationArea = All;
                }
                field(PAYPAL; Rec.PAYPAL)
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {

    }
}