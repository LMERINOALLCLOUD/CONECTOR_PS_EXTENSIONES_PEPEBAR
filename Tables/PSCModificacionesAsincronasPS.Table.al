//7227678
table 60101 "Modificaciones Asincronas PS"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "idAsync"; Integer)
        {
            Caption = 'Id';
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }

        field(2; "IdOrigen"; Code[20])
        {
            CaptionML = ESP = 'Id Origen', ENU = 'Source Id';
            DataClassification = ToBeClassified;
        }

        field(3; "IdDestino"; Code[20])
        {
            CaptionML = ESP = 'Id Destino', ENU = 'Destination Id';
            DataClassification = ToBeClassified;
        }

        field(4; "Tipo"; Option)
        {
            CaptionML = ESP = 'Tipo', ENU = 'Type';
            DataClassification = ToBeClassified;
            OptionMembers = "Estado Pedido",Stock,Seguimiento,"Baja Producto",Tarifa,Pedido,Categoria,Atributos,"Imagenes producto","Pedido-compra-INN",Marca,"Descripcion larga","Grupo Cliente","Update Categoria Tree","Campos personalizados","Unidades multiples",Fabricante;
        }

        field(5; "Cantidad"; Decimal)
        {
            CaptionML = ESP = 'Cantidad', ENU = 'Qty';
            DataClassification = ToBeClassified;
        }

        field(6; "Procesado"; Boolean)
        {
            CaptionML = ESP = 'Procesado', ENU = 'Processed';
            DataClassification = ToBeClassified;
        }

        field(7; "Texto"; Text[30])
        {
            CaptionML = ESP = 'Texto', ENU = 'Text';
            DataClassification = ToBeClassified;
        }

        field(8; "Fecha/Hora"; DateTime)
        {
            CaptionML = ESP = 'Fecha/Hora creación', ENU = 'Creation Date/Time';
            DataClassification = ToBeClassified;
        }

        field(9; "Fecha/Hora proceso"; DateTime)
        {
            CaptionML = ESP = 'Fecha/Hora de proceso', ENU = 'Processing Date/Time';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; idAsync)
        {
            Clustered = true;
        }
    }

}