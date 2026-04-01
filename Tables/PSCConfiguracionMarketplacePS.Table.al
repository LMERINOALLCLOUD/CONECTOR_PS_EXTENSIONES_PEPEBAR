//MARKETPLACE no se usan no borrar porque sino da error al actualizar extension
table 60102 ConfiguracionMarketplacePS
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Cod. Marketplace"; Code[20])
        {
            //numeración maual no se incluye ningún número de serie para establecer el código
            Caption = 'Cod. Marketplace';
            DataClassification = ToBeClassified;
        }
        field(2; "Id Estado Pedido PS"; Text[10])
        {
            //relación con el estado pedido de PS para la entrada de pedidos del marketplace
            CaptionML = ESP = 'Id Estado Pedido PS', ENU = 'PS Order Status Id';
            DataClassification = ToBeClassified;
            TableRelation = "Relacion de estados pedido PS";
        }
        field(3; "Desc. estado pedido PS"; Text[50])
        {
            Caption = 'MyField';

            FieldClass = FlowField;
            CalcFormula = lookup("Relacion de estados pedido PS".nombreEstadoPS where(idEstadoPS = field("Id Estado Pedido PS")));
        }
        field(4; "Tipo Margen"; Option)
        {
            CaptionML = ESP = 'Tipo margen', ENU = 'Calculation type';
            DataClassification = ToBeClassified;
            OptionMembers = "Porentual","Importe Fijo";
        }
        field(5; "Importe minimo"; Decimal)
        {
            CaptionML = ESP = 'Importe mínimo', ENU = 'Min. Amount';
            DataClassification = ToBeClassified;
        }
        field(6; "Cuota"; Decimal)
        {
            CaptionML = ESP = 'Cuota o margen %', ENU = 'Pecentage o fixed amount';
            DataClassification = ToBeClassified;
        }
        field(7; "Importe total en pedidos"; Decimal)
        {
            //flowfield que suma los impotes del margen de todos los pedidos PS que tienen esta cuota de marketplace
            CaptionML = ESP = 'Importe total en pedidos', ENU = 'Total amount in orders';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Header"."Importe cuota marketplace" where("Cuota marketplace" = field("Cod. Marketplace")));
        }
        field(8; "Incluye gastos envio"; Boolean)
        {
            //si incluye los gastos de envío para el cálculo de la cuota (solo para cuota porcentual)
            CaptionML = ESP = 'Incluye gastos de envío', ENU = 'Shipping cost included';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Cod. Marketplace")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        notification: Notification;
    begin
        if "Cod. Marketplace" = '' then begin
            notification.Scope := NotificationScope::LocalScope;
            notification.Message := 'Debe informar el código del marketplace, no puede ser vacío';
            notification.Send();
            Error('Cód. no puede ser vacío');
        end;
    end;

}