//numeración licencia allcloud 7227677
codeunit 60100 "PS Sincro Suscribers"
{
    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterPostItem', '', true, true)]
    local procedure OnAfterPostItemLedgerEntry(var ItemJournalLine: Record "Item Journal Line")
    var
        cuPSSincro: Codeunit PSSincro;
    begin
        cuPSSincro.insertarOperacionActStock(ItemJournalLine."Item No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    LOCAL procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20];
        SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean)
    var
        rEstadosPS: Record "Relacion de estados pedido PS";
        cuPSSincro: Codeunit PSSincro;
    begin
        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) AND (SalesHeader.IdPedidoPS > 0) THEN BEGIN
            rEstadosPS.RESET();
            rEstadosPS.SETRANGE(Registrado, TRUE);
            IF rEstadosPS.FINDFIRST() THEN begin
                cuPSSincro.insertarOperacionActEstPedidoAutomatica(SalesHeader.IdPedidoPS, rEstadosPS.idEstadoPS);
                SalesHeader."Estado Pedido PS" := rEstadosPS.idEstadoPS;
                SalesHeader.MODIFY();
            end;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 414, 'OnAfterReleaseSalesDoc', '', true, true)]
    local procedure OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        rEstadosPS: Record "Relacion de estados pedido PS";
        cuPSSincro: Codeunit PSSincro;
    begin
        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) AND (SalesHeader.IdPedidoPS > 0) THEN BEGIN
            rEstadosPS.RESET();
            rEstadosPS.SETRANGE(rEstadosPS.Lanzado, TRUE);
            IF rEstadosPS.FINDFIRST() THEN BEGIN
                cuPSSincro.insertarOperacionActEstPedidoAutomatica(SalesHeader.IdPedidoPS, rEstadosPS.idEstadoPS);
                //ACTUALIZAMOS EL ESTADO DEL PEDIDO
                SalesHeader."Estado Pedido PS" := rEstadosPS.idEstadoPS;
                SalesHeader.Modify();
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Unit Price', true, true)]
    local procedure OnAfterValidateItemTable(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        cuPS: Codeunit PSSincro;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        if not rec.IsTemporary then begin
            if rSalesSetup."Sincro Tarifas Automat." then begin
                if Rec.IdPS > 0 then begin
                    if xRec."Unit Price" <> Rec."Unit Price" then
                        cups.insertarOperacionActTarifa(rec.IdPS);
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Item Category Code', true, true)]
    local procedure OnAfterValidateItemTableCategoryCode(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        cuPS: Codeunit PSSincro;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();
        if rSalesSetup."Sincronizar categorias" = rSalesSetup."Sincronizar categorias"::Automatica then begin
            if Rec.IdPS > 0 then begin
                if xRec."Item Category Code" <> Rec."Item Category Code" then
                    cups.insertarOperacionActualizacionCategoria(rec."No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Descripcion larga PS', true, true)]
    local procedure OnAfterValidateItemTableDescripcionLargaPS(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        cuPS: Codeunit PSSincro;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();

        if Rec.IdPS > 0 then begin
            if xRec."Descripcion larga PS" <> Rec."Descripcion larga PS" then
                cups.insertarOperacionActualizacionDescripcionLarga(rec."No.");
        end;

    end;

    [EventSubscriber(ObjectType::Table, 7505, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertEventItemAttributeValueMaping(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();
        if rSalesSetup."Sincronizar atributos" = rSalesSetup."Sincronizar atributos"::Automatica then begin
            if rec."Table ID" = 27 then begin
                rItem.Get(rec."No.");
                if rItem.IdPS > 0 then begin
                    cups.insertarOperacionActualizacionAtributos(rItem."No.");
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 7505, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyEventItemAttributeValueMaping(var Rec: Record "Item Attribute Value Mapping"; var xRec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();
        if rSalesSetup."Sincronizar atributos" = rSalesSetup."Sincronizar atributos"::Automatica then begin
            if rec."Table ID" = 27 then begin
                if rec."Item Attribute Value ID" <> xRec."Item Attribute Value ID" then begin
                    rItem.Get(rec."No.");
                    if rItem.IdPS > 0 then begin
                        cups.insertarOperacionActualizacionAtributos(rItem."No.");
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 7505, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteEventItemAttributeValueMaping(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();
        if rSalesSetup."Sincronizar atributos" = rSalesSetup."Sincronizar atributos"::Automatica then begin
            if rec."Table ID" = 27 then begin
                rItem.Get(rec."No.");
                if rItem.IdPS > 0 then begin
                    cups.insertarOperacionActualizacionAtributos(rItem."No.");
                end;
            end;
        end;
    end;

    //price calculation
    [EventSubscriber(ObjectType::Table, 7002, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertEventSalesPrice(var Rec: Record "Sales Price"; RunTrigger: Boolean)
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();
        if not rec.IsTemporary then begin
            if rSalesSetup."Sincro Tarifas Automat." then begin
                rItem.get(Rec."Item No.");
                if rItem.IdPS > 0 then begin
                    cups.insertarOperacionActTarifa(rItem.IdPS);
                end;
            end;
        end;
    end;

    /*SE ELIMINA ESTE EVENTO Y SE SUSTITUYE POR EL ONAFTERVALIDATE YA QUE ESTE A VECES NO SE LANZA AL IMPORTAR TARIFAS DESDE RAPID-START
    [EventSubscriber(ObjectType::Table, 7002, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyEventSalesPrice(var Rec: Record "Sales Price"; var xRec: Record "Sales Price"; RunTrigger: Boolean)
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();
        if not rec.IsTemporary then begin
            if rSalesSetup."Sincro Tarifas Automat." then begin
                rItem.get(Rec."Item No.");
                if rItem.IdPS > 0 then begin
                    if (rec."Unit Price" <> xRec."Unit Price") then
                        cups.insertarOperacionActTarifa(rItem.IdPS);
                end;
            end;
        end;
    end;
    */

    [EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnAfterValidateEvent', 'Unit Price', true, true)]
    local procedure "Sales Price_OnAfterValidateEvent_Unit Price"
    (
        var Rec: Record "Sales Price";
        var xRec: Record "Sales Price";
        CurrFieldNo: Integer
    )
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();
        if not rec.IsTemporary then begin
            if rSalesSetup."Sincro Tarifas Automat." then begin
                rItem.get(Rec."Item No.");
                if rItem.IdPS > 0 then begin
                    if (rec."Unit Price" <> xRec."Unit Price") then
                        cups.insertarOperacionActTarifa(rItem.IdPS);
                end;
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Sales Line Discount", 'OnAfterValidateEvent', 'Line Discount %', true, true)]
    local procedure "Sales Line Discount_OnAfterValidateEvent_Line Discount %"
    (
        var Rec: Record "Sales Line Discount";
        var xRec: Record "Sales Line Discount";
        CurrFieldNo: Integer
    )
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        if Rec.Type <> Rec.Type::Item then
            exit;

        if not rec.IsTemporary then begin
            if rSalesSetup."Sincro Tarifas Automat." then begin
                IF rItem.get(Rec.Code) then
                    if rItem.IdPS > 0 then begin
                        if (rec."Line Discount %" <> xRec."Line Discount %") then
                            cups.insertarOperacionActTarifa(rItem.IdPS);
                    end;
            end;
        end;
    end;



    [EventSubscriber(ObjectType::Table, 7002, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteEventItemSalesPrice(var Rec: Record "Sales Price"; RunTrigger: Boolean)
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.get();
        if not rec.IsTemporary then begin
            if rSalesSetup."Sincro Tarifas Automat." then begin
                rItem.get(Rec."Item No.");
                if rItem.IdPS > 0 then begin
                    cups.insertarOperacionActTarifa(rItem.IdPS);
                end;
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnAfterValidateEvent', 'Customer Disc. Group', true, true)]
    local procedure "Customer_OnAfterValidateEvent_Customer Price Group"
    (
        var Rec: Record "Customer";
        var xRec: Record "Customer";
        CurrFieldNo: Integer
    )
    var
        cuPS: Codeunit PSSincro;
    begin
        if (xRec."Customer Disc. Group" <> rec."Customer Disc. Group") and (rec."Customer Disc. Group" <> '') and (Rec.IdClientePS > 0) then
            cuPS.insertarOperacionActGrupoCliente(rec."No.", rec."Customer Disc. Group");
    end;

    /*incorrecto hay que mirar en la tabla descripciones varias
        [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterValidateEvent', 'DescVar Prod Pto 1', true, true)]
        local procedure "Item_OnAfterValidateEvent_DescVar Prod Pto 1"
        (
            var Rec: Record "Item";
            var xRec: Record "Item";
            CurrFieldNo: Integer
        )
        var
            cuPS: Codeunit PSSincro;
        begin
            if (xRec."DescVar Prod Pto 1" <> rec."DescVar Prod Pto 1") then
                cuPS.insertarOperacionCamposPersonalizados(Rec."No.");
        end;

        [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterValidateEvent', 'DescVar Prod Pto 2', true, true)]
        local procedure "Item_OnAfterValidateEvent_DescVar Prod Pto 2"
        (
            var Rec: Record "Item";
            var xRec: Record "Item";
            CurrFieldNo: Integer
        )
        var
            cuPS: Codeunit PSSincro;
        begin
            if (xRec."DescVar Prod Pto 2" <> rec."DescVar Prod Pto 2") then
                cuPS.insertarOperacionCamposPersonalizados(Rec."No.");
        end;

        [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterValidateEvent', 'DescVar Prod Pto 3', true, true)]
        local procedure "Item_OnAfterValidateEvent_DescVar Prod Pto 3"
        (
            var Rec: Record "Item";
            var xRec: Record "Item";
            CurrFieldNo: Integer
        )
        var
            cuPS: Codeunit PSSincro;
        begin
            if (xRec."DescVar Prod Pto 3" <> rec."DescVar Prod Pto 3") then
                cuPS.insertarOperacionCamposPersonalizados(Rec."No.");
        end;

        [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterValidateEvent', 'DescVar Prod Pto 4', true, true)]
        local procedure "Item_OnAfterValidateEvent_DescVar Prod Pto 4"
        (
            var Rec: Record "Item";
            var xRec: Record "Item";
            CurrFieldNo: Integer
        )
        var
            cuPS: Codeunit PSSincro;
        begin
            if (xRec."DescVar Prod Pto 4" <> rec."DescVar Prod Pto 4") then
                cuPS.insertarOperacionCamposPersonalizados(Rec."No.");
        end;

        [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterValidateEvent', 'Descripcion web larga', true, true)]
        local procedure "Item_OnAfterValidateEvent_Descripcion web larga"
        (
            var Rec: Record "Item";
            var xRec: Record "Item";
            CurrFieldNo: Integer
        )
        var
            cuPS: Codeunit PSSincro;
        begin
            if (xRec."DescVar Web Larga" <> rec."DescVar Web Larga") then
                cuPS.insertarOperacionActualizacionDescripcionLarga(Rec."No.");
        end;

        [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterValidateEvent', 'Descripcion web corta', true, true)]
        local procedure "Item_OnAfterValidateEvent_Descripcion web corta"
        (
            var Rec: Record "Item";
            var xRec: Record "Item";
            CurrFieldNo: Integer
        )
        var
            cuPS: Codeunit PSSincro;
        begin
            if (xRec."DescVar Web Corta" <> rec."DescVar Web Corta") then
                cuPS.insertarOperacionActualizacionDescripcionLarga(Rec."No.");
        end;

        */

    //update descripciones largas y campos personalizados
    [EventSubscriber(ObjectType::Table, Database::"Descripciones Varias", 'OnAfterValidateEvent', 'Descripcion', true, true)]
    local procedure "Item_OnAfterValidateEvent_Descripcion web corta"
            (
                var Rec: Record "Descripciones Varias";
                var xRec: Record "Descripciones Varias";
                CurrFieldNo: Integer
            )
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
    begin
        if (xRec.Descripcion = rec.Descripcion) then
            exit;
        if Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::Temporal then
            exit;

        if not rItem.Get(Rec.Codigo) then
            exit;

        if rItem.IdPS = 0 then
            exit;

        if (Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::"Prod Desc Corta") or (Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::"Prod Desc Larga") then
            cuPS.insertarOperacionActualizacionDescripcionLarga(rItem."No.")
        else
            cuPS.insertarOperacionCamposPersonalizados(rItem."No.");

    end;


    [EventSubscriber(ObjectType::Table, Database::"Descripciones Varias", 'OnAfterInsertEvent', '', true, true)]
    local procedure "Descripciones Varias_OnAfterInsertEvent"
    (
        var Rec: Record "Descripciones Varias";
        RunTrigger: Boolean
    )
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
    begin
        if Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::Temporal then
            exit;

        if not rItem.Get(Rec.Codigo) then
            exit;

        if rItem.IdPS = 0 then
            exit;

        if (Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::"Prod Desc Corta") or (Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::"Prod Desc Larga") then
            cuPS.insertarOperacionActualizacionDescripcionLarga(rItem."No.")
        else
            cuPS.insertarOperacionCamposPersonalizados(rItem."No.");

    end;

    [EventSubscriber(ObjectType::Table, Database::"Descripciones Varias", 'OnAfterModifyEvent', '', true, true)]
    local procedure "Descripciones Varias_OnAfterModifyEvent"
    (
        var Rec: Record "Descripciones Varias";
        var xRec: Record "Descripciones Varias";
        RunTrigger: Boolean
    )
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
    begin
        //puede ser un blob
        //if Rec.Descripcion = xRec.Descripcion then
        //    exit;

        if Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::Temporal then
            exit;

        if not rItem.Get(Rec.Codigo) then
            exit;

        if rItem.IdPS = 0 then
            exit;

        if (Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::"Prod Desc Corta") or (Rec."Tipo Descripcion" = Rec."Tipo Descripcion"::"Prod Desc Larga") then
            cuPS.insertarOperacionActualizacionDescripcionLarga(rItem."No.")
        else
            cuPS.insertarOperacionCamposPersonalizados(rItem."No.");

    end;



    //update categorias nuevo
    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnAfterModifyEvent', '', true, true)]
    local procedure "Item Category_OnAfterModifyEvent"
    (
        var Rec: Record "Item Category";
        var xRec: Record "Item Category";
        RunTrigger: Boolean
    )
    var
        cups: Codeunit PSSincro;
    begin
        if (xRec.Description <> Rec.Description) or (xRec."Parent Category" <> rec."Parent Category") then
            cups.insertarOperacionActCategoriasTree(Rec.Code, 'update');
    end;


    [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterValidateEvent', 'Multiples unidades', true, true)]
    local procedure "Item_OnAfterValidateEvent_Multiples unidades"
    (
        var Rec: Record "Item";
        var xRec: Record "Item";
        CurrFieldNo: Integer
    )
    var
        cups: Codeunit PSSincro;
    begin
        if Rec."Multiples unidades" <> xRec."Multiples unidades" then
            cuPS.insertarOperacionMultiplesUnidades(Rec."No.", Rec."Multiples unidades");
    end;


    [EventSubscriber(ObjectType::Table, Database::"Producto Categoria Relation", 'OnAfterValidateEvent', 'Categoria Code', true, true)]
    local procedure "Producto Categoria Relation_OnAfterValidateEvent_Categoria Code"
    (
        var Rec: Record "Producto Categoria Relation";
        var xRec: Record "Producto Categoria Relation";
        CurrFieldNo: Integer
    )
    var
        cuPS: Codeunit PSSincro;
        rItem: Record Item;
    begin
        if rItem.Get(Rec."Item No.") and (rItem.IdPS > 0) then
            cuPS.insertarOperacionActualizacionCategoria(Rec."Item No.");
    end;



}