//7227678
tableextension 60101 T27ItemExtension extends Item
{
    fields
    {
        field(60100; "Producto web"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Producto web', ENU = 'Web Item';
        }
        field(60101; IdPS; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Id PS', ENU = 'PS Id';
        }
        field(60102; "Descripcion larga PS"; text[250])
        {
            CaptionML = ESP = 'Descripción larga PS', ENU = 'PS description';
            DataClassification = ToBeClassified;
        }

        field(60103; "Stock Bresme"; Decimal)
        {
            Caption = 'Stock Bresme';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(60104; "Stock Comafe"; Decimal)
        {
            Caption = 'Stock Comafe';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(60105; "Multiples unidades"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(60106; "Combinacion"; Boolean)
        {
            Caption = 'Producto combinado PS';
            DataClassification = ToBeClassified;
        }
        field(60107; "Id Combinacion"; Integer)
        {
            Caption = 'Id Combinación PS';
            DataClassification = ToBeClassified;
        }
    }

}