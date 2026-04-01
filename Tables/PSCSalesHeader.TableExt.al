//7227679
tableextension 60102 T36_SalesHeaderExtension extends "Sales Header"
{
    fields
    {
        field(60100; "IdPedidoPS"; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Id Pedido PS', ENU = 'PS Order Id';
        }

        field(60101; "EsPedidoPS"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Pedido PS', ENU = 'PS Order';
        }

        field(60102; "TotalPSIva"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Total pedido s/iva', ENU = 'Order total wo/taxes';
        }

        field(60103; "TotalPCIva"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Total pedido c/iva', ENU = 'Order total w/taxes';
        }

        field(60104; "TotalEnvioPSiva"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Total envío s/iva', ENU = 'Shipping total wo/taxes';
        }

        field(60105; "Estado Pedido PS"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Relacion de estados pedido PS";
            CaptionML = ESP = 'Estado Pedido PS', ENU = 'PS Order Status';
            trigger OnValidate()
            var
                CUPs: Codeunit PSSincro;
            begin
                //aquí codigo para insertar la operación asíncrona
                CUPs.insertarOperacionActEstPedido(IdPedidoPS, "Estado Pedido PS");
                /*
                perso matarromera                
                IF IdPedidoPS <> 0 THEN BEGIN
                IF "Estado Pedido PS" <> xRec."Estado Pedido PS" THEN BEGIN

                    rEstadosPedidoPreparCurso.RESET();
                    rEstadosPedidoPreparCurso.SETRANGE(rEstadosPedidoPreparCurso."En preparacion",TRUE);
                    IF rEstadosPedidoPreparCurso.FINDFIRST() THEN
                    estadoPreparEnCurso := rEstadosPedidoPreparCurso.idEstadoPS;

                    //COMPROBAMOS SI EL ESTADO ES PAGO ACEPTADO CAMBIAMOS A PREPARACION EN CURSO
                    rEstadosPedidoAceptado.RESET();
                    rEstadosPedidoAceptado.SETRANGE(rEstadosPedidoAceptado."Pago Aceptado",TRUE);
                    IF rEstadosPedidoAceptado.FINDFIRST() THEN REPEAT
                    IF "Estado Pedido PS" = rEstadosPedidoAceptado.idEstadoPS THEN
                        "Estado Pedido PS" := estadoPreparEnCurso;
                    UNTIL rEstadosPedidoAceptado.NEXT = 0;

                    CUPs.insertarOperacionActEstPedido(IdPedidoPS,"Estado Pedido PS");
                END;
                END;
                */

            end;
        }
        field(60106; "Desc. Estado Pedido PS"; Text[50])
        {
            CaptionML = ESP = 'Desc. Estado Pedido PS', ENU = 'PS Order Status Desc.';
            FieldClass = FlowField;
            CalcFormula = lookup("Relacion de estados pedido PS".nombreEstadoPS where(idEstadoPS = field("Estado Pedido PS")));
        }

        field(60107; "Ref. pedido PS"; Text[30])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Ref. pedido PS', ENU = 'PS Order Reference';
        }

        field(60108; "Nº seguimiento PS"; Text[30])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Nº seguimiento PS', ENU = 'PS Tracking No.';

            trigger OnValidate()
            var
                CUPs: Codeunit PSSincro;
            begin
                IF IdPedidoPS <> 0 THEN
                    IF "Nº seguimiento PS" <> xRec."Nº seguimiento PS" THEN BEGIN
                        //INNSincro QUITAMOS EL INICIO DE LA URL ANTES DE PASAR A PRESTASHOP
                        //v1.0.0.19
                        CUPs.insertarOperacionActSegPedido(IdPedidoPS, CUPs.quitarInicioURL("Nº seguimiento PS"));
                    END;
            end;
        }

        //MARKETPLACE no se usan no borrar porque sino da error al actualizar extension
        field(60110; "Cuota marketplace"; Code[20])
        {
            Caption = 'Cuota marketplace';
            DataClassification = ToBeClassified;
            TableRelation = ConfiguracionMarketplacePS;
            trigger OnValidate()
            begin
                //if rec."Cuota marketplace" <> xRec."Cuota marketplace" then
                //    calculoManualDatosyCuotaMarketplace();
            end;
        }
        field(60111; "Importe cuota marketplace"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                //recalcularCuotaMarketplace();
            end;
        }
        field(60112; "Margen beneficio s.marketplace"; Decimal)
        {
            //total pedido - cuota marketplace (base, sin el iva)
            Caption = 'Margen beneficio MK';
            DataClassification = ToBeClassified;
        }
        field(60113; "Margen beneficio total"; Decimal)
        {
            //margen de beneficio, sin iva, descontando el precio venta productos - precio coste - margen marketplace
            Caption = 'Margen beneficio total';
            DataClassification = ToBeClassified;
        }

        field(60109; "TotalDescuentos"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Total descuentos pedido PS', ENU = 'PS Order total discounts';
        }
    }

}