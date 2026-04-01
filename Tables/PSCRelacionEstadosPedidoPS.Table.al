//7227677
table 60100 "Relacion de estados pedido PS"
{
    DataClassification = ToBeClassified;

    fields
    {

        field(1; "idEstadoPS"; Code[10])
        {
            CaptionML = ESP = 'Id Estado pedido PS', ENU = 'PS order state Id';
            DataClassification = ToBeClassified;
        }

        field(2; "nombreEstadoPS"; Text[50])
        {
            CaptionML = ESP = 'Desc. Estado pedido PS', ENU = 'PS order state desc.';
            ;
            DataClassification = ToBeClassified;
        }

        field(3; "formaPagoNAV"; Code[10])
        {
            CaptionML = ESP = 'Forma de pago NAV', ENU = 'NAV Payment Method';
            ;
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method";
        }

        field(4; "moduloPagoPS"; Text[30])
        {
            CaptionML = ESP = 'Módulo de pago PS', ENU = 'PS Payment Module';
            DataClassification = ToBeClassified;
        }
        field(5; "checked"; Boolean)
        {
            CaptionML = ESP = 'Checked', ENU = 'Checked';
            DataClassification = ToBeClassified;
        }
        field(6; "estadoDeEntrada"; Boolean)
        {
            CaptionML = ESP = 'Estado de entrada', ENU = 'Input state';
            DataClassification = ToBeClassified;
        }
        field(7; "Error Pago"; Boolean)
        {
            CaptionML = ESP = 'Error de pago', ENU = 'Payment error';
            DataClassification = ToBeClassified;
        }
        field(8; "Lanzado"; Boolean)
        {
            CaptionML = ESP = 'Lanzado', ENU = 'Released';
            DataClassification = ToBeClassified;
        }
        field(9; "Registrado"; Boolean)
        {
            CaptionML = ESP = 'Registrado', ENU = 'Posted';
            DataClassification = ToBeClassified;
        }
        field(10; "Pte Pago"; Boolean)
        {
            CaptionML = ESP = 'Pte. pago', ENU = 'Payment expected';
            DataClassification = ToBeClassified;
        }
        field(11; "Conf. fabrica"; Boolean)
        {
            Caption = 'Conf. en fábrica';
            DataClassification = ToBeClassified;
        }
        field(12; "PAYPAL"; Boolean)
        {
            CaptionML = ESP = 'Recargo PAYPAL', ENU = 'PAYPAL surcharge';
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(PK; idEstadoPS)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; idEstadoPS, nombreEstadoPS) { }
    }

}