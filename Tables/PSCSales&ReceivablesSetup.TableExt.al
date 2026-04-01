//7227682
tableextension 60105 T311SalesReceivablesSetExt extends "Sales & Receivables Setup"
{
    fields
    {
        field(60100; "Cliente tarifa web"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Cliente para web', ENU = 'PS Web customer';
            TableRelation = Customer;
        }

        field(60101; "Numeracion Clientes PS"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Numeración para clientes web', ENU = 'Web cust. series No.';
            TableRelation = "No. Series";
        }

        field(60102; "Cod. Vendedor PS"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Cód. vendedor PS', ENU = 'PS Salesman Code';
            TableRelation = "Salesperson/Purchaser";
        }
        //NO SE USA
        field(60103; "Grupo contable cliente PS"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Grupo contable cliente PS', ENU = 'Cust. posting group PS';
            TableRelation = "Customer Posting Group";
        }
        //NO SE USA
        field(60104; "Grupo contable negocio PS"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Id dirección PS', ENU = 'PS address Id';
            TableRelation = "Gen. Business Posting Group";
        }

        field(60105; "Forma pago cliente PS"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Forma pago cliente PS', ENU = 'PS customer payment method';
            TableRelation = "Payment Method";
        }

        field(60106; "Term. pago cliente PS"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Term. pago cliente PS', ENU = 'PS customer payment terms';
            TableRelation = "Payment Terms";
        }

        field(60107; "SincronizacionTarifa"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Sincronización tarifas', ENU = 'Sales price sync.';
        }

        field(60108; "SincronizacionProductos"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Sincronización productos', ENU = 'Item sync.';
        }

        field(60109; "UltimaSincroTarifa"; DateTime)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Últ. sincro tarifas', ENU = 'Sales price last sync.';
        }

        field(60110; "UltimaSincroProductos"; DateTime)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Últ. sincro productos', ENU = 'Items last sync.';
        }

        field(60111; "Cuenta ventas PS"; Code[20])
        {
            //PSSINCRO para los productos que no estén sincronizados
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Cuenta ventas PS', ENU = 'PS Sales g/l account';
            TableRelation = "G/L Account";
        }

        field(60112; "Tipo cuenta envios"; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Tipo cuenta envios PS', ENU = 'PS shipment type account';
            OptionMembers = Cuenta,Producto;
        }

        field(60113; "Cuenta ventas envios"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Cuenta envios PS', ENU = 'PS shipping account';
            TableRelation = if ("Tipo cuenta envios" = const(Cuenta)) "G/L Account"
            else
            if ("Tipo cuenta envios" = const(Producto)) Item;
        }

        field(60114; "Filtro almacen inventario PS"; Text[100])
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Filtro almacen inventario PS', ENU = 'PS location inventory filter';
        }

        field(60115; "Incluir movs. sin almacen PS"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Incluir movs. sin almacen PS', ENU = 'Include empty location entries';
        }

        field(60116; "Id pedido PS ultimo"; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Ultimo ID pedido PS sincronizado', ENU = 'Last PS order ID sync.';
        }

        field(60117; "Grupo contable cl. PS nac esp"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Customer Posting Group";
        }

        field(60118; "Grupo contable neg. PS nac esp"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group";
        }

        field(60119; "Grupo contable IVA PS nac esp"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "VAT Business Posting Group";
        }

        field(60120; "Zonas PS nacional esp."; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(60121; "Grupo contable cl. PS"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Customer Posting Group";
        }

        field(60122; "Grupo contable neg. PS"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group";
        }

        field(60123; "Grupo contable IVA PS"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "VAT Business Posting Group";
        }

        field(60124; "Zonas PS nacional"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(60125; "Grupo contable cl. PS UE"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Customer Posting Group";
        }

        field(60126; "Grupo contable neg. PS UE"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group";
        }

        field(60127; "Grupo contable IVA PS UE"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "VAT Business Posting Group";
        }

        field(60128; "Zonas PS UE"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(60129; "Grupo contable cl. PS no UE"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Customer Posting Group";
        }

        field(60130; "Grupo contable neg. PS no UE"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group";
        }

        field(60131; "Grupo contable IVA PS no UE"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "VAT Business Posting Group";
        }

        field(60132; "Zonas PS no UE"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(60133; "Texto linea descuento"; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(60134; "Sincro Tarifas Automat."; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(60135; "Serie Pedidos s.factura"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }

        field(60136; "Serie Pedidos c.factura"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }

        field(60137; "License key 1"; text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(60138; "License key 2"; text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(60139; "Almacén pedidos PS"; Code[20])
        {
            CaptionML = ESP = 'Almacén pedidos PS';
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(60140; "Sincronizar atributos"; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Sincronizar atributos', ENU = 'Attribute Sync.';
            OptionMembers = No,Si,Automatica;
            OptionCaptionML = ESP = 'No,Sí,Automática', ENU = 'No,Yes,Automatic';
        }
        field(60141; "Sincronizar categorias"; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ESP = 'Sincronizar categorías', ENU = 'Category Sync.';
            OptionMembers = No,Si,Automatica;
            OptionCaptionML = ESP = 'No,Sí,Automática', ENU = 'No,Yes,Automatic';
        }
        //PERSO ELALMACENDELPROFESIONAL
        field(60142; "Ud Medida productos"; Code[10])
        {
            Caption = 'Ud. Medida defecto productos web';
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure";
        }
        field(60143; "Activar productos PS"; Option)
        {
            CaptionML = ESP = 'Activar productos en PS', ENU = 'Activate PS Products';
            DataClassification = ToBeClassified;
            OptionMembers = Si,No;
            OptionCaptionML = ESP = 'Sí,No', ENU = 'Yes,No';
        }

        //PERSO SINCRONIZACIÓN IMÁGENES DESDE FTP
        field(60144; "Last FTP update"; DateTime)
        {
            CaptionML = ESP = 'Últ. actualización FTP', ENU = 'Last FTP update';
            DataClassification = ToBeClassified;
        }

        field(60154; "Sincronizar imagenes FTP"; Boolean)
        {
            CaptionML = ESP = 'Sincronizar imágenes FTP', ENU = 'Sincronize FTP images';
            DataClassification = ToBeClassified;
        }

        //CAMPOS PERSONALIZADOS PEPEBAR
        field(60180; "Id DescVar Pto 1"; Integer)
        {
            Caption = 'Id Att. PS DescVar Pto 1';
            DataClassification = ToBeClassified;
        }
        field(60181; "Id DescVar Pto 2"; Integer)
        {
            Caption = 'Id Att. PS DescVar Pto 2';
            DataClassification = ToBeClassified;
        }
        field(60182; "Id DescVar Pto 3"; Integer)
        {
            Caption = 'Id Att. PS DescVar Pto 3';
            DataClassification = ToBeClassified;
        }
        field(60183; "Id DescVar Pto 4"; Integer)
        {
            Caption = 'Id Att. PS DescVar Pto 4';
            DataClassification = ToBeClassified;
        }
        field(60190; "No sincronizar Stock"; Boolean)
        {
            Caption = 'No sincronizar Stock con PS';
            DataClassification = ToBeClassified;
        }

        //nueva funcionalidad recargos PAYPAL
        field(60184; "Producto recargo PAYPAL"; Code[20])
        {
            Caption = 'Producto recargo PAYPAL';
            DataClassification = ToBeClassified;
            TableRelation = Item;
        }
        field(60198; "Check referencias PS"; Boolean)
        {
            Caption = 'Check referencias PS';
            DataClassification = ToBeClassified;
        }
        field(60199; "Listado referencias PS"; Blob)
        {
            Caption = 'Listado ref. PS';
            Description = 'listado de todas las referencias existentes en PS (Activas) formato xxxx|xxxx';
            DataClassification = ToBeClassified;
        }


    }

}