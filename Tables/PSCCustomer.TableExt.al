//7227677
tableextension 60100 T18CustomerExtension extends Customer
{
    fields
    {
        field(60100; IdClientePS; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Id Cliente PS', ENU = 'PS Cust. Id';
        }
        field(60101; fechaAltaClientePS; DateTime)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Fecha alta PS', ENU = 'PS date add';
        }
        field(60102; IdDireccionPrincipalPS; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Id Dirección principal PS', ENU = 'PS main cust. address  Id';
        }
        field(60103; EsClientePS; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Es Cliente PS', ENU = 'Is PS Cust.';
        }

        field(60104; "Pendiente sincro B2B"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Pendiente Sincronización', ENU = 'Sync. pending';
            trigger OnValidate()
            begin
                if "Pendiente sincro B2B" then begin
                    if rec."Customer Disc. Group" = '' then
                        error('Antes de marcar la sincronización con PS debe configurar un Grupo Precios Cliente para el cliente');
                    if rec."Email PS" = '' then
                        error('Debe informar una dirección de correo electrónico en el campo Email PS para poder sincronizar el cliente con PS');
                    TestField(EsClientePS, false);
                end;
            end;
        }
        field(60105; "Email PS"; Text[100])
        {
            Caption = 'Email PS';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key("ConectorPSkey"; IdClientePS)
        {

        }
    }

}