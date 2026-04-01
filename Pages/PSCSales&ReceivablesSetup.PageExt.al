//7227682
pageextension 60105 P459_SalesAndReceivablesSetExt extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Number Series")
        {
            group("PS Sincro")
            {
                field("Cliente tarifa web"; "Cliente tarifa web")
                {
                    ApplicationArea = All;
                }
                field("Numeracion Cliente PS"; "Numeracion Clientes PS")
                {
                    ApplicationArea = All;
                }
                field("Cod. Vendedor PS"; "Cod. Vendedor PS")
                {
                    ApplicationArea = All;
                }
                field("Forma pago cliente PS"; "Forma pago cliente PS")
                {
                    ApplicationArea = All;
                }
                field("Term. pago cliente PS"; "Term. pago cliente PS")
                {
                    ApplicationArea = All;
                }
                field(SincronizacionProductos; SincronizacionProductos)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(UltimaSincroProductos; UltimaSincroProductos)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(SincronizacionTarifa; SincronizacionTarifa)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(UltimaSincroTarifa; UltimaSincroTarifa)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sincronizar imagenes FTP"; "Sincronizar imagenes FTP")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last FTP update"; "Last FTP update")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Cuenta ventas PS"; "Cuenta ventas PS")
                {
                    ApplicationArea = All;
                    ToolTipML = ESP = 'Cuenta contable que se va a utilizar para las líneas del pedido en caso de que el producto vendido en PS no se encuentre en NAV',
                        ENU = 'Cuenta contable que se va a utilizar para las líneas del pedido en caso de que el producto vendido en PS no se encuentre en NAV';
                }
                field("Tipo cuenta envios"; "Tipo cuenta envios")
                {
                    ApplicationArea = All;
                }
                field("Cuenta ventas envios"; "Cuenta ventas envios")
                {
                    ApplicationArea = All;
                    ToolTipML = ESP = 'Cuenta contable o producto que se va a utilizar para la línea de gastos de envío del pedido',
                        ENU = 'Cuenta contable o producto que se va a utilizar para la línea de gastos de envío del pedido';
                }
                field("Filtro almacen inventario PS"; "Filtro almacen inventario PS")
                {
                    ApplicationArea = All;
                    ToolTipML = ESP = 'Filtro tipo NAV con los almacenes que se van a utilizar para el cálculo de inventario que se va a sincronizar con PS',
                        ENU = 'Filtro tipo NAV con los almacenes que se van a utilizar para el cálculo de inventario que se va a sincronizar con PS';
                }
                field("Incluir movs. sin almacen PS"; "Incluir movs. sin almacen PS")
                {
                    ApplicationArea = All;
                }
                field("Almacén pedidos PS"; "Almacén pedidos PS")
                {
                    ApplicationArea = All;
                }

                field("Sincro Tarifas Automat."; "Sincro Tarifas Automat.")
                {
                    ApplicationArea = All;
                }
                field("Texto linea descuento"; "Texto linea descuento")
                {
                    ApplicationArea = All;
                }
                field("Serie Pedidos s.factura"; "Serie Pedidos s.factura")
                {
                    ApplicationArea = All;
                }
                field("Serie Pedidos c.factura"; "Serie Pedidos c.factura")
                {
                    ApplicationArea = All;
                }
                field("Sincronizar atributos"; "Sincronizar atributos")
                {
                    ApplicationArea = All;
                }
                field("Sincronizar categorias"; "Sincronizar categorias")
                {
                    ApplicationArea = All;
                }
                field("Activar productos PS"; "Activar productos PS")
                {
                    ApplicationArea = All;
                    ToolTipML = ESP = 'Si se habilita esta opción los productos se activaran al crearse en PS, en caso contrario apareceran como inactivos hasta que se activen manualmente en PS',
                        ENU = 'Si se habilita esta opción los productos se activaran al crearse en PS, en caso contrario apareceran como inactivos hasta que se activen manualmente en PS';
                }
                //PERSO ELALMACENPROFESIONAL
                field("Ud Medida productos"; "Ud Medida productos")
                {
                    ApplicationArea = All;
                }
                field("No sincronizar Stock"; "No sincronizar Stock")
                {
                    ApplicationArea = All;
                }
                field(licenseKey; licenseKey)
                {
                    ApplicationArea = All;
                    //MultiLine = true;
                    Editable = false;
                    CaptionML = ESP = 'License Key PS', ENU = 'License Key PS';

                    trigger OnAssistEdit()
                    var
                    begin
                        PAGE.RunModal(60103);
                        CurrPage.Update();
                    end;
                    /*
                    trigger OnValidate()
                    var
                    begin
                        CUPs.splitLicenseKey(LicenseKey, "License Key 1", "License Key 2");
                        VALIDATE("License Key 1");
                        VALIDATE("License Key 2");
                        MODIFY(TRUE);
                    end;
                    */
                }

            }

            group("PS Sincro 3")
            {
                Caption = 'PS SINCRO - Campos Personalizados PEPEBAR';
                field("Id DescVar Pto 1"; "Id DescVar Pto 1")
                {
                    ApplicationArea = All;
                }
                field("Id DescVar Pto 2"; "Id DescVar Pto 2")
                {
                    ApplicationArea = All;
                }
                field("Id DescVar Pto 3"; "Id DescVar Pto 3")
                {
                    ApplicationArea = All;
                }
                field("Id DescVar Pto 4"; "Id DescVar Pto 4")
                {
                    ApplicationArea = All;
                }
                field("Producto recargo PAYPAL"; Rec."Producto recargo PAYPAL")
                {
                    ApplicationArea = All;
                }
            }

            group("PS Sincro 2")
            {
                group("Clientes Nacionales")
                {
                    CaptionML = ESP = 'Clientes nacionales', ENU = 'Clientes nacionales';

                    field("Grupo contable cl. PS"; "Grupo contable cl. PS")
                    {
                        ApplicationArea = All;
                    }
                    field("Grupo contable neg. PS"; "Grupo contable neg. PS")
                    {
                        ApplicationArea = All;
                    }
                    field("Grupo contable IVA PS"; "Grupo contable IVA PS")
                    {
                        ApplicationArea = All;
                    }
                    field("Zonas PS nacional"; "Zonas PS nacional")
                    {
                        ApplicationArea = All;
                        ToolTipML = ESP = 'Ids de las zonas PS separados por comas', ENU = 'Ids de las zonas PS separados por comas';
                    }
                }

                group("Clientes Nacionales esp.")
                {
                    CaptionML = ESP = 'Clientes nacionales especiales', ENU = 'Clientes nacionales especiales';

                    field("Grupo contable cl. PS nac esp"; "Grupo contable cl. PS nac esp")
                    {
                        ApplicationArea = All;
                    }
                    field("Grupo contable neg. PS nac esp"; "Grupo contable neg. PS nac esp")
                    {
                        ApplicationArea = All;
                    }
                    field("Grupo contable IVA PS nac esp"; "Grupo contable IVA PS nac esp")
                    {
                        ApplicationArea = All;
                    }
                    field("Zonas PS nacional esp."; "Zonas PS nacional esp.")
                    {
                        ApplicationArea = All;
                        ToolTipML = ESP = 'Ids de las zonas PS separados por comas', ENU = 'Ids de las zonas PS separados por comas';
                    }
                }

                group("Clientes UE")
                {
                    CaptionML = ESP = 'Clientes UE', ENU = 'Clientes UE';

                    field("Grupo contable cl. PS UE"; "Grupo contable cl. PS UE")
                    {
                        ApplicationArea = All;
                    }
                    field("Grupo contable neg. PS UE"; "Grupo contable neg. PS UE")
                    {
                        ApplicationArea = All;
                    }
                    field("Grupo contable IVA PS UE"; "Grupo contable IVA PS UE")
                    {
                        ApplicationArea = All;
                    }
                    field("Zonas PS UE"; "Zonas PS UE")
                    {
                        ApplicationArea = All;
                        ToolTipML = ESP = 'Ids de las zonas PS separados por comas', ENU = 'Ids de las zonas PS separados por comas';
                    }
                }

                group("Clientes No UE")
                {
                    CaptionML = ESP = 'Clientes No UE', ENU = 'Clientes No UE';

                    field("Grupo contable cl. PS no UE"; "Grupo contable cl. PS no UE")
                    {
                        ApplicationArea = All;
                    }
                    field("Grupo contable neg. PS no UE"; "Grupo contable neg. PS no UE")
                    {
                        ApplicationArea = All;
                    }
                    field("Grupo contable IVA PS no UE"; "Grupo contable IVA PS no UE")
                    {
                        ApplicationArea = All;
                    }
                    field("Zonas PS no UE"; "Zonas PS no UE")
                    {
                        ApplicationArea = All;
                        ToolTipML = ESP = 'Ids de las zonas PS separados por comas', ENU = 'Ids de las zonas PS separados por comas';
                    }
                }
            }

        }
    }

    actions
    {
        addlast(navigation)
        {
            group("PS Sincro actions")
            {
                CaptionML = ESP = 'PS Sincro', ENU = 'PS Sync.';
                Visible = true;

                action("Marcar sinc.productos")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Marcar sincronizacion de productos', ENU = 'Marcar sincronizacion de productos';
                    Image = Reuse;

                    trigger OnAction();
                    var
                    begin
                        IF CONFIRM(Text001) THEN BEGIN
                            SincronizacionProductos := TRUE;
                            MODIFY();
                        END;
                    end;
                }

                action("Marcar sinc.tarifas")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Marcar sincronizacion de tarifas', ENU = 'Marcar sincronizacion de tarifas';
                    Image = PriceAdjustment;

                    trigger OnAction();
                    var
                    begin
                        IF CONFIRM(Text002) THEN BEGIN
                            SincronizacionTarifa := TRUE;
                            MODIFY();
                        END;
                    end;
                }

                action("EstadosPedido")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Editar estados pedido PS', ENU = 'Editar estados pedido PS';
                    Image = Status;
                    RunObject = page "Lista Estados Pedido PS";

                }

                action("Act.Inventario")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Actualizar inventario productos', ENU = 'Actualizar inventario productos';
                    Image = UpdateShipment;

                    trigger OnAction();
                    var
                        cuPS: Codeunit PSSincro;
                    begin
                        IF CONFIRM(Text003) THEN BEGIN
                            cuPS.sincronizarStockTodosProductos();
                        END;
                    end;
                }

                action("Act.Categorias")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Actualizar categorias productos', ENU = 'Actualizar categorias productos';
                    Image = Route;

                    trigger OnAction();
                    var
                        cuPS: Codeunit PSSincro;
                        rSalesSetup: Record "Sales & Receivables Setup";
                    begin
                        rSalesSetup.get();
                        if rSalesSetup."Sincronizar categorias" = rSalesSetup."Sincronizar categorias"::No then
                            Error(Text006);

                        IF CONFIRM(Text004) THEN BEGIN
                            cuPS.sincronizarCategoriasTodosProductos();
                        END;
                    end;
                }

                action("Act.Atributos")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Actualizar características productos', ENU = 'Actualizar características productos';
                    Image = Category;

                    trigger OnAction();
                    var
                        cuPS: Codeunit PSSincro;
                        rSalesSetup: Record "Sales & Receivables Setup";
                    begin
                        rSalesSetup.Get();
                        if rSalesSetup."Sincronizar atributos" = rSalesSetup."Sincronizar atributos"::No then
                            Error(Text006);

                        IF CONFIRM(Text005) THEN BEGIN
                            cuPS.sincronizarCaracteristicasTodosProductos();
                        END;
                    end;
                }

                action("Act.Imagenes")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Actualizar imágenes productos', ENU = 'Actualizar imágenes productos';
                    Image = AbsenceCategory;

                    trigger OnAction();
                    var
                        cuPS: Codeunit PSSincro;
                    begin
                        IF CONFIRM(Text008) THEN BEGIN
                            cuPS.sincronizarImagenesTodosProductos();
                        END;
                    end;
                }
                action("Sincrodescripciones")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Actualizar descripciones productos', ENU = 'Actualizar descripciones productos';
                    Image = CopyDocument;

                    trigger OnAction();
                    var
                        CuPS: Codeunit PSSincro;
                    begin

                        IF CONFIRM(Text010) THEN
                            CuPS.sincronizarDescripcionesTodosProductos();
                    end;
                }
                action("Sincrocamposper")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Actualizar campos personalizados productos', ENU = 'Actualizar campos personalizados productos';
                    Image = CopyDocument;

                    trigger OnAction();
                    var
                        CuPS: Codeunit PSSincro;
                    begin

                        IF CONFIRM(Text012) THEN
                            CuPS.sincronizarCamposPersonalizadosTodosProductos();
                    end;
                }
                action("Resincronizar pedido PS")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Resincronizar pedido PS', ENU = 'PS Order Resync';
                    Image = RefreshVATExemption;
                    RunObject = report "Resincronizar pedidoPS";
                }

                action("Modificar ultimo pedido PS")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Modificar ultimo id pedido PS sincronizaro', ENU = 'Modify last psId Order sync.';
                    Image = LinkAccount;
                    RunObject = report "Modificar ultimo id pedido PS";
                }
                action("Resincronizar unidades multiples")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Resincronizar multiples unidades', ENU = 'Resincronizar multiples unidades';
                    Image = LinkAccount;
                    trigger OnAction()
                    var
                        cuPS: Codeunit PSSincro;
                    begin
                        IF CONFIRM(Text011) THEN
                            cuPS.sincronizarMultiplesUnidadesTodosProductos();
                    end;
                }
                action("Restablecer productos")
                {
                    ApplicationArea = all;
                    CaptionML = ESP = 'Restablecer productos PS', ENU = 'Restablecer productos PS';
                    Image = UnLinkAccount;

                    trigger OnAction()
                    var
                        rItem: Record Item;
                    begin
                        if not Confirm('Esta acción restablecerá los IDs de producto para que se sincronicen automáticamente desde el conector PS \¿Está seguro de que quiere realizar la acción?', false) then
                            exit;

                        rItem.Reset();
                        rItem.SetRange("Producto web", true);
                        if rItem.FindSet() then begin
                            rItem.ModifyAll("Producto web", false);
                        end;

                        rItem.Reset();
                        rItem.SetFilter(IdPS, '>0');
                        if rItem.FindSet() then begin
                            rItem.ModifyAll(Combinacion, false);
                            rItem.ModifyAll("Id Combinacion", 0);
                            rItem.ModifyAll(IdPS, 0);
                        end;
                    end;
                }
                action(DESARROLLO)
                {
                    //INICIALIZAR PRODUCTOS, CATEGORIAS, CLIENTES, ATRIBUTOS, DIRECCIONES ENVIO
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        rCustomer: Record Customer;
                        rItem: Record item;
                        rItemAttributes: record "Item Attribute";
                        ritemAttValues: Record "Item Attribute Value";
                        rItemCategories: Record "Item Category";
                        rShipToAdd: Record "Ship-to Address";
                        rasincronas: Record "Modificaciones Asincronas PS";
                    begin
                        /*
                        if not Confirm('Esto borrará todos los datos sincronizados, ¿ Desea continuar ?', false) then
                            exit;

                        rCustomer.Reset();
                        rCustomer.SetFilter(IdClientePS, '>0');
                        if rCustomer.FindSet() then begin
                            rCustomer.ModifyAll(IdClientePS, 0);
                            rCustomer.ModifyAll(EsClientePS, false);
                            rCustomer.ModifyAll(IdDireccionPrincipalPS, 0);
                            rCustomer.ModifyAll("Pendiente sincro B2B", false);
                        end;

                        rShipToAdd.Reset();
                        rShipToAdd.SetFilter(IdDireccionPS, '>0');
                        if rShipToAdd.FindSet() then
                            rShipToAdd.ModifyAll(IdDireccionPS, 0);

                        rItem.Reset();
                        rItem.SetRange("Producto web", true);
                        if rItem.FindSet() then begin
                            rItem.ModifyAll(IdPS, 0);
                            rItem.ModifyAll("Producto web", false);
                        end;

                        rItemAttributes.Reset();
                        rItemAttributes.SetFilter(IdPS, '>0');
                        if rItemAttributes.FindSet() then begin
                            rItemAttributes.ModifyAll(IdPS, 0);
                        end;

                        ritemAttValues.Reset();
                        ritemAttValues.SetFilter(IdPS, '>0');
                        if ritemAttValues.FindSet() then begin
                            ritemAttValues.ModifyAll(IdPS, 0);
                        end;

                        rItemCategories.Reset();
                        rItemCategories.SetFilter(IdPS, '>0');
                        if rItemCategories.FindSet() then begin
                            rItemCategories.ModifyAll(IdPS, 0);
                        end;
                        */

                        if (Confirm('esto es desarrollo, continuar?')) then begin
                            /*
                            ritemAttValues.Reset();
                            ritemAttValues.SetFilter(IdPS, '>0');
                            if ritemAttValues.FindSet() then begin
                                ritemAttValues.ModifyAll(IdPS, 0);
                            end;
                            */
                            rasincronas.Reset();
                            rasincronas.SetFilter("Fecha/Hora", '%1..', CreateDateTime(DMY2Date(11, 1, 2023), 0T));
                            rasincronas.SetRange("Fecha/Hora proceso", 0DT);
                            rasincronas.SetRange(Tipo, rasincronas.Tipo::"Campos personalizados");
                            if rasincronas.FindSet() then
                                rasincronas.ModifyAll(Procesado, false);
                        end;

                    end;
                }
            }
        }
    }

    var
        Text001: TextConst ESP = 'Va a marcar la sincronizacion de productos NAV->PS durante el siguiente ciclo de sincronización, ¿ Desea continuar ?',
            ENU = 'Va a marcar la sincronizacion de productos NAV->PS durante el siguiente ciclo de sincronización, ¿ Desea continuar ?';

        Text002: TextConst ESP = 'Va a marcar la sincronizacion de tarifas NAV->PS durante el siguiente ciclo de sincronización, ¿ Desea continuar ?',
            ENU = 'Va a marcar la sincronizacion de tarifas NAV->PS durante el siguiente ciclo de sincronización, ¿ Desea continuar ?';

        Text003: TextConst ESP = 'La siguiente acción marcará sincronización de stock para todos los productos marcados como "producto web" ¿ Desea continuar ?',
            ENU = 'La siguiente acción marcará sincronización de stock para todos los productos marcados como "producto web" ¿ Desea continuar ?';
        Text004: TextConst ESP = 'La siguiente acción marcará sincronización de categorías para todos los productos marcados como "producto web" ¿ Desea continuar ?',
            ENU = 'La siguiente acción marcará sincronización de categorías para todos los productos marcados como "producto web" ¿ Desea continuar ?';
        Text005: TextConst ESP = 'La siguiente acción marcará sincronización de características para todos los productos marcados como "producto web" ¿ Desea continuar ?',
            ENU = 'La siguiente acción marcará sincronización de características para todos los productos marcados como "producto web" ¿ Desea continuar ?';
        Text006: TextConst ESP = 'La sincronización de categorías está desactivada, no se puede ejecutar la acción',
            ENU = 'La sincronización de categorías está desactivada, no se puede ejecutar la acción';
        Text007: TextConst ESP = 'La sincronización de características está desactivada, no se puede ejecutar la acción',
            ENU = 'La sincronización de características está desactivada, no se puede ejecutar la acción';
        Text008: TextConst ESP = 'La siguiente acción marcará sincronización de imágenes para todos los productos marcados como "producto web" ¿ Desea continuar ?',
            ENU = 'La siguiente acción marcará sincronización de imágenes para todos los productos marcados como "producto web" ¿ Desea continuar ?';
        Text010: TextConst ESP = 'La siguiente acción marcará sincronización de descripciones para todos los productos marcados como "producto web" ¿ Desea continuar ?',
            ENU = 'La siguiente acción marcará sincronización de descripciones para todos los productos marcados como "producto web" ¿ Desea continuar ?';
        Text011: TextConst ESP = 'La siguiente acción marcará sincronización de múltiples unidades en los productos marcados como "producto web" ¿ Desea continuar ?',
            ENU = 'La siguiente acción marcará sincronización de múltiples unidades en los productos marcados como "producto web" ¿ Desea continuar ?';
        Text012: TextConst ESP = 'La siguiente acción marcará sincronización de campos personalizados en los productos marcados como "producto web" ¿ Desea continuar ?',
            ENU = 'La siguiente acción marcará sincronización de campos personalizados en los productos marcados como "producto web" ¿ Desea continuar ?';

        licenseKey: Text;
        cuPS: Codeunit PSSincro;


    trigger OnAfterGetCurrRecord()
    var
    begin
        cuPS.combineLicenseKey(rec."License key 1", rec."License key 2", licenseKey);
    end;
}