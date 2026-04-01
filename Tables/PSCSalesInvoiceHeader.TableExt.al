//7227680
tableextension 60103 T112SalesInvoiceHeaderExten extends "Sales Invoice Header"
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
            CaptionML = ESP = 'Estado Pedido PS', ENU = 'PS Order Status';
        }

        field(60106; "Desc. Estado Pedido PS"; Text[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Desc. Estado Pedido PS', ENU = 'PS Order Status Desc.';
            //falta calcformula tabla de estados pedidos

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

        }

        field(60109; "TotalDescuentos"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Total descuentos pedido PS', ENU = 'PS Order total discounts';

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
    }

}