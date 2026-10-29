//7227678
codeunit 60101 PSSincro
{
    // version PSSINCRO


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'VER DIRECCION EN PRESTASHOP';
        Text002: Label 'Sincronizando stock producto ############1##';
        Text003: Label 'Sincronizando categorías producto ############1##';
        Text004: Label 'Sincronizando características producto ############1##';
        Text005: Label 'Sincronizando imágenes producto ############1##';
        Text006: Label 'Sincronizando descripciones producto ############1##';
        Text007: Label 'Sincronizando multimples unidades producto ############1##';
        Text008: Label 'Sincronizando campos personalizados producto ############1##';



    //REVISAR ESTA FUNCION SE HAN MODIFICADO BASTANTE CÓDIGO
    procedure sincronizaProductosPStoNav(xmlItemsProf: Text; var xmlTextoRetorno: text)
    var
        locautXmlDoc: XmlDocument;
        resultNode: XmlNode;
        listaNodos: XmlNodeList;
        nodeElemento: XmlNode;
        numeroElementos: Integer;
        i: Integer;
        idElementos: array[15000] of Integer;
        descElementos: array[15000] of Text[30];
        //combinaciones pinturasprincipado
        combinacionIdElemento: array[15000] of Integer;
        enteroId: Integer;
        nodoContenido: XmlNode;
        rItem: Record Item;
        rItemAux: Record Item;
        XMLDOMMgt: Codeunit "XML DOM Management";

        locautXmlDocOut: XmlDocument;
        xmlRootNode: XmlNode;
        rVariantesProduct: Record "Item Variant";
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
    begin
        //LOS PRODUCTOS SE RELACIONAN CON NAV POR EL CAMPO "COD. REFERENCIA OL" DE LA VARIANTE
        //SI TUVIERAN MÁS DE UNA VARIANTE SE RELACIONAN CON EL CAMPO DE LA PRIMERA VARIANTE QUE EXISTA
        //SINCRONIZA EL LISTADO DE IDPS Y IDNAV PARA LOS PRODUCTOS PASADOS EL EL XML

        XmlDocument.ReadFrom(xmlItemsProf, locautXmlDoc);
        //XMLDOMMgt.LoadXMLDocumentFromInStream(readStream,locautXmlDoc);
        //locautXmlDoc.load('C:\XMLpruebas.xml');
        //LEEMOS EL NODO QUE NOS INTERESE DE LA RESPUESTA

        //locautXmlDoc.SetProperty('SelectionLanguage', 'XPath');
        //locautXmlDoc.SelectSingleNode('//ArrayOfListaProductoIds', resultNode);
        //RECORREMOS TODOS LOS NODOS Y ALMACENAMOS EL VALOR DE ID EN UN ARRAY idElementos
        numeroElementos := 0;


        //MESSAGE(resultNode.text);  
        //listaNodos := resultNode.AsXmlElement().GetChildNodes();
        locautXmlDoc.SelectNodes('//ArrayOfListaProductoIds/ListaProductoIds', listaNodos);

        //listaNodos := resultNode.AsXmlDocument().GetChildNodes();
        i := 1;
        foreach nodeElemento in listaNodos do begin

            //end;


            //for i := 1 to listaNodos.Count do begin
            //listaNodos.Get(i, nodeElemento);
            nodeElemento.SelectSingleNode('idPs', nodoContenido);

            IF EVALUATE(enteroId, nodoContenido.AsXmlElement().InnerText) THEN BEGIN
                idElementos[i] := enteroId;
                nodeElemento.SelectSingleNode('referencia', nodoContenido);
                descElementos[i] := CopyStr(nodoContenido.AsXmlElement().InnerText, 1, MaxStrLen(descElementos[i]));
                nodeElemento.SelectSingleNode('combinacion', nodoContenido);
                //combinaciones pinturasprincipado
                if (nodoContenido.AsXmlElement().InnerText <> '') then
                    IF EVALUATE(enteroId, nodoContenido.AsXmlElement().InnerText) then
                        combinacionIdElemento[i] := enteroId
                    else
                        combinacionIdElemento[i] := 0
                else
                    combinacionIdElemento[i] := 0;

                numeroElementos += 1;
                i += 1;
            END;

        end;

        //respuesta y procesado
        xmlRootNode := XmlElement.Create('RESPUESTAS').AsXmlNode();
        FOR i := 1 TO numeroElementos DO BEGIN
            IF rItem.Get(CopyStr(descElementos[i], 1, MaxStrLen(rItem."No."))) THEN BEGIN
                IF rItem.IdPs = 0 THEN BEGIN
                    rItem.IdPs := idElementos[i];
                    rItem."Producto web" := TRUE;
                    //combinaciones pinturasprincipado
                    if combinacionIdElemento[i] > 0 then begin
                        rItem.Combinacion := true;
                        rItem."Id Combinacion" := combinacionIdElemento[i];
                    end;

                    rItem.MODIFY();

                    //INSERTAMOS ACTUALIZACIÓN DE STOCK Y DE TARIFA                    
                    insertarOperacionActStock(rItem."No.");
                    insertarOperacionActTarifaNAut(rItem.IdPs);
                    //insertarOperacionActFeatureCajas(rItem."No.");
                    //insertarOperacionActBUnitOfMeasure(rItem."No.");
                    //insertarOperacionActImagenesProducto(rItem."No.");
                END ELSE BEGIN
                    //1.0.0.31
                    //Si es una combinación resincronizamos el id de nuevo ya que es posible que se modifique su id cada vez que se hace un cambio en ps
                    if combinacionIdElemento[i] > 0 then begin
                        if rItem."Id Combinacion" <> combinacionIdElemento[i] then begin
                            //ACTUALIZAMOS OPERACIONES ASÍNCRONAS PENDIENTES SI LAS HUBIESE
                            rOperacionesAsincronas.Reset();
                            rOperacionesAsincronas.SetRange(IdDestino, Format(rItem."Id Combinacion"));
                            rOperacionesAsincronas.SetRange(Tipo, rOperacionesAsincronas.Tipo::Stock);
                            rOperacionesAsincronas.SetRange(Procesado, false);
                            if rOperacionesAsincronas.FindSet() then begin
                                rOperacionesAsincronas.ModifyAll(IdDestino, Format(combinacionIdElemento[i]));
                            end;

                            rItem.IdPs := idElementos[i];
                            rItem."Producto web" := TRUE;
                            //combinaciones pinturasprincipado
                            rItem.Combinacion := true;
                            rItem."Id Combinacion" := combinacionIdElemento[i];
                            rItem.MODIFY();
                        end;
                    end else begin
                        //puede que haya sido combinación y ahora ya no lo sea
                        rItemAux.Reset();
                        rItemAux.SetRange(IdPS, idElementos[i]);
                        if rItemAux.FindSet() then begin
                            rItemAux.ModifyAll(Combinacion, false);
                            rItemAux.ModifyAll("Id Combinacion", 0);
                        end;
                        //puede también que se haya modificado el idproducto
                        if rItem.IdPS <> idElementos[i] then begin
                            rItem.IdPS := idElementos[i];
                            rItem.Modify();
                        end;
                    end;
                END;
            END ELSE BEGIN
                //ESCRIBIMOS UN REGISTRO EN EL XML DE RESPUESTA
                //LLM CORRECCION
                //xmlTextoRetorno.ADDTEXT(generaRegistroXMLPr(descElementos[i],'1'));
                generaRegistroXMLPrV2(xmlRootNode, descElementos[i], FORMAT(idElementos[i]));
                //xmlTextoRetorno.ADDTEXT(generaRegistroXMLPrrItem."No.",'1'));
            END;
        END;

        locautXmlDocOut := XmlDocument.Create();
        locautXmlDocOut.Add(xmlRootNode);
        locautXmlDocOut.WriteTo(xmlTextoRetorno);
    end;

    //NUEVA FUNCIONALIDAD DE CHEQUEO DE REFERENCIAS PS
    /*
    se almacene en campo blob el listado de referencias existentes en PS, en posteriores ejecuciones se comprueba si el listado de PS 
    coincide con los productos sincronizados en BC, si existen diferencias se sincronizan los datos de los productos en BC, desmarcando la sincronización con PS
    El proceso se lanza según un booleano en la tabla "Sales & receivables setup", este booleano se marca en el report de sincronización de imágenes FTP
    */

    procedure setReferenciasPS(xmlItemsProf: Text)
    var
        locautXmlDoc: XmlDocument;
        resultNode: XmlNode;
        listaNodos: XmlNodeList;
        nodeElemento: XmlNode;
        numeroElementos: Integer;
        i: Integer;
        descElementos: array[15000] of Text[30];
        nodoContenido: XmlNode;
        xmlRootNode: XmlNode;
        listado: Text;
        rSalesSetup: Record "Sales & Receivables Setup";
        ostr: OutStream;
        instr: InStream;
        emptyTempBlob: Codeunit "Temp Blob";
        rRef: RecordRef;
        fRef: FieldRef;
    begin
        //LOS PRODUCTOS SE RELACIONAN CON NAV POR EL CAMPO "COD. REFERENCIA OL" DE LA VARIANTE
        //SI TUVIERAN MÁS DE UNA VARIANTE SE RELACIONAN CON EL CAMPO DE LA PRIMERA VARIANTE QUE EXISTA
        //SINCRONIZA EL LISTADO DE IDPS Y IDNAV PARA LOS PRODUCTOS PASADOS EL EL XML

        XmlDocument.ReadFrom(xmlItemsProf, locautXmlDoc);

        //RECORREMOS TODOS LOS NODOS Y ALMACENAMOS EL VALOR DE ID EN UN ARRAY idElementos
        numeroElementos := 0;

        locautXmlDoc.SelectNodes('//ArrayOfListaProductoIds/ListaProductoIds', listaNodos);

        //listaNodos := resultNode.AsXmlDocument().GetChildNodes();
        i := 1;
        foreach nodeElemento in listaNodos do begin
            //for i := 1 to listaNodos.Count do begin
            //listaNodos.Get(i, nodeElemento);
            nodeElemento.SelectSingleNode('referencia', nodoContenido);
            descElementos[i] := nodoContenido.AsXmlElement().InnerText;
            numeroElementos += 1;
            i += 1;
        end;

        //respuesta y procesado
        rSalesSetup.Get();
        rSalesSetup.CalcFields("Listado referencias PS");
        if rSalesSetup."Listado referencias PS".HasValue then begin
            rSalesSetup."Listado referencias PS".CreateInStream(instr, TextEncoding::UTF8);
            instr.ReadText(listado);
        end;
        xmlRootNode := XmlElement.Create('RESPUESTAS').AsXmlNode();
        FOR i := 1 TO numeroElementos DO BEGIN
            listado += descElementos[i] + '|';
        END;

        rSalesSetup.Get();
        rRef.GetTable(rSalesSetup);
        fRef := rRef.Field(rSalesSetup.FieldNo("Listado referencias PS"));
        emptyTempBlob.ToFieldRef(fRef);
        rRef.SetTable(rSalesSetup);
        rSalesSetup."Listado referencias PS".CreateOutStream(ostr, TextEncoding::UTF8);
        ostr.WriteText(listado);
        rSalesSetup.Modify();
    end;

    procedure deleteReferenciasPs()
    var
        emptyTempBlob: Codeunit "Temp Blob";
        rRef: RecordRef;
        fRef: FieldRef;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        if rSalesSetup."Listado referencias PS".HasValue then begin
            rRef.GetTable(rSalesSetup);
            fRef := rRef.Field(rSalesSetup.FieldNo("Listado referencias PS"));
            emptyTempBlob.ToFieldRef(fRef);
            rRef.SetTable(rSalesSetup);
            rSalesSetup.Modify();
        end;
    end;

    procedure checkReferenciasPs(var xmlTextoRetorno: text): Text
    var
        rSalesSetup: Record "Sales & Receivables Setup";
        listado: Text;
        instr: InStream;
        elementos: list of [Text];
        elemento: Text;
        elementoCode: code[20];
        rItem: Record Item;
        comprobado: Boolean;
        xmlRootNode: XmlNode;
        locautXmlDocOut: XmlDocument;
    begin
        rSalesSetup.Get();
        rSalesSetup.CalcFields("Listado referencias PS");
        if rSalesSetup."Listado referencias PS".HasValue then begin
            rSalesSetup."Listado referencias PS".CreateInStream(instr, TextEncoding::UTF8);
            instr.ReadText(listado);
        end;
        elementos := listado.Split('|');
        xmlRootNode := XmlElement.Create('RESPUESTAS').AsXmlNode();
        rItem.Reset();
        rItem.SetFilter(IdPS, '>0');
        IF rItem.FindSet() THEN
            repeat
                comprobado := false;
                foreach elemento in elementos do begin
                    //pueden existir vacíos
                    if elemento <> '' then begin
                        elementoCode := CopyStr(elemento, 1, MaxStrLen(elementoCode));
                        if rItem."No." = elementoCode then begin
                            comprobado := true;
                        end;
                    end;
                end;

                if not comprobado then begin
                    rItem.IdPS := 0;
                    rItem."Producto web" := false;
                    rItem."Id Combinacion" := 0;
                    rItem.Combinacion := false;
                    rItem.Modify();
                    generaRegistroXMLPrV2(xmlRootNode, rItem."No.", '2');
                end;
            UNTIL rItem.Next() = 0;
        locautXmlDocOut := XmlDocument.Create();
        locautXmlDocOut.Add(xmlRootNode);
        locautXmlDocOut.WriteTo(xmlTextoRetorno);

        exit(listado);
    end;

    procedure getCheckReferenciasPS(): Boolean
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        exit(rSalesSetup."Check referencias PS");
    end;

    procedure updateCheckReferenciasPS()
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        rSalesSetup."Check referencias PS" := false;
        rSalesSetup.Modify();
    end;

    //NUEVA FUNCIONALIDAD DE CHEQUEO DE REFERENCIAS PS - FIN

    procedure uptadeIdPsProducto(ProductoNo: Code[20]; idPs: Integer)
    var
        rItem: Record Item;
        rAsync: Record "Modificaciones Asincronas PS";
    begin
        IF rItem.GET(ProductoNo) THEN BEGIN
            rItem.IdPs := idPs;
            rItem.MODIFY();

            //1.0.0.18
            //actualizamos las operaciones asíncronas que se pudieran haber insertado antes de la sincronización del producto
            rAsync.Reset();
            rAsync.SetRange(IdDestino, ProductoNo);
            if rAsync.FindSet() then
                rAsync.ModifyAll(IdOrigen, Format(idPs));

        END;
    end;

    //REVISAR ESTA FUNCION
    local procedure generaRegistroXMLPrV2(var xmlNodeOut: XmlNode; codProducto: Text[30]; motivo: Text[30])
    var
        xmlNodeTmp: XmlNode;
        XMLDOMMgt: Codeunit "XML DOM Management";
    begin
        xmlNodeTmp := XmlElement.create('RESPUESTA', '').AsXmlNode();
        xmlNodeTmp.AsXmlElement().Add(XmlElement.create('A', '', codProducto).AsXmlNode());
        xmlNodeTmp.AsXmlElement().Add(XmlElement.create('B', '', motivo).AsXmlNode());
        xmlNodeOut.AsXmlElement().Add(xmlNodeTmp);
    end;

    procedure sincronizaEstadoPedido(idPs: Code[10]; descripcion: Text[50]; moduloPago: Text[30])
    var
        rEstadosPedido: Record "Relacion de estados pedido PS";
    begin
        IF rEstadosPedido.GET(idPs) THEN BEGIN
            rEstadosPedido.nombreEstadoPS := descripcion;
            rEstadosPedido.moduloPagoPS := moduloPago;
            IF moduloPago <> '' THEN
                rEstadosPedido.estadoDeEntrada := TRUE;
            rEstadosPedido.MODIFY();
        END ELSE BEGIN
            rEstadosPedido.idEstadoPS := idPs;
            rEstadosPedido.nombreEstadoPS := descripcion;
            rEstadosPedido.moduloPagoPS := moduloPago;
            IF moduloPago <> '' THEN
                rEstadosPedido.estadoDeEntrada := TRUE;
            rEstadosPedido.INSERT();
        END;
    end;

    procedure insertClientePS(idClientePs: Integer; nombre: Text[50]; direccion1: Text[50]; direccion2: Text[50]; ciudad: Text[30]; codigoPostal: Text[10]; email: Text[80]; telefono: Text[20]; telefonoMovil: Text[20]; nif: Text[20]; codigoPais: Text[10]; idDireccionPrincipal: Integer; empresa_cif: Text[20]; empresa: Text[50]; empresa_cnae: Text[20]; empresa_web: Text[50]; provincia: Text[30]; id_zona: Text[30]): Code[20]
    var
        rCustomer: Record Customer;
        rSalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        //LLM MODIFICADO ABRIL 2015 PARA EVITAR CLIENTES DUPLICADOS Y AÑADIR INFORMACIÓN DE EMPRESA
        //FINALMENTE EL CIF SE INFORMA SIEMPRE EN EL MISMO CAMPO DNI/NIF/NIE/CIF LA DIFERENCIA ENTRE EMPRESA Y CLIENTE
        //NOS LA VA A DAR EL CAMPO EMPRESA

        rSalesSetup.GET();

        rCustomer.RESET();
        rCustomer.SETRANGE(rCustomer.IdClientePS, idClientePs);
        IF NOT rCustomer.FINDFIRST() THEN BEGIN
            //COMPROBAMOS QUE TENGA EL NIF INFORMADO, EN CASO CONTRARIO NO INSERTAMOS EL CLIENTE
            ///////////////////////////////1.0.0.18
            //MODIFICACIÓN SI EL NIF NO EXISTE DAMOS DE ALTA EL CLIENTE, PERO EN EL CAMPO CLIENTE DE FACTURACIÓN PONEMOS AL CLIENTE ESTÁNDAR
            ///////////////////////////////1.0.0.18
            /*IF (nif <> '') THEN BEGIN*/


            //LLM EL CIF SIEMPRE VA EN EL CAMPO CIF EL CAMPO EMPRESA_CIF NO SE USA OCTUBRE 2015
            //IF (empresa <> '') AND (empresa_cif <> '') THEN BEGIN
            //IF (empresa <> '') THEN BEGIN

            //COMPROBAMOS POR CIF SI EL CLIENTE YA EXISTE
            if (nif = '') then
                nif := 'SINNIF';

            rCustomer.RESET();
            rCustomer.SETRANGE(rCustomer."VAT Registration No.", nif);
            IF NOT rCustomer.FINDFIRST() THEN BEGIN
                rCustomer.INIT();
                IF rSalesSetup."Numeracion Clientes PS" <> '' THEN
                    rCustomer."No." := NoSeriesMgt.GetNextNo(rSalesSetup."Numeracion Clientes PS", 0D, TRUE);
                rCustomer.IdClientePS := idClientePs;
                rCustomer.EsClientePS := TRUE;
                rCustomer.INSERT(FALSE);

                if empresa <> '' then
                    rCustomer.VALIDATE(rCustomer.Name, empresa)
                else
                    rCustomer.VALIDATE(rCustomer.Name, nombre);
                rCustomer.Address := direccion1;
                rCustomer."Address 2" := direccion2;
                rCustomer.City := ciudad;
                //v1.0.0.19
                //prevalece información de teléfono móvil
                rCustomer."Phone No." := telefono;
                if telefonoMovil <> '' then
                    rCustomer."Mobile Phone No." := telefonoMovil;
                IF nif <> 'SINNIF' then
                    rCustomer."VAT Registration No." := nif;
                rCustomer."Post Code" := codigoPostal;
                rCustomer.VALIDATE(County, provincia);
                rCustomer."E-Mail" := email;
                rCustomer.IdDireccionPrincipalPs := idDireccionPrincipal;
                rCustomer.fechaAltaClientePs := CURRENTDATETIME();
                rCustomer.VALIDATE(rCustomer."Salesperson Code", rSalesSetup."Cod. Vendedor PS");

                //GRUPOS CONTABLES SEGÚN ZONA
                rCustomer.VALIDATE(rCustomer."Customer Posting Group", getGrupoContableClientexZona(id_zona));
                rCustomer.VALIDATE(rCustomer."Gen. Bus. Posting Group", getGrupoContableNegocioxZona(id_zona));
                rCustomer.VALIDATE(rCustomer."VAT Bus. Posting Group", getGrupoContableIVAxZona(id_zona));
                //FIN

                //FORMA DE PAGO DEFECTO
                rCustomer.VALIDATE(rCustomer."Payment Terms Code", rSalesSetup."Term. pago cliente PS");
                rCustomer.VALIDATE(rCustomer."Payment Method Code", rSalesSetup."Forma pago cliente PS");
                rCustomer.VALIDATE("Country/Region Code", codigoPais);
                rCustomer."Home Page" := empresa_web;
                //NOMBRE DEL CLIENTE COMO CONTACTO
                rCustomer.Contact := nombre;

                //SI EL NIF NO ESTÁ INFORMADO PONEMOS COMO CLIENTE DE FACTURACIÓN EL CLIENTE ESTÁNDAR
                if nif = 'SINNIF' then
                    rCustomer.Validate("Bill-to Customer No.", rSalesSetup."Cliente tarifa web");

                rCustomer.Modify(FALSE);
            END ELSE BEGIN
                //COMPROBAMOS QUE EL NIF NO SEA VACÍO ya lo comprobamos al principio
                //IF empresa_cif <> '' THEN BEGIN
                //RELACIONAMOS EL IDCLIENTEPS
                rCustomer.EsClientePS := TRUE;
                rCustomer.IdClientePS := idClientePs;
                IF rCustomer.Contact = '' THEN
                    rCustomer.Contact := nombre;

                //LLM ACTUALIZAMOS LA DIRECCIÓN POR SI LA HA MODIFICADO SEPTIEMBRE 2019
                //ERROR AL DAR DE ALTA EL PEDIDO //VER DIRECCIÓN EN PRESTASHOP
                rCustomer.Address := direccion1;
                rCustomer."Address 2" := direccion2;
                rCustomer.City := ciudad;
                //v1.0.0.19
                //prevalece información de teléfono móvil
                rCustomer."Phone No." := telefono;
                if telefonoMovil <> '' then
                    rCustomer."Mobile Phone No." := telefonoMovil;
                rCustomer."Post Code" := codigoPostal;
                rCustomer.VALIDATE(County, provincia);
                rCustomer."E-Mail" := email;
                rCustomer.IdDireccionPrincipalPs := idDireccionPrincipal;
                //LLM ACTUALIZAMOS LA DIRECCIÓN POR SI LA HA MODIFICADO SEPTIEMBRE 2019 FIN

                rCustomer.MODIFY();
                //END;
            END;
            /*
            END ELSE BEGIN
                rCustomer.RESET();
                rCustomer.SETRANGE(rCustomer."VAT Registration No.", nif);
                IF NOT rCustomer.FINDFIRST() THEN BEGIN
                    rCustomer.INIT();
                    IF rSalesSetup."Numeracion Clientes PS" <> '' THEN
                        rCustomer."No." := NoSeriesMgt.GetNextNo(rSalesSetup."Numeracion Clientes PS", 0D, TRUE);
                    rCustomer.IdClientePS := idClientePs;
                    rCustomer.EsClientePS := TRUE;
                    rCustomer.Insert(false);
                    rCustomer.VALIDATE(rCustomer.Name, nombre);
                    rCustomer.Address := direccion1;
                    rCustomer."Address 2" := direccion2;
                    rCustomer.City := ciudad;
                    rCustomer."Phone No." := telefonoMovil;
                    rCustomer."VAT Registration No." := nif;
                    rCustomer."Post Code" := codigoPostal;
                    rCustomer.VALIDATE(County, provincia);
                    rCustomer."E-Mail" := email;
                    rCustomer.IdDireccionPrincipalPs := idDireccionPrincipal;
                    rCustomer.fechaAltaClientePs := CURRENTDATETIME();
                    rCustomer.VALIDATE(rCustomer."Salesperson Code", rSalesSetup."Cod. Vendedor PS");

                    //GRUPOS CONTABLES SEGÚN ZONA
                    rCustomer.VALIDATE(rCustomer."Customer Posting Group", getGrupoContableClientexZona(id_zona));
                    rCustomer.VALIDATE(rCustomer."Gen. Bus. Posting Group", getGrupoContableNegocioxZona(id_zona));
                    rCustomer.VALIDATE(rCustomer."VAT Bus. Posting Group", getGrupoContableIVAxZona(id_zona));
                    //FIN

                    //FORMA DE PAGO DEFECTO
                    rCustomer.VALIDATE(rCustomer."Payment Terms Code", rSalesSetup."Term. pago cliente PS");
                    rCustomer.VALIDATE(rCustomer."Payment Method Code", rSalesSetup."Forma pago cliente PS");
                    rCustomer.VALIDATE("Country/Region Code", codigoPais);

                    rCustomer.Modify(FALSE);
                END ELSE BEGIN
                    //RELACIONAMOS EL IDCLIENTEPS
                    rCustomer.EsClientePS := TRUE;
                    rCustomer.IdClientePS := idClientePs;

                    //LLM ACTUALIZAMOS LA DIRECCIÓN POR SI LA HA MODIFICADO SEPTIEMBRE 2019
                    //ERROR AL DAR DE ALTA EL PEDIDO //VER DIRECCIÓN EN PRESTASHOP
                    rCustomer.Address := direccion1;
                    rCustomer."Address 2" := direccion2;
                    rCustomer.City := ciudad;
                    rCustomer."Phone No." := telefonoMovil;
                    rCustomer."Post Code" := codigoPostal;
                    rCustomer.VALIDATE(County, provincia);
                    rCustomer."E-Mail" := email;
                    rCustomer.IdDireccionPrincipalPs := idDireccionPrincipal;
                    //LLM ACTUALIZAMOS LA DIRECCIÓN POR SI LA HA MODIFICADO SEPTIEMBRE 2019 FIN

                    rCustomer.MODIFY();
                END;

            END;
            */
            //RETORNAMOS EL CÓDIGO DEL NUEVO CLIENTE INSERTADO
            EXIT(rCustomer."No.");

            /*END ELSE
                //RETORNAMOS EL COD. CLIENTE ESTANDAR
                EXIT(rSalesSetup."Cliente tarifa Web");
            */

        END ELSE BEGIN
            //EL CLIENTE YA EXISTE
            //IF empresa <> '' THEN BEGIN
            if empresa <> '' then
                rCustomer.VALIDATE(rCustomer.Name, empresa)
            else
                rCustomer.Validate(rCustomer.Name, nombre);
            rCustomer.Address := direccion1;
            rCustomer."Address 2" := direccion2;
            rCustomer.City := ciudad;
            //v1.0.0.19
            //prevalece información de teléfono móvil
            rCustomer."Phone No." := telefono;
            if telefonoMovil <> '' then
                rCustomer."Mobile Phone No." := telefonoMovil;
            rCustomer."Post Code" := codigoPostal;
            rCustomer.VALIDATE(County, provincia);
            rCustomer."E-Mail" := email;
            rCustomer.IdDireccionPrincipalPs := idDireccionPrincipal;
            //rCustomer.fechaAltaClientePs := CURRENTDATETIME();
            rCustomer.VALIDATE(rCustomer."Salesperson Code", rSalesSetup."Cod. Vendedor PS");

            //GRUPOS CONTABLES SEGÚN ZONA
            rCustomer.VALIDATE(rCustomer."Customer Posting Group", getGrupoContableClientexZona(id_zona));
            rCustomer.VALIDATE(rCustomer."Gen. Bus. Posting Group", getGrupoContableNegocioxZona(id_zona));
            rCustomer.VALIDATE(rCustomer."VAT Bus. Posting Group", getGrupoContableIVAxZona(id_zona));
            //FIN

            //FORMA DE PAGO DEFECTO
            rCustomer.VALIDATE(rCustomer."Payment Terms Code", rSalesSetup."Term. pago cliente PS");
            rCustomer.VALIDATE(rCustomer."Payment Method Code", rSalesSetup."Forma pago cliente PS");
            rCustomer.VALIDATE("Country/Region Code", codigoPais);
            rCustomer.MODIFY();
            /*
            END ELSE BEGIN
                rCustomer.VALIDATE(rCustomer.Name, nombre);
                rCustomer.Address := direccion1;
                rCustomer."Address 2" := direccion2;
                rCustomer.City := ciudad;
                rCustomer."Phone No." := telefonoMovil;
                rCustomer."Post Code" := codigoPostal;
                rCustomer.VALIDATE(County, provincia);
                rCustomer."E-Mail" := email;
                rCustomer.IdDireccionPrincipalPs := idDireccionPrincipal;
                //rCustomer.fechaAltaClientePs := CURRENTDATETIME();
                rCustomer.VALIDATE(rCustomer."Salesperson Code", rSalesSetup."Cod. Vendedor PS");

                //GRUPOS CONTABLES SEGÚN ZONA
                rCustomer.VALIDATE(rCustomer."Customer Posting Group", getGrupoContableClientexZona(id_zona));
                rCustomer.VALIDATE(rCustomer."Gen. Bus. Posting Group", getGrupoContableNegocioxZona(id_zona));
                rCustomer.VALIDATE(rCustomer."VAT Bus. Posting Group", getGrupoContableIVAxZona(id_zona));
                //FIN

                //FORMA DE PAGO DEFECTO
                rCustomer.VALIDATE(rCustomer."Payment Terms Code", rSalesSetup."Term. pago cliente PS");
                rCustomer.VALIDATE(rCustomer."Payment Method Code", rSalesSetup."Forma pago cliente PS");
                rCustomer.VALIDATE("Country/Region Code", codigoPais);
                rCustomer.MODIFY();
            END;
            */
            //RETORNAMOS EL CÓDIGO DEL NUEVO CLIENTE MODIFICADO
            EXIT(rCustomer."No.");
        END;
    end;

    procedure getUltimoIdClienteSincronizado(): Integer
    var
        rCustomer: Record Customer;
    begin
        rCustomer.RESET();
        rCustomer.SETCURRENTKEY(IdClientePS);
        //rCustomer.SETRANGE(rCustomer.EsClientePS,TRUE);
        rCustomer.SETFILTER(rCustomer.IdClientePS, '>0');
        IF rCustomer.FINDLAST() THEN
            EXIT(rCustomer.IdClientePS)
        ELSE
            EXIT(0);
    end;

    /*
    procedure comprobacionListadoClientesPS(xmlItemsProf: Text;var xmlTextoRetorno: BigText)
    var
        numeroElementos: Integer;
        i: Integer;
        idElementos: array [15000] of Integer;
        descElementos: array [15000] of Code[20];
        enteroId: Integer;
        rCustomer: Record Customer;
        nodoContenido: DotNet XmlNode;
        "//": Integer;
        locautXmlDoc: DotNet XmlDocument;
        resultNode: DotNet XmlNode;
        listaNodos: DotNet XmlNodeList;
        nodeElemento: DotNet XmlNode;
        XMLDOMMgt: Codeunit "XML DOM Management";
        enum: DotNet Dictionary_Of_T_U_Enumerator;
        locautXmlDocOut: DotNet XmlDocument;
        xmlRootNode: DotNet XmlNode;
    begin
        //COMPRUEBA EL LISTADO DE TODOS LOS CLIENTES DE PS, SI ALGUNO DE ELLOS NO EXISTE EN NAV, LO DEVUELVE
        //PARA SU RESINCRONIZACION
        XMLDOMMgt.LoadXMLDocumentFromText(xmlItemsProf,locautXmlDoc);
        //locautXmlDoc.load('C:\XMLpruebas.xml');
        //LEEMOS EL NODO QUE NOS INTERESE DE LA RESPUESTA

        //locautXmlDoc.SetProperty('SelectionLanguage', 'XPath');
        resultNode := locautXmlDoc.SelectSingleNode('//ArrayOfListaClientes');
        //RECORREMOS TODOS LOS NODOS Y ALMACENAMOS EL VALOR DE ID EN UN ARRAY idElementos
        numeroElementos := 0;
        //MESSAGE(resultNode.text);
        listaNodos := resultNode.ChildNodes;
        enum := listaNodos.GetEnumerator();
        i:= 1;
        WHILE enum.MoveNext DO BEGIN
          nodeElemento := enum.Current;
          nodoContenido := nodeElemento.SelectSingleNode('idPs');
          IF EVALUATE(enteroId,nodoContenido.InnerText) THEN BEGIN
            idElementos[i] := enteroId;
            numeroElementos += 1;
            i+=1;
          END;
        END;

        locautXmlDocOut := locautXmlDocOut.XmlDocument;
        XMLDOMMgt.AddRootElement(locautXmlDocOut,'RESPUESTAS',xmlRootNode);
        FOR i:= 1 TO numeroElementos DO BEGIN
          rCustomer.RESET();
          rCustomer.SETRANGE(rCustomer.IdClientePS,idElementos[i]);
          IF NOT rCustomer.FINDFIRST() THEN BEGIN
            generaRegistroXMLPrV2(xmlRootNode,FORMAT(idElementos[i]),'1');
          END;
        END;
        xmlTextoRetorno.ADDTEXT(locautXmlDocOut.InnerXml);
    end;
    */

    procedure insertDireccionClientePS(idClientePs: Integer; direccion1: Text[50]; direccion2: Text[50]; ciudad: Text[30]; codigoPostal: Text[10]; telefono: Text[20]; telefonoMovil: Text[20]; codigoPais: Text[10]; idDireccion: Integer; provincia: Text[30]; id_zona: Text[30]; nombre: Text[50])
    var
        rDireccionEnvio: Record "Ship-to Address";
        rCustomer: Record Customer;
    begin
        rCustomer.RESET();
        rCustomer.SETRANGE(rCustomer.IdClientePS, idClientePs);
        IF rCustomer.FINDFIRST() THEN BEGIN
            rDireccionEnvio.RESET();
            rDireccionEnvio.SETRANGE(rDireccionEnvio."Customer No.", rCustomer."No.");
            rDireccionEnvio.SETRANGE(rDireccionEnvio.IdDireccionPS, idDireccion);
            IF rDireccionEnvio.FINDFIRST() THEN BEGIN
                rDireccionEnvio.Address := direccion1;
                rDireccionEnvio."Address 2" := direccion2;
                rDireccionEnvio.City := ciudad;
                rDireccionEnvio."Phone No." := telefonoMovil;
                rDireccionEnvio.Name := nombre;
                rDireccionEnvio."Post Code" := codigoPostal;
                rDireccionEnvio.County := provincia;
                rDireccionEnvio."Last Date Modified" := TODAY();
                //llm febrero 2016
                rDireccionEnvio.id_zona := id_zona;

                rCustomer.VALIDATE("Country/Region Code", codigoPais);
                rDireccionEnvio.MODIFY();
            END ELSE BEGIN
                rDireccionEnvio.INIT();
                rDireccionEnvio.VALIDATE(rDireccionEnvio."Customer No.", rCustomer."No.");
                rDireccionEnvio.Code := FORMAT(idDireccion);
                rDireccionEnvio.IdDireccionPS := idDireccion;
                rDireccionEnvio.Address := direccion1;
                rDireccionEnvio."Address 2" := direccion2;
                rDireccionEnvio.City := ciudad;
                rDireccionEnvio."Phone No." := telefonoMovil;
                rDireccionEnvio.Name := nombre;
                rDireccionEnvio."Post Code" := codigoPostal;
                rDireccionEnvio.County := provincia;
                rDireccionEnvio."Last Date Modified" := TODAY();
                //llm febrero 2016
                rDireccionEnvio.id_zona := id_zona;

                rCustomer.VALIDATE("Country/Region Code", codigoPais);
                rDireccionEnvio.INSERT();
            END;
        END;
    end;

    procedure getPrecioVentaProducto(idProductoPS: Integer): Decimal
    var
        rSalesPrice: Record "Sales Price";
        rCustomer: Record Customer;
        rSalesSetup: Record "Sales & Receivables Setup";
        rItem: Record Item;
    begin
        rSalesSetup.GET();
        rItem.RESET();
        rItem.SETRANGE(rItem.IdPs, idProductoPS);
        IF rItem.FINDFIRST() THEN BEGIN
            IF rSalesSetup."Cliente tarifa Web" <> '' THEN BEGIN
                //obtenemos el cliente
                rCustomer.Get(rSalesSetup."Cliente tarifa web");

                rSalesPrice.RESET();
                rSalesPrice.SETRANGE(rSalesPrice."Item No.", rItem."No.");
                rSalesPrice.SETRANGE(rSalesPrice."Sales Type", rSalesPrice."Sales Type"::Customer);
                rSalesPrice.SETRANGE(rSalesPrice."Sales Code", rCustomer."No.");
                rSalesPrice.SETFILTER(rSalesPrice."Starting Date", '<=%1', TODAY);
                rSalesPrice.SETFILTER(rSalesPrice."Ending Date", '>=%1|%2', TODAY, 0D);
                //PERSO PEPEBAR
                rSalesPrice.SetRange("Minimum Quantity", 0, 1);
                IF rSalesPrice.FINDFIRST() THEN
                    EXIT(rSalesPrice."Unit Price")
                ELSE BEGIN
                    //BUSCAMOS EL GRUPO PRECIOS CLIENTE DEL CLIENTE SI EXISTE TARIFA
                    rSalesPrice.SETRANGE(rSalesPrice."Sales Type", rSalesPrice."Sales Type"::"Customer Price Group");
                    rSalesPrice.SETRANGE(rSalesPrice."Sales Code", rCustomer."Customer Price Group");
                    IF rSalesPrice.FINDFIRST() THEN
                        EXIT(rSalesPrice."Unit Price")
                    ELSE
                        EXIT(rItem."Unit Price");
                END;
            END ELSE
                EXIT(rItem."Unit Price");
        END ELSE
            EXIT(0);
    end;

    procedure actualizarTarifasEnCicloActual(): Boolean
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.GET();
        IF rSalesSetup.SincronizacionTarifa THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    procedure updateFechaSincroTarifas()
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.GET();
        rSalesSetup.UltimaSincroTarifa := CURRENTDATETIME();
        rSalesSetup.SincronizacionTarifa := FALSE;
        rSalesSetup.MODIFY();
    end;

    procedure actualizarProductEnCicloActual(): Boolean
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.GET();
        IF rSalesSetup.SincronizacionProductos THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    procedure updateFechaSincroProductos()
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.GET();
        rSalesSetup.UltimaSincroProductos := CURRENTDATETIME();
        rSalesSetup.SincronizacionProductos := FALSE;
        rSalesSetup.MODIFY();
    end;

    procedure getUltimoIdPedidoSincronizado(): Integer
    var
        rPedido: Record "Sales Header";
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.GET();

        rPedido.RESET();
        rPedido.SETCURRENTKEY(rPedido.IdPedidoPS);
        rPedido.SETRANGE(rPedido.EsPedidoPS, TRUE);
        IF rPedido.FINDLAST() THEN BEGIN
            IF rSalesSetup."Id pedido PS ultimo" > rPedido.IdPedidoPS THEN
                EXIT(rSalesSetup."Id pedido PS ultimo")
            ELSE
                EXIT(rPedido.IdPedidoPS);
        END ELSE
            EXIT(rSalesSetup."Id pedido PS ultimo");

        //PRUEBAS
        //EXIT(100);
    end;

    procedure insertCabeceraPedidoPS(IdPedido: Integer; IdCliente: Integer; IdDireccionFactura: Integer; IdDireccionEnvio: Integer; Payment: Text[30]; TotalPedidoSiva: Decimal; TotalPedidoCiva: Decimal; TotalEnvioSiva: Decimal; EstadoPedidoPS: Code[10]; referenciaPedidoPS: Text[30]; fechaEnvio: Date; fechaPedido: Date): Code[20]
    var
        rPedido: Record "Sales Header";
        rCustomer: Record Customer;
        rDireccionEnvio: Record "Ship-to Address";
        rSalesSetup: Record "Sales & Receivables Setup";
        rEstadosPedidoPS: Record "Relacion de estados pedido PS";
        factura: Boolean;
        NoSeriesMgt: Codeunit "No. Series";
        rSalesLine: Record "Sales Line";
    begin
        rSalesSetup.GET();

        //COMPROBACION ESTADO PEDIDO SI EL ESTADO TIENE MARCADO "ERROR PAGO" DEVOLVEMOS -1 Y NO SE DA DE ALTA EL PEDIDO
        IF rEstadosPedidoPS.GET(EstadoPedidoPS) THEN BEGIN
            IF rEstadosPedidoPS."Error Pago" THEN
                EXIT('-1'); //error en pago
        END;
        //COMPROBACION ESTADO PEDIDO FIN

        rCustomer.RESET();
        rCustomer.SETRANGE(rCustomer.IdClientePS, IdCliente);
        IF rCustomer.FINDFIRST() THEN
            factura := TRUE;

        rPedido.RESET();
        rPedido.SETRANGE(rPedido."Document Type", rPedido."Document Type"::Order);
        rPedido.SETRANGE(rPedido.IdPedidoPS, IdPedido);
        IF NOT rPedido.FINDFIRST() THEN BEGIN
            rPedido.INIT();

            //PERSO
            IF factura THEN BEGIN
                IF rSalesSetup."Serie Pedidos c.factura" <> '' THEN
                    rPedido."No." := NoSeriesMgt.GetNextNo(rSalesSetup."Serie Pedidos c.factura", 0D, TRUE);
            END ELSE BEGIN
                IF rSalesSetup."Serie Pedidos s.factura" <> '' THEN
                    rPedido."No." := NoSeriesMgt.GetNextNo(rSalesSetup."Serie Pedidos s.factura", 0D, TRUE);
            END;

            rPedido."Document Type" := rPedido."Document Type"::Order;
            rPedido.IdPedidoPS := IdPedido;
            rPedido."Ref. pedido PS" := referenciaPedidoPS;
            //N DOC. EXTERNO
            rPedido."External Document No." := FORMAT(IdPedido);
            rPedido.INSERT(TRUE);

            rCustomer.RESET();
            rCustomer.SETRANGE(rCustomer.IdClientePS, IdCliente);
            IF rCustomer.FINDFIRST() THEN BEGIN
                rPedido.VALIDATE(rPedido."Sell-to Customer No.", rCustomer."No.");
                //COMPROBAMOS LAS DIRECCIONES
                //v1.0.0.19
                IF ((IdDireccionFactura <> rCustomer.IdDireccionPrincipalPs) and (rCustomer."Bill-to Customer No." = rCustomer."No.")) THEN BEGIN
                    rDireccionEnvio.Reset();
                    rDireccionEnvio.SetRange(IdDireccionPS, IdDireccionFactura);
                    IF rDireccionEnvio.FindSet() THEN BEGIN
                        rPedido."Bill-to Name" := rDireccionEnvio.Name;
                        rPedido."Bill-to Name 2" := rDireccionEnvio."Name 2";
                        rPedido."Bill-to Address" := rDireccionEnvio.Address;
                        rPedido."Bill-to Address 2" := rDireccionEnvio."Address 2";
                        rPedido."Bill-to City" := rDireccionEnvio.City;
                        rPedido."Bill-to Post Code" := rDireccionEnvio."Post Code";
                        rPedido."Bill-to Country/Region Code" := rDireccionEnvio."Country/Region Code";

                        //modificamos los grupos contables según la zona de la dirección
                        rPedido.VALIDATE(rPedido."Customer Posting Group", getGrupoContableClientexZona(rDireccionEnvio.id_zona));
                        rPedido.VALIDATE(rPedido."Gen. Bus. Posting Group", getGrupoContableNegocioxZona(rDireccionEnvio.id_zona));
                        rPedido.VALIDATE(rPedido."VAT Bus. Posting Group", getGrupoContableIVAxZona(rDireccionEnvio.id_zona));
                    END ELSE BEGIN
                        rPedido."Bill-to Name" := Text001;
                        rPedido."Bill-to Address" := Text001;
                    END;
                END;

                IF (IdDireccionEnvio <> rCustomer.IdDireccionPrincipalPs) THEN BEGIN
                    rDireccionEnvio.Reset();
                    rDireccionEnvio.SetRange(IdDireccionPS, IdDireccionEnvio);
                    IF rDireccionEnvio.FindSet() THEN BEGIN
                        rPedido.VALIDATE(rPedido."Ship-to Code", rDireccionEnvio.Code);
                    END ELSE BEGIN
                        rPedido."Ship-to Name" := Text001;
                        rPedido."Ship-to Address" := Text001;
                    END;
                END;

                rPedido.VALIDATE(rPedido."Posting Date", TODAY);
                rPedido."Shipment Date" := fechaEnvio;
                rPedido."Order Date" := fechaPedido;
                //FIN DIRECCIONES

                rPedido.EsPedidoPS := TRUE;
                rPedido.TotalEnvioPSiva := TotalEnvioSiva;
                rPedido.TotalPCiva := TotalPedidoCiva;
                rPedido.TotalPSiva := TotalPedidoSiva;
                //rPedido.VALIDATE("Estado Pedido PS", FORMAT(EstadoPedidoPS));
                //si hace el validate insertará una op. asíncrona y duplicará el estado en PS
                rPedido."Estado Pedido PS" := Format(EstadoPedidoPS);

                //rPedido.VALIDATE(rPedido."Order Date",TODAY);
                rPedido."Salesperson Code" := rSalesSetup."Cod. Vendedor PS";

                IF rEstadosPedidoPS.GET(EstadoPedidoPS) THEN BEGIN
                    IF rEstadosPedidoPS.formaPagoNAV <> '' THEN
                        rPedido.VALIDATE("Payment Method Code", rEstadosPedidoPS.formaPagoNAV);

                    //redsys y paypal tienen el mismo estado de pago aceptado
                    /*
                    IF (STRPOS(Payment, 'Redsys') > 0) THEN
                      rPedido.VALIDATE("Payment Method Code",rSalesSetup."Forma pago REDSYS");
                    IF (STRPOS(Payment, 'PayPal') > 0) THEN
                      rPedido.VALIDATE("Payment Method Code",rSalesSetup."Forma pago PAYPAL");
                    */
                END;

                IF rSalesSetup."Almacén pedidos PS" <> '' THEN
                    rPedido."Location Code" := rSalesSetup."Almacén pedidos PS";

                rPedido."Your Reference" := referenciaPedidoPS;
                rPedido."Importe Pago al pedido" := TotalPedidoCiva;


                //INSERTAMOS EL PEDIDO
                rPedido.MODIFY();

                //ALMACENAMOS EL ID PEDIDO PS
                rSalesSetup."Id pedido PS ultimo" := IdPedido;
                rSalesSetup.MODIFY();

                //PAYPAL
                IF (rEstadosPedidoPS.PAYPAL) then begin
                    rSalesLine.INIT();
                    rSalesLine."Document Type" := rSalesLine."Document Type"::Order;
                    rSalesLine."Document No." := rPedido."No.";
                    rSalesLine."Line No." := getNextOrderLineNo(rPedido."No.");
                    rSalesLine.Type := rSalesLine.Type::Item;
                    rSalesLine.Validate("No.", rSalesSetup."Producto recargo PAYPAL");
                    rSalesLine.Validate(Quantity, 1);
                end;
                //FIN PAYPAL

                //RETORNAMOS EL NUMERO DE PEDIDO
                EXIT(rPedido."No.");
            END ELSE BEGIN
                //cliente genérico
                rPedido.VALIDATE(rPedido."Sell-to Customer No.", rSalesSetup."Cliente tarifa Web");
                //INSERTAMOS LAS DIRECCIONES EN OTRA FUNCIÓN POSTERIOR

                rPedido.EsPedidoPS := TRUE;
                rPedido.TotalEnvioPSiva := TotalEnvioSiva;
                rPedido.TotalPCiva := TotalPedidoCiva;
                rPedido.TotalPSiva := TotalPedidoSiva;
                //rPedido.VALIDATE("Estado Pedido PS", FORMAT(EstadoPedidoPS));
                //si hace el validate insertará una op. asíncrona y duplicará el estado en PS
                rPedido."Estado Pedido PS" := Format(EstadoPedidoPS);

                //rPedido.VALIDATE(rPedido."Order Date",TODAY);
                rPedido."Salesperson Code" := rSalesSetup."Cod. Vendedor PS";

                IF rEstadosPedidoPS.GET(EstadoPedidoPS) THEN BEGIN
                    IF rEstadosPedidoPS.formaPagoNAV <> '' THEN
                        rPedido.VALIDATE("Payment Method Code", rEstadosPedidoPS.formaPagoNAV);
                END;

                IF rSalesSetup."Almacén pedidos PS" <> '' THEN
                    rPedido."Location Code" := rSalesSetup."Almacén pedidos PS";

                rPedido."Your Reference" := referenciaPedidoPS;
                rPedido."Importe Pago al pedido" := TotalPedidoCiva;

                //INSERTAMOS EL PEDIDO
                rPedido.MODIFY();

                //ALMACENAMOS EL ID PEDIDO PS
                rSalesSetup."Id pedido PS ultimo" := IdPedido;
                rSalesSetup.MODIFY();

                //PAYPAL
                IF (rEstadosPedidoPS.PAYPAL) then begin
                    rSalesLine.INIT();
                    rSalesLine."Document Type" := rSalesLine."Document Type"::Order;
                    rSalesLine."Document No." := rPedido."No.";
                    rSalesLine."Line No." := getNextOrderLineNo(rPedido."No.");
                    rSalesLine.Type := rSalesLine.Type::Item;
                    rSalesLine.Validate("No.", rSalesSetup."Producto recargo PAYPAL");
                    rSalesLine.Validate(Quantity, 1);
                end;
                //FIN PAYPAL

                //RETORNAMOS EL NUMERO DE PEDIDO
                EXIT(rPedido."No.");

            END;
        END ELSE BEGIN
            //SI EL PEDIDO YA EXISTE Y ESTÁ EN ESTADO ABIERTO ACTUALIZAMOS TODOS LOS DATOS
            /*
            IF rPedido.Status = rPedido.Status::Open THEN BEGIN
                rCustomer.RESET();
                rCustomer.SETRANGE(rCustomer.IdClientePS, IdCliente);
                IF rCustomer.FINDFIRST() THEN BEGIN
                    rPedido.VALIDATE(rPedido."Sell-to Customer No.", rCustomer."No.");
                    //COMPROBAMOS LAS DIRECCIONES
                    IF (IdDireccionFactura <> rCustomer.IdDireccionPrincipalPs) THEN BEGIN
                        rDireccionEnvio.Reset();
                        rDireccionEnvio.SetRange(IdDireccionPS, IdDireccionFactura);
                        IF rDireccionEnvio.FindSet() THEN BEGIN
                            rPedido."Bill-to Name" := rDireccionEnvio.Name;
                            rPedido."Bill-to Name 2" := rDireccionEnvio."Name 2";
                            rPedido."Bill-to Address" := rDireccionEnvio.Address;
                            rPedido."Bill-to Address 2" := rDireccionEnvio."Address 2";
                            rPedido."Bill-to City" := rDireccionEnvio.City;
                            rPedido."Bill-to Post Code" := rDireccionEnvio."Post Code";
                            rPedido."Bill-to Country/Region Code" := rDireccionEnvio."Country/Region Code";
                        END ELSE BEGIN
                            rPedido."Bill-to Name" := Text001;
                            rPedido."Bill-to Address" := Text001;
                        END;
                    END;

                    IF (IdDireccionEnvio <> rCustomer.IdDireccionPrincipalPs) THEN BEGIN
                        rDireccionEnvio.Reset();
                        rDireccionEnvio.SetRange(IdDireccionPS, IdDireccionEnvio);
                        IF rDireccionEnvio.FindSet() THEN BEGIN
                            rPedido.VALIDATE(rPedido."Ship-to Code", rDireccionEnvio.Code);
                        END ELSE BEGIN
                            rPedido."Ship-to Name" := Text001;
                            rPedido."Ship-to Address" := Text001;
                        END;
                    END;
                    //FIN DIRECCIONES

                    rPedido.EsPedidoPS := TRUE;
                    rPedido.TotalEnvioPSiva := TotalEnvioSiva;
                    rPedido.TotalPCiva := TotalPedidoCiva;
                    rPedido.TotalPSiva := TotalPedidoSiva;
                    //rPedido.VALIDATE("Estado Pedido PS", FORMAT(EstadoPedidoPS));
                    //si hace el validate insertará una op. asíncrona y duplicará el estado en PS
                    rPedido."Estado Pedido PS" := Format(EstadoPedidoPS);

                    //rPedido.VALIDATE(rPedido."Order Date",TODAY);
                    rPedido."Salesperson Code" := rSalesSetup."Cod. Vendedor PS";

                    IF rEstadosPedidoPS.GET(EstadoPedidoPS) THEN BEGIN
                        IF rEstadosPedidoPS.formaPagoNAV <> '' THEN
                            rPedido.VALIDATE("Payment Method Code", rEstadosPedidoPS.formaPagoNAV);
                    END;

                    //INSERTAMOS EL PEDIDO
                    rPedido.MODIFY();

                    //ALMACENAMOS EL ID PEDIDO PS
                    rSalesSetup."Id pedido PS ultimo" := IdPedido;
                    rSalesSetup.MODIFY();

                    //RETORNAMOS EL NUMERO DE PEDIDO
                    EXIT(rPedido."No.");
                END ELSE BEGIN
                    //CLIENTE GENÉRICO
                    rPedido.VALIDATE(rPedido."Sell-to Customer No.", rSalesSetup."Cliente tarifa Web");
                    //COMPROBAMOS LAS DIRECCIONES
                    //las direcciones las actualizamos en funcion posteriormente

                    rPedido.EsPedidoPS := TRUE;
                    rPedido.TotalEnvioPSiva := TotalEnvioSiva;
                    rPedido.TotalPCiva := TotalPedidoCiva;
                    rPedido.TotalPSiva := TotalPedidoSiva;
                    //rPedido.VALIDATE("Estado Pedido PS", FORMAT(EstadoPedidoPS));
                    //si hace el validate insertará una op. asíncrona y duplicará el estado en PS
                    rPedido."Estado Pedido PS" := Format(EstadoPedidoPS);

                    //rPedido.VALIDATE(rPedido."Order Date",TODAY);
                    rPedido."Salesperson Code" := rSalesSetup."Cod. Vendedor PS";

                    IF rEstadosPedidoPS.GET(EstadoPedidoPS) THEN BEGIN
                        IF rEstadosPedidoPS.formaPagoNAV <> '' THEN
                            rPedido.VALIDATE("Payment Method Code", rEstadosPedidoPS.formaPagoNAV);
                    END;

                    //INSERTAMOS EL PEDIDO
                    rPedido.MODIFY();

                    //ALMACENAMOS EL ID PEDIDO PS
                    rSalesSetup."Id pedido PS ultimo" := IdPedido;
                    rSalesSetup.MODIFY();

                END;
            END ELSE
            */
            EXIT('-1');//EL PEDIDO ESTÁ LANZADO
        END;
    end;

    procedure InsertPedidoDireccionesPS(idClientePs: Integer; nombre: Text[50]; empresa: Text[50]; direccion1: Text[50]; direccion2: Text[50]; ciudad: Text[30]; codigoPostal: Text[10]; telefono: Text[20]; telefonoMovil: Text[20]; codigoPais: Text[10]; idDireccion: Integer; provincia: Text[30]; id_zona: Text[30]; cif: Text[30]; tipo: Option facturacion,envio; codPedidoNAV: Code[20])
    var
        rDireccionEnvio: Record "Ship-to Address";
        rSalesSetup: Record "Sales & Receivables Setup";
        rCustomer: Record Customer;
        rSalesHeader: Record "Sales Header";
    begin
        rSalesHeader.GET(rSalesHeader."Document Type"::Order, codPedidoNAV);
        CASE tipo OF
            tipo::facturacion:
                BEGIN
                    /*PERSO, NO HACEMOS NADA, DEJAMOS LOS DATOS DEL CLIENTE ECOMMERCE
                    rSalesHeader."Bill-to Name" := nombre;
                    IF empresa <> '' THEN
                      rSalesHeader."Bill-to Name" := empresa;
                    rSalesHeader."Bill-to Address" := direccion1;
                    rSalesHeader."Bill-to Address 2" := direccion2;
                    rSalesHeader."Bill-to City" := ciudad;
                    rSalesHeader."Bill-to Post Code" := codigoPostal;
                    rSalesHeader."Bill-to Country/Region Code" := codigoPais;
                    rSalesHeader."Bill-to County" := provincia;

                    rSalesHeader."Sell-to Customer Name" := nombre;
                    IF empresa <> '' THEN
                      rSalesHeader."Sell-to Customer Name" := empresa;
                    rSalesHeader."Sell-to Address" := direccion1;
                    rSalesHeader."Sell-to Address 2" := direccion2;
                    rSalesHeader."Sell-to City" := ciudad;
                    rSalesHeader."Sell-to Post Code" := codigoPostal;
                    rSalesHeader."Sell-to Country/Region Code" := codigoPais;
                    rSalesHeader."Sell-to County" := provincia;

                    //actualizamos los grupos de registro
                    rSalesHeader."Customer Posting Group" :=  getGrupoContableClientexZona(id_zona);
                    rSalesHeader."VAT Bus. Posting Group" := getGrupoContableNegocioxZona(id_zona);
                    rSalesHeader."VAT Registration No." := cif;
                    rSalesHeader."Sell-to Contact" := nombre;
                    rSalesHeader.MODIFY();
                    */
                END;
            tipo::envio:
                BEGIN
                    rSalesHeader."Ship-to Name" := nombre;
                    rSalesHeader."Ship-to Address" := direccion1;
                    rSalesHeader."Ship-to Address 2" := direccion2;
                    rSalesHeader."Ship-to City" := ciudad;
                    rSalesHeader."Ship-to Post Code" := codigoPostal;
                    rSalesHeader."Ship-to Country/Region Code" := codigoPais;
                    rSalesHeader."Ship-to County" := provincia;

                    rSalesHeader.MODIFY();
                END;
        END;

    end;

    procedure insertLineaPedidoPS(codPedido: Code[20]; idProductoPs: Integer; codProducto: Code[20]; descripcion: Text[100]; cantidad: Decimal; descuento: Decimal; precioUnitario: Decimal; precioSiva: Decimal; precioCiva: Decimal; importeLineaSIva: Decimal; importeLineaCIva: Decimal)
    var
        rSalesHeader: Record "Sales Header";
        rSalesSetup: Record "Sales & Receivables Setup";
        rSalesLine: Record "Sales Line";
        rItem: Record Item;
        importeIva: Decimal;
        porcentajeIva: Decimal;
        importeCiva: Decimal;
        importeSiva: Decimal;
        vatSetup: Record "VAT Posting Setup";
        rItemVariant: Record "Item Variant";
        rItemUoMeasure: Record "Item Unit of Measure";
    begin
        rSalesSetup.GET();

        rSalesHeader.GET(rSalesHeader."Document Type"::Order, codPedido);
        rSalesLine.INIT();
        rSalesLine."Document Type" := rSalesLine."Document Type"::Order;
        rSalesLine."Document No." := codPedido;
        rSalesLine."Line No." := getNextOrderLineNo(codPedido);

        //PUEDE QUE LA REFERENCIA VENGA VACÍA EN LA LÍNEA DEL PEDIDO, BUSCAMOS SI ES VACÍA POR EL ID DE PS
        if codProducto = '' then begin
            ritem.reset();
            ritem.setrange(IdPS, idProductoPs);
            if ritem.findset() then begin
                //lo hacemos antes para que inserte la unidad de medida en la línea de forma automática
                //da error si el producto ya tiene movimientos                
                if (rItem."Base Unit of Measure" <> rSalesSetup."Ud Medida productos") and (rSalesSetup."Ud Medida productos" <> '') and (not productoTieneMovs(rItem)) then begin
                    rItem.Validate("Base Unit of Measure", rSalesSetup."Ud Medida productos");
                    rItem.Modify();
                    //rSalesLine."Unit of Measure Code" := rSalesSetup."Ud Medida productos";
                end;
                rSalesLine.Type := rSalesLine.Type::Item;
                rSalesLine.VALIDATE("No.", rItem."No.");
                //LLM CORRECCIÓN FEBRERO 2021 COMPROBAMOS QUE EL PRODUCTO TENGA LA UNIDAD DE MEDIDA CONFIGURADA
                //eN CASO CONTRARIO DA ERROR Y NO PASA EL PEDIDO
                if rItemUoMeasure.Get(rItem."No.", rSalesSetup."Ud Medida productos") then
                    rSalesLine.Validate("Unit of Measure Code", rSalesSetup."Ud Medida productos");
                //ALMACÉN
                rSalesLine.VALIDATE(rSalesLine."Location Code", rSalesSetup."Almacén pedidos PS");

            end else begin
                rSalesLine.Type := rSalesLine.Type::"G/L Account";
                rSalesLine.VALIDATE(rSalesLine."No.", rSalesSetup."Cuenta ventas PS");
            end;
        end else begin
            IF (rItem.GET(codProducto)) THEN BEGIN
                //lo hacemos antes para que inserte la unidad de medida en la línea de forma automática
                //da error si el producto ya tiene movimientos
                if (rItem."Base Unit of Measure" <> rSalesSetup."Ud Medida productos") and (rSalesSetup."Ud Medida productos" <> '') and (not productoTieneMovs(rItem)) then begin
                    rItem.Validate("Base Unit of Measure", rSalesSetup."Ud Medida productos");
                    rItem.Modify();
                    //rSalesLine."Unit of Measure Code" := rSalesSetup."Ud Medida productos";
                end;
                rSalesLine.Type := rSalesLine.Type::Item;
                rSalesLine.VALIDATE("No.", rItem."No.");
                //eN CASO CONTRARIO DA ERROR Y NO PASA EL PEDIDO
                if rItemUoMeasure.Get(rItem."No.", rSalesSetup."Ud Medida productos") then
                    rSalesLine.Validate("Unit of Measure Code", rSalesSetup."Ud Medida productos");
                //ALMACÉN
                rSalesLine.VALIDATE(rSalesLine."Location Code", rSalesSetup."Almacén pedidos PS");
            END ELSE BEGIN
                rSalesLine.Type := rSalesLine.Type::"G/L Account";
                rSalesLine.VALIDATE(rSalesLine."No.", rSalesSetup."Cuenta ventas PS");
            END;
        end;
        rSalesLine.Description := descripcion;
        rSalesLine.VALIDATE(Quantity, cantidad);
        rSalesLine.VALIDATE(rSalesLine."Unit Price", precioUnitario);
        rSalesLine.Validate("Line Discount %", 100);
        //dependiendo de la configuración de almacén es posible que se tenga que informar manualmente la cantidad a enviar y facturar
        rSalesLine.VALIDATE(rSalesLine."Qty. to Ship", cantidad);
        rSalesLine.VALIDATE(rSalesLine."Qty. to Invoice", cantidad);

        //rSalesLine.VALIDATE("Line Discount %", descuento);
        //al poner el importe total de la línea sin IVA se calcula automáticamente el % descuento de la línea
        //lineas con precio 0 da error
        if (precioUnitario <> 0) then
            rSalesLine.VALIDATE("Line Amount", importeLineaSIva);

        rSalesLine.INSERT(TRUE);

    end;

    local procedure productoTieneMovs(var ritem: Record Item): Boolean
    var
        rMovsProducto: Record "Item Ledger Entry";
    begin
        rMovsProducto.reset();
        rMovsProducto.setrange("Item No.", ritem."No.");
        exit(rMovsProducto.FindSet());
    end;

    procedure insertLineaPedidoPSEnvio(codPedido: Code[20]; idProductoPs: Integer; descripcion: Text[50]; precioUnitario: Decimal; precioSiva: Decimal; precioCiva: Decimal)
    var
        rSalesHeader: Record "Sales Header";
        rSalesSetup: Record "Sales & Receivables Setup";
        rSalesLine: Record "Sales Line";
        rItem: Record Item;
        importeIva: Decimal;
        porcentajeIva: Decimal;
        importeCiva: Decimal;
        importeSiva: Decimal;
        vatSetup: Record "VAT Posting Setup";
    begin
        rSalesSetup.GET();

        rSalesHeader.GET(rSalesHeader."Document Type"::Order, codPedido);
        rSalesLine.INIT();
        rSalesLine."Document Type" := rSalesHeader."Document Type"::Order;
        rSalesLine."Document No." := codPedido;
        rSalesLine."Line No." := getNextOrderLineNo(codPedido);

        IF rSalesSetup."Tipo cuenta envios" = rSalesSetup."Tipo cuenta envios"::Cuenta THEN BEGIN
            rSalesLine.Type := rSalesLine.Type::"G/L Account";
        END ELSE BEGIN
            rSalesLine.Type := rSalesLine.Type::Item;
        END;
        rSalesLine.VALIDATE(rSalesLine."No.", rSalesSetup."Cuenta ventas Envios");
        rSalesLine.Description := descripcion;
        rSalesLine.VALIDATE(rSalesLine.Quantity, 1);
        rSalesLine.VALIDATE(rSalesLine."Unit Price", precioUnitario);

        //dependiendo de la configuración de almacén es posible que se tenga que informar manualmente la cantidad a enviar y facturar
        rSalesLine.VALIDATE(rSalesLine."Qty. to Ship", 1);
        rSalesLine.VALIDATE(rSalesLine."Qty. to Invoice", 1);


        importeSiva := precioSiva;
        importeCiva := precioCiva;

        importeIva := importeCiva - importeSiva;
        IF (importeIva > 0) AND (importeCiva > 0) THEN
            porcentajeIva := importeSiva * 100 / importeCiva;

        rSalesLine.INSERT(TRUE);
    end;

    procedure insertLineaPedidoPSDescuentos(codPedido: Code[20]; precioUnitario: Decimal; precioSiva: Decimal; precioCiva: Decimal; totalPedidoSiva: Decimal)
    var
        rSalesHeader: Record "Sales Header";
        rSalesSetup: Record "Sales & Receivables Setup";
        rSalesLine: Record "Sales Line";
        rItem: Record Item;
        importeIva: Decimal;
        porcentajeIva: Decimal;
        importeCiva: Decimal;
        importeSiva: Decimal;
        vatSetup: Record "VAT Posting Setup";
        rSalesLineAux: Record "Sales Line";
        importeLineasSiva: Decimal;
        porcentajeDescuento: Decimal;
        biCupon: Decimal;
        cupon: Decimal;
        rvatSetup: Record "VAT Posting Setup";
        importeLinCIva: Decimal;
        importePedCIva: Decimal;
        GLSetup: Record "General Ledger Setup";
    begin
        //PERSONALIZACIÓN PEPEBAR, NO SE APLICA DESCUENTO A RECARGO NI GASTOS DE ENVÍO
        rSalesSetup.GET();
        GLSetup.Get();

        //ACTUALIZAMOS INFORMACIÓN DE LA CABECERA DE PEDIDO
        IF rSalesHeader.GET(rSalesHeader."Document Type"::Order, codPedido) THEN BEGIN
            rSalesHeader.TotalPSiva := totalPedidoSiva;
            rSalesHeader.TotalDescuentos := precioCiva;
            rSalesHeader.MODIFY();
        END;

        IF precioUnitario <> 0 THEN BEGIN
            rSalesHeader.GET(rSalesHeader."Document Type"::Order, codPedido);
            rSalesLine.INIT();
            rSalesLine."Document Type" := rSalesHeader."Document Type"::Order;
            rSalesLine."Document No." := codPedido;
            rSalesLine."Line No." := getNextOrderLineNo(codPedido);
            rSalesLine.Type := rSalesLine.Type::" ";

            //PERSONALIZACIÓN MATARROMERA, LIENAS DE PRODUCTO CON DIFERENTES IVA
            rSalesLineAux.RESET();
            rSalesLineAux.SETRANGE(rSalesLineAux."Document Type", rSalesLineAux."Document Type"::Order);
            rSalesLineAux.SETRANGE(rSalesLineAux."Document No.", codPedido);
            IF rSalesLineAux.FINDSET() THEN
                REPEAT
                    if (rSalesLineAux."No." <> rSalesSetup."Cuenta ventas envios") and (rSalesLineAux."No." <> rSalesSetup."Producto recargo PAYPAL") then begin
                        vatSetup.GET(rSalesLineAux."VAT Bus. Posting Group", rSalesLineAux."VAT Prod. Posting Group");
                        importeLinCIva := rSalesLineAux."Line Amount" * (1 + vatSetup."VAT %" / 100);
                        importePedCIva += importeLinCIva;

                        importeLineasSiva += rSalesLineAux."Line Amount";
                    end;
                UNTIL rSalesLineAux.NEXT = 0;

            //calculamos el porcentaje de descuento sobre el total
            //aplicamos a cada línea el descuento a mayores del que tenga ya aplicado
            IF rSalesLineAux.FINDSET() THEN
                REPEAT
                    if (rSalesLineAux."No." <> rSalesSetup."Cuenta ventas envios") and (rSalesLineAux."No." <> rSalesSetup."Producto recargo PAYPAL") then begin
                        //division por cero en lineas con importe 0
                        if rSalesLineAux."Line Amount" > 0 then begin
                            importeLinCIva := rSalesLineAux."Line Amount" * (1 + vatSetup."VAT %" / 100);
                            cupon := (ABS(precioCiva) / importePedCIva) * importeLinCIva;
                            biCupon := (cupon / (1 + vatSetup."VAT %" / 100));
                            //porcentajeDescuento := biCupon / rSalesLineAux."Line Amount" * 100;
                            //rSalesLineAux.VALIDATE("Line Discount %", rSalesLineAux."Line Discount %" + porcentajeDescuento);
                            //si la linea tiene ya descuento no sale bien el importe actuamos sobre el line amount
                            rSalesLineAux.Validate("Line Amount", rSalesLineAux."Line Amount" - biCupon);
                            rSalesLineAux.MODIFY();
                        end;
                    end;
                UNTIL rSalesLineAux.NEXT = 0;

            //AHORA INSERTAMOS UNA LÍNEA DE COMENTARIO INDICANDO QUE SE HA APLICADO UN DESCUENTO DE CUPÓN POR IMPORTE DE X EUROS
            rSalesLine.Description := STRSUBSTNO(rSalesSetup."Texto linea descuento", FORMAT(ABS(precioCiva)));
            rSalesLine.INSERT(TRUE);

            //ACTUALIZAMOS INFORMACIÓN DE LA CABECERA DE PEDIDO
            IF rSalesHeader.GET(rSalesHeader."Document Type"::Order, codPedido) THEN BEGIN
                rSalesHeader.TotalPSiva := totalPedidoSiva;
                rSalesHeader.TotalDescuentos += precioUnitario;
                rSalesHeader.MODIFY();
            END;
        END;

    end;

    procedure getNextOrderLineNo(codPedido: Code[20]): Integer
    var
        rSalesLine: Record "Sales Line";
    begin
        rSalesLine.RESET();
        rSalesLine.SETRANGE(rSalesLine."Document Type", rSalesLine."Document Type"::Order);
        rSalesLine.SETRANGE(rSalesLine."Document No.", codPedido);
        IF rSalesLine.FINDLAST() THEN
            EXIT(rSalesLine."Line No." + 10000)
        ELSE
            EXIT(10000);
    end;

    procedure procesarOperacionAsincrona(idOperacion: Integer)
    var
        rAsync: Record "Modificaciones Asincronas PS";
    begin
        IF rAsync.GET(idOperacion) THEN BEGIN
            rAsync.Procesado := TRUE;
            rAsync."Fecha/Hora proceso" := CurrentDateTime;
            rAsync.MODIFY();
        END;
    end;

    /*
    procedure comprobacionListadoPedidosPS(xmlItemsProf: Text;var xmlTextoRetorno: BigText)
    var
        numeroElementos: Integer;
        i: Integer;
        idElementos: array [15000] of Integer;
        descElementos: array [15000] of Code[20];
        enteroId: Integer;
        rPedido: Record "Sales Header";
        nodoContenido: DotNet XmlNode;
        rSalesSetup: Record "Sales & Receivables Setup";
        rAsin: Record Table50014;
        locautXmlDoc: DotNet XmlDocument;
        resultNode: DotNet XmlNode;
        listaNodos: DotNet XmlNodeList;
        nodeElemento: DotNet XmlNode;
        XMLDOMMgt: Codeunit "XML DOM Management";
        enum: DotNet Dictionary_Of_T_U_Enumerator;
        locautXmlDocOut: DotNet XmlDocument;
        xmlRootNode: DotNet XmlNode;
    begin
        //COMPRUEBA EL LISTADO DE TODOS LOS CLIENTES DE PS, SI ALGUNO DE ELLOS NO EXISTE EN NAV, LO DEVUELVE
        //PARA SU RESINCRONIZACION
        
        //LLM AGOSTO 10.08.2015
        //CORRECCIÓN PARA PEDIDOS BORRADOS YA SINCRONIZADOS
        rSalesSetup.GET();
        
        XMLDOMMgt.LoadXMLDocumentFromText(xmlItemsProf,locautXmlDoc);
        //locautXmlDoc.load('C:\XMLpruebas.xml');
        //LEEMOS EL NODO QUE NOS INTERESE DE LA RESPUESTA
        
        //locautXmlDoc.SetProperty('SelectionLanguage', 'XPath');
        resultNode := locautXmlDoc.SelectSingleNode('//ArrayOfListaPedidos');
        //RECORREMOS TODOS LOS NODOS Y ALMACENAMOS EL VALOR DE ID EN UN ARRAY idElementos
        numeroElementos := 0;
        i:=1;
        //MESSAGE(resultNode.text);
        listaNodos := resultNode.ChildNodes;
        enum := listaNodos.GetEnumerator();
        WHILE enum.MoveNext DO BEGIN
          nodeElemento := enum.Current;
          nodoContenido := nodeElemento.SelectSingleNode('idPs');
          IF EVALUATE(enteroId,nodoContenido.InnerText) THEN BEGIN
            idElementos[i] := enteroId;
            numeroElementos += 1;
            i+=1;
          END;
        END;
        
        locautXmlDocOut := locautXmlDocOut.XmlDocument;
        XMLDOMMgt.AddRootElement(locautXmlDocOut,'RESPUESTAS',xmlRootNode);
        FOR i:= 1 TO numeroElementos DO BEGIN
          IF rSalesSetup."Id pedido PS ultimo" < idElementos[i] THEN BEGIN
            rPedido.RESET();
            rPedido.SETRANGE(rPedido."Document Type",rPedido."Document Type"::Order);
            rPedido.SETRANGE(rPedido.IdPedidoPS,idElementos[i]);
            IF NOT rPedido.FINDFIRST() THEN BEGIN
              //xmlTextoRetorno.ADDTEXT(generaRegistroXMLPr(FORMAT(idElementos[i]),'1'));
              generaRegistroXMLPrV2(xmlRootNode,FORMAT(idElementos[i]),'1');
            END;
          END;
        END;
        
        /*
        locautXmlDocOut := locautXmlDocOut.XmlDocument;
        XMLDOMMgt.AddRootElement(locautXmlDocOut,'RESPUESTAS',xmlRootNode);
        FOR i:= 1 TO numeroElementos DO BEGIN
          rAsin.RESET();
          rAsin.SETRANGE(rAsin.IdOrigen,FORMAT(idElementos[i]));
          rAsin.SETRANGE(rAsin.Tipo,rAsin.Tipo::"5");
          rAsin.SETRANGE(rAsin.Procesado,FALSE);
        
          IF rSalesSetup."Id pedido PS ultimo" < idElementos[i] THEN BEGIN
            rPedido.RESET();
            rPedido.SETRANGE(rPedido."Document Type",rPedido."Document Type"::Order);
            rPedido.SETRANGE(IdPedidoPS,idElementos[i]);
            IF NOT rPedido.FINDFIRST() THEN BEGIN
              generaRegistroXMLPrV2(xmlRootNode,FORMAT(idElementos[i]),'1');
            END;
          END ELSE BEGIN
            IF rAsin.FINDFIRST() THEN BEGIN
              generaRegistroXMLPrV2(xmlRootNode,FORMAT(idElementos[i]),'1');
              rAsin.Procesado := TRUE;
              rAsin.MODIFY();
            END;
          END;
        END;
        
        xmlTextoRetorno.ADDTEXT(locautXmlDocOut.InnerXml);

    end;
    */

    /* procedure insertarOperacionActStock(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                rOperacionesAsincronas.INIT();
                rOperacionesAsincronas.idAsync := 0;
                rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPs);
                rOperacionesAsincronas.IdDestino := rItem."No.";
                rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::Stock;
                rOperacionesAsincronas.Cantidad := calcularInventarioProducto(codProducto);
                rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                rOperacionesAsincronas.INSERT(TRUE);
            END;
        END;
    end; */

    procedure insertarOperacionActGrupoCliente(codCliente: Code[20]; codGrupoPrecioCliente: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rCustomerPrGr: Record "Customer Discount Group";
        rCustomer: Record Customer;
    begin
        rCustomer.Get(codCliente);
        IF rCustomerPrGr.GET(codGrupoPrecioCliente) THEN BEGIN
            IF (rCustomerPrGr."Id Group PS" > 0) and (rCustomer.IdClientePS > 0) THEN BEGIN
                //buscamos si ya existe operación pendiente
                rOperacionesAsincronas.reset();
                rOperacionesAsincronas.setrange(Tipo, rOperacionesAsincronas.Tipo::"Grupo Cliente");
                rOperacionesAsincronas.setrange(IdOrigen, codCliente);
                rOperacionesAsincronas.SetRange(IdDestino, format(rCustomerPrGr."Id Group PS"));
                rOperacionesAsincronas.SetRange(Procesado, false);
                if not rOperacionesAsincronas.FindSet() then begin
                    rOperacionesAsincronas.INIT();
                    rOperacionesAsincronas.idAsync := 0;
                    rOperacionesAsincronas.IdOrigen := Format(rCustomer.IdClientePS);
                    rOperacionesAsincronas.IdDestino := Format(rCustomerPrGr."Id Group PS");
                    rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::"Grupo Cliente";
                    rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                    rOperacionesAsincronas.INSERT(TRUE);
                end;
            END;
        END;
    end;

    procedure insertarOperacionActImagenesProducto(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                rOperacionesAsincronas.INIT();
                rOperacionesAsincronas.idAsync := 0;
                rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPs);
                rOperacionesAsincronas.IdDestino := rItem."No.";
                rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::"Imagenes producto";
                rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                rOperacionesAsincronas.INSERT(TRUE);
            END;
        END;
    end;

    procedure insertarOperacionBajaProducto(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                rOperacionesAsincronas.INIT();
                rOperacionesAsincronas.idAsync := 0;
                rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPs);
                rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::"Baja Producto";
                rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                rOperacionesAsincronas.INSERT(TRUE);
            END;
        END;
    end;

    procedure insertarOperacionActualizacionAtributos(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                //buscamos si ya existe operación pendiente
                rOperacionesAsincronas.reset();
                rOperacionesAsincronas.setrange(Tipo, rOperacionesAsincronas.Tipo::Atributos);
                rOperacionesAsincronas.setrange(IdOrigen, format(rItem.IdPS));
                rOperacionesAsincronas.SetRange(Procesado, false);
                if not rOperacionesAsincronas.FindSet() then begin
                    rOperacionesAsincronas.INIT();
                    rOperacionesAsincronas.idAsync := 0;
                    rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPs);
                    rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::Atributos;
                    rOperacionesAsincronas.IdDestino := rItem."No.";
                    rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                    rOperacionesAsincronas.INSERT(TRUE);
                end;
            END;
        END;
    end;



    procedure insertarOperacionResincronizarPedido(idPedidoPS: Integer)
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
    begin

        //buscamos si ya existe operación pendiente
        rOperacionesAsincronas.reset();
        rOperacionesAsincronas.setrange(Tipo, rOperacionesAsincronas.Tipo::Pedido);
        rOperacionesAsincronas.setrange(IdOrigen, format(idPedidoPS));
        rOperacionesAsincronas.SetRange(Procesado, false);
        if not rOperacionesAsincronas.FindSet() then begin
            rOperacionesAsincronas.INIT();
            rOperacionesAsincronas.idAsync := 0;
            rOperacionesAsincronas.IdOrigen := FORMAT(idPedidoPS);
            rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::Pedido;
            rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
            rOperacionesAsincronas.INSERT(TRUE);
        end;
    end;

    procedure insertarOperacionActualizacionCategoria(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                rOperacionesAsincronas.INIT();
                rOperacionesAsincronas.idAsync := 0;
                rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPs);
                rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::Categoria;
                rOperacionesAsincronas.IdDestino := rItem."No.";
                rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                rOperacionesAsincronas.INSERT(TRUE);
            END;
        END;
    end;

    procedure insertarOperacionActualizacionDescripcionLarga(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                rOperacionesAsincronas.INIT();
                rOperacionesAsincronas.idAsync := 0;
                rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPs);
                rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::"Descripcion larga";
                rOperacionesAsincronas.IdDestino := rItem."No.";
                rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                rOperacionesAsincronas.INSERT(TRUE);
            END;
        END;
    end;

    procedure calcularInventarioProducto(codProducto: Code[20]): Decimal
    var
        rItem: Record Item;
        rMovsProducto: Record "Item Ledger Entry";
        rSalesSetup: Record "Sales & Receivables Setup";
        rLocation: Record Location;
        continuar: Boolean;
        retorno: Decimal;
        rSalesLine: Record "Sales Line";
        rSalesHeader: Record "Sales Header";
    begin
        CLEAR(retorno);

        rSalesSetup.GET();
        IF rItem.GET(codProducto) THEN BEGIN
            //CALCULAMOS EL STOCK POR ALMACÉN YA QUE PUEDE QUE HAYA ALMACENES DE TRÁNSITO
            rLocation.RESET();
            IF rLocation.FINDFIRST() THEN
                REPEAT
                    IF NOT rLocation."Use As In-Transit" THEN BEGIN
                        continuar := TRUE;
                        rMovsProducto.RESET();
                        rMovsProducto.SETCURRENTKEY("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
                        rMovsProducto.SETRANGE(rMovsProducto."Item No.", codProducto);
                        IF rSalesSetup."Filtro Almacen inventario PS" <> '' THEN
                            IF STRPOS(rSalesSetup."Filtro Almacen inventario PS", rLocation.Code) = 0 THEN
                                continuar := FALSE;
                        IF continuar THEN BEGIN
                            rMovsProducto.SETRANGE(rMovsProducto."Location Code", rLocation.Code);
                            IF rMovsProducto.FINDSET() THEN BEGIN
                                rMovsProducto.CALCSUMS(rMovsProducto.Quantity);
                                retorno += rMovsProducto.Quantity;
                            END
                        END;
                    END;
                UNTIL rLocation.NEXT = 0;
            //LLM MAYO 2015
            //INCLUIMOS LOS MOVIMIENTOS QUE NO TIENEN ALMACÉN EN EL INVENTARIO DEL PRODUCTO SIEMPRE QUE EN EL FILTRO EXISTA
            IF rSalesSetup."Incluir movs. sin almacen PS" THEN BEGIN
                rMovsProducto.RESET();
                rMovsProducto.SETCURRENTKEY("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
                rMovsProducto.SETRANGE(rMovsProducto."Item No.", codProducto);
                rMovsProducto.SETRANGE(rMovsProducto."Location Code", '');
                IF rMovsProducto.FINDSET() THEN BEGIN
                    rMovsProducto.CALCSUMS(rMovsProducto.Quantity);
                    retorno += rMovsProducto.Quantity;
                END;
            END;
            //DESCONTAMOS LAS LÍNEAS DE PEDIDO LANZADAS PARA EL PRODUCTO
            rSalesLine.RESET();
            rSalesLine.SETRANGE("Document Type", rSalesLine."Document Type"::Order);
            rSalesLine.SETRANGE(Type, rSalesLine.Type::Item);
            rSalesLine.SETRANGE("No.", rItem."No.");
            rSalesLine.SETFILTER("Location Code", rSalesSetup."Filtro Almacen inventario PS");
            IF rSalesLine.FINDSET THEN
                REPEAT
                    //corrección ya que puede que existan líneas sin cabecera
                    if rSalesHeader.GET(rSalesLine."Document Type", rSalesLine."Document No.") then
                        IF rSalesHeader.Status = rSalesHeader.Status::Released THEN
                            retorno -= rSalesLine."Qty. to Ship";
                UNTIL rSalesLine.NEXT = 0;
        END;


        EXIT(retorno);
    end;

    /*
        procedure comprobacionListadoDireccionPS(xmlItemsProf: Text;var xmlTextoRetorno: BigText)
        var
            numeroElementos: Integer;
            i: Integer;
            idElementos: array [15000] of Integer;
            descElementos: array [15000] of Code[20];
            enteroId: Integer;
            rShipToAddress: Record "Ship-to Address";
            nodoContenido: DotNet XmlNode;
            rCustomer: Record Customer;
            locautXmlDoc: DotNet XmlDocument;
            resultNode: DotNet XmlNode;
            listaNodos: DotNet XmlNodeList;
            nodeElemento: DotNet XmlNode;
            XMLDOMMgt: Codeunit "XML DOM Management";
            enum: DotNet Dictionary_Of_T_U_Enumerator;
            locautXmlDocOut: DotNet XmlDocument;
            xmlRootNode: DotNet XmlNode;
        begin
            //COMPRUEBA EL LISTADO DE TODOS LOS CLIENTES DE PS, SI ALGUNO DE ELLOS NO EXISTE EN NAV, LO DEVUELVE
            //PARA SU RESINCRONIZACION
            //RELACIÓN CLIENTES PS-NAV MULTIPLE no se modifica nada
            //SINCRONIZA EL LISTADO DE IDPS Y IDNAV PARA LOS PRODUCTOS PASADOS EL EL XML
            XMLDOMMgt.LoadXMLDocumentFromText(xmlItemsProf,locautXmlDoc);
            //locautXmlDoc.load('C:\XMLpruebas.xml');
            //LEEMOS EL NODO QUE NOS INTERESE DE LA RESPUESTA

            //locautXmlDoc.SetProperty('SelectionLanguage', 'XPath');
            resultNode := locautXmlDoc.SelectSingleNode('//ArrayOfListaDirecciones');
            //RECORREMOS TODOS LOS NODOS Y ALMACENAMOS EL VALOR DE ID EN UN ARRAY idElementos
            numeroElementos := 0;
            //MESSAGE(resultNode.text);
            listaNodos := resultNode.ChildNodes;
            enum := listaNodos.GetEnumerator();
            i:=1;
            WHILE enum.MoveNext DO BEGIN
              nodeElemento := enum.Current;
              nodoContenido := nodeElemento.SelectSingleNode('idPs');
              IF EVALUATE(enteroId,nodoContenido.InnerText) THEN BEGIN
                idElementos[i] := enteroId;
                numeroElementos += 1;
                i+=1;
              END;
            END;

            locautXmlDocOut := locautXmlDocOut.XmlDocument;
            XMLDOMMgt.AddRootElement(locautXmlDocOut,'RESPUESTAS',xmlRootNode);
            FOR i:= 1 TO numeroElementos DO BEGIN
              //BUSCAMOS SI CORRESPONDE A LA DIRECCION PRINCIPAL DE ALGUN CLIENTE
              rCustomer.RESET();
              rCustomer.SETRANGE(rCustomer.IdDireccionPrincipalPs,idElementos[i]);
              IF NOT rCustomer.FINDFIRST() THEN BEGIN
                //BUSCAMOS SI CORRESPONDE A DIRECCIONES SECUNDARIAS DE CLIENTES
                rShipToAddress.RESET();
                rShipToAddress.SETRANGE(rShipToAddress.IdDirecionPs,idElementos[i]);
                IF NOT rShipToAddress.FINDFIRST() THEN
                  generaRegistroXMLPrV2(xmlRootNode,FORMAT(idElementos[i]),'1');
              END;
            END;

            xmlTextoRetorno.ADDTEXT(locautXmlDocOut.InnerXml);
        end;
    */
    procedure sincronizarStockTodosProductos()
    var
        rItem: Record Item;
        window: Dialog;
    begin
        window.OPEN(Text002);

        rItem.RESET();
        rItem.SETFILTER(rItem.IdPs, '>0');
        rItem.SETRANGE(rItem."Producto web", TRUE);
        IF rItem.FINDFIRST() THEN
            REPEAT
                insertarOperacionActStock(rItem."No.");
                window.UPDATE(1, rItem."No.");
            UNTIL rItem.NEXT = 0;

        window.CLOSE();
    end;

    procedure sincronizarCategoriasTodosProductos()
    var
        rItem: Record Item;
        window: Dialog;
    begin
        window.OPEN(Text003);

        rItem.RESET();
        rItem.SETFILTER(rItem.IdPs, '>0');
        rItem.SETRANGE(rItem."Producto web", TRUE);
        IF rItem.FINDFIRST() THEN
            REPEAT
                if (rItem.IdPS > 0) then
                    insertarOperacionActualizacionCategoria(rItem."No.");
                window.UPDATE(1, rItem."No.");
            UNTIL rItem.NEXT = 0;
        window.CLOSE();
    end;

    procedure sincronizarCaracteristicasTodosProductos()
    var
        rItem: Record Item;
        window: Dialog;
    begin
        window.OPEN(Text004);

        rItem.RESET();
        rItem.SETFILTER(rItem.IdPs, '>0');
        rItem.SETRANGE(rItem."Producto web", TRUE);
        IF rItem.FINDFIRST() THEN
            REPEAT
                insertarOperacionActualizacionAtributos(rItem."No.");
                window.UPDATE(1, rItem."No.");
            UNTIL rItem.NEXT = 0;
        window.CLOSE();
    end;

    procedure sincronizarImagenesTodosProductos()
    var
        rItem: Record Item;
        window: Dialog;
    begin
        window.OPEN(Text005);

        rItem.RESET();
        rItem.SETFILTER(rItem.IdPs, '>0');
        rItem.SETRANGE(rItem."Producto web", TRUE);
        IF rItem.FINDFIRST() THEN
            REPEAT
                insertarOperacionActImagenesProducto(rItem."No.");
                window.UPDATE(1, rItem."No.");
            UNTIL rItem.NEXT = 0;
        window.CLOSE();
    end;

    procedure sincronizarDescripcionesTodosProductos()
    var
        rItem: Record Item;
        window: Dialog;
    begin
        window.OPEN(Text005);

        rItem.RESET();
        rItem.SETFILTER(rItem.IdPs, '>0');
        rItem.SETRANGE(rItem."Producto web", TRUE);
        IF rItem.FINDFIRST() THEN
            REPEAT
                insertarOperacionActualizacionDescripcionLarga(rItem."No.");
                window.UPDATE(1, rItem."No.");
            UNTIL rItem.NEXT = 0;
        window.CLOSE();
    end;

    procedure sincronizarCamposPersonalizadosTodosProductos()
    var
        rItem: Record Item;
        window: Dialog;
    begin
        window.OPEN(Text008);

        rItem.RESET();
        rItem.SETFILTER(rItem.IdPs, '>0');
        rItem.SETRANGE(rItem."Producto web", TRUE);
        IF rItem.FINDFIRST() THEN
            REPEAT
                insertarOperacionCamposPersonalizados(rItem."No.");
                window.UPDATE(1, rItem."No.");
            UNTIL rItem.NEXT = 0;
        window.CLOSE();
    end;

    procedure insertarOperacionActEstPedido(idPedidoPS: Integer; EstadoPedidoPS: Code[10])
    var
        rAsync: Record "Modificaciones Asincronas PS";
    begin
        rAsync.RESET();
        rAsync.SETRANGE(rAsync.IdOrigen, FORMAT(idPedidoPS));
        rAsync.SETRANGE(rAsync.IdDestino, FORMAT(EstadoPedidoPS));
        rAsync.SETRANGE(rAsync.Procesado, FALSE);
        rAsync.SETRANGE(rAsync.Tipo, rAsync.Tipo::"Estado Pedido");
        IF NOT rAsync.FINDFIRST() THEN BEGIN
            rAsync.INIT();
            rAsync.idAsync := 0;
            rAsync.IdOrigen := FORMAT(idPedidoPS);
            rAsync.IdDestino := EstadoPedidoPS;
            rAsync.Tipo := rAsync.Tipo::"Estado Pedido";
            rAsync."Fecha/Hora" := CURRENTDATETIME();
            rAsync.INSERT(TRUE);
        end;
    end;

    //funcion creada para que no se dupliquen los estados en las transciones automáticas (p.e. cuando lanzamos el pedido)
    internal procedure insertarOperacionActEstPedidoAutomatica(idPedidoPS: Integer; EstadoPedidoPS: Code[10])
    var
        rAsync: Record "Modificaciones Asincronas PS";
    begin
        rAsync.Reset();
        rAsync.SetRange(IdOrigen, Format(idPedidoPS));
        rAsync.SetRange(Tipo, rAsync.Tipo::"Estado Pedido");
        rAsync.SetRange(IdDestino, EstadoPedidoPS);
        if not rAsync.FindSet() then begin
            rAsync.INIT();
            rAsync.idAsync := 0;
            rAsync.IdOrigen := FORMAT(idPedidoPS);
            rAsync.IdDestino := EstadoPedidoPS;
            rAsync.Tipo := rAsync.Tipo::"Estado Pedido";
            rAsync."Fecha/Hora" := CURRENTDATETIME();
            rAsync.INSERT(TRUE);
        end;
    end;

    procedure insertarOperacionActSegPedido(IdPedidoPS: Integer; NseguimientoPS: Text[30])
    var
        rAsync: Record "Modificaciones Asincronas PS";
    begin
        rAsync.INIT();
        rAsync.idAsync := 0;
        rAsync.IdOrigen := FORMAT(IdPedidoPS);
        rAsync.Tipo := rAsync.Tipo::Seguimiento;
        rAsync.Texto := NseguimientoPS;
        rAsync."Fecha/Hora" := CURRENTDATETIME();
        rAsync.INSERT(TRUE);
    end;

    procedure insertarOperacionActTarifa(IdProductoPS: Integer)
    var
        rAsync: Record "Modificaciones Asincronas PS";
        SalesSetup: Record "Sales & Receivables Setup";
        item: Record Item;
    begin
        //COMPROBAMOS QUE NO EXISTA UNA ACTUALIZACIÓN PENDIENTE PARA EL PRODUCTO ANTES DE INSERTAR UNA NUEVA
        //NGPC COMPROBAMOS QUE ESTÉ SINCRONIZADO CON PS
        IF IdProductoPS = 0 THEN
            EXIT;

        SalesSetup.GET();
        IF SalesSetup."Sincro Tarifas Automat." THEN BEGIN
            item.reset();
            item.SetRange(IdPS, IdProductoPS);
            if item.findset() then begin
                rAsync.RESET();
                rAsync.SETRANGE(rAsync.IdOrigen, FORMAT(IdProductoPS));
                rAsync.SETRANGE(rAsync.Procesado, FALSE);
                rAsync.SETRANGE(rAsync.Tipo, rAsync.Tipo::Tarifa);
                IF NOT rAsync.FINDFIRST() THEN BEGIN
                    rAsync.INIT();
                    rAsync.idAsync := 0;
                    rAsync.IdOrigen := FORMAT(IdProductoPS);
                    rAsync.IdDestino := item."No.";
                    rAsync.Tipo := rAsync.Tipo::Tarifa;
                    rAsync."Fecha/Hora" := CURRENTDATETIME();
                    rAsync.INSERT(TRUE);
                END;
            end;
        END;
    end;

    procedure insertarOperacionActTarifaNAut(IdProductoPS: Integer)
    var
        rAsync: Record "Modificaciones Asincronas PS";
        item: Record Item;
    begin
        //COMPROBAMOS QUE NO EXISTA UNA ACTUALIZACIÓN PENDIENTE PARA EL PRODUCTO ANTES DE INSERTAR UNA NUEVA
        //NGPC COMPROBAMOS QUE ESTÉ SINCRONIZADO CON PS
        IF IdProductoPS = 0 THEN
            EXIT;

        item.reset();
        item.SetRange(IdPS, IdProductoPS);
        if item.findset() then begin
            rAsync.RESET();
            rAsync.SETRANGE(rAsync.IdOrigen, FORMAT(IdProductoPS));
            rAsync.SETRANGE(rAsync.Procesado, FALSE);
            rAsync.SETRANGE(rAsync.Tipo, rAsync.Tipo::Tarifa);
            IF NOT rAsync.FINDFIRST() THEN BEGIN
                rAsync.INIT();
                rAsync.idAsync := 0;
                rAsync.IdOrigen := FORMAT(IdProductoPS);
                rAsync.IdDestino := item."No.";
                rAsync.Tipo := rAsync.Tipo::Tarifa;
                rAsync."Fecha/Hora" := CURRENTDATETIME();
                rAsync.INSERT(TRUE);
            END;
        end;
    end;

    procedure getImpuestosSegunIdZona(zona: Text[30]): Integer
    var
        rSalesSetup: Record "Sales & Receivables Setup";
        sarray: array[100] of Text[30];
        retorno: Integer;
        contador: Integer;
        i: Integer;
    begin
        //RESPUESTAS
        //1 - ZONA NACIONAL
        //2 - ZONA NACIONAL IMP. ESPECIAL CANARIAS, CEUTA, MELILLA
        //3 - ZONA UE
        //4 - ZONA NO UE
        rSalesSetup.GET();
        retorno := 0;
        IF zona = '' THEN
            retorno := 1;

        IF retorno = 0 THEN BEGIN
            contador := 0;
            REPEAT
                contador += 1;
                sarray[contador] := token(rSalesSetup."Zonas PS nacional", ',');
            UNTIL sarray[contador] = '';
            FOR i := 1 TO contador DO BEGIN
                IF (zona = sarray[i]) THEN
                    retorno := 1;
            END;
        END;

        IF retorno = 0 THEN BEGIN
            contador := 0;
            REPEAT
                contador += 1;
                sarray[contador] := token(rSalesSetup."Zonas PS nacional esp.", ',');
            UNTIL sarray[contador] = '';
            FOR i := 1 TO contador DO BEGIN
                IF (zona = sarray[i]) THEN
                    retorno := 2;
            END;
        END;

        IF retorno = 0 THEN BEGIN
            contador := 0;
            REPEAT
                contador += 1;
                sarray[contador] := token(rSalesSetup."Zonas PS UE", ',');
            UNTIL sarray[contador] = '';
            FOR i := 1 TO contador DO BEGIN
                IF (zona = sarray[i]) THEN
                    retorno := 3;
            END;
        END;

        IF retorno = 0 THEN BEGIN
            contador := 0;
            REPEAT
                contador += 1;
                sarray[contador] := token(rSalesSetup."Zonas PS no UE", ',');
            UNTIL sarray[contador] = '';
            FOR i := 1 TO contador DO BEGIN
                IF (zona = sarray[i]) THEN
                    retorno := 4;
            END;
        END;

        IF retorno = 0 THEN
            retorno := 1;

        EXIT(retorno)
    end;

    procedure token(var Text: Text[1024]; Separator: Text[1]) Token: Text[30]
    var
        Pos: Integer;
    begin
        Pos := STRPOS(Text, Separator);
        IF Pos > 0 THEN BEGIN
            Token := COPYSTR(Text, 1, Pos - 1);
            IF Pos + 1 <= STRLEN(Text) THEN
                Text := COPYSTR(Text, Pos + 1)
            ELSE
                Text := '';
        END ELSE BEGIN
            Token := Text;
            Text := '';
        END;
    end;

    procedure getGrupoContableClientexZona(id_zona: Text[30]): Code[20]
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        //GRUPOS CONTABLES SEGÚN ZONA
        rSalesSetup.GET();
        CASE getImpuestosSegunIdZona(id_zona) OF
            1:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable cl. PS");
                END;
            2:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable cl. PS nac esp");
                END;
            3:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable cl. PS UE");
                END;
            4:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable cl. PS no UE");
                END;
        END;
        //FIN
    end;

    procedure getGrupoContableNegocioxZona(id_zona: Text[30]): Code[20]
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        //GRUPOS CONTABLES SEGÚN ZONA
        rSalesSetup.GET();
        CASE getImpuestosSegunIdZona(id_zona) OF
            1:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable neg. PS");
                END;
            2:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable neg. PS nac esp");
                END;
            3:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable neg. PS UE");
                END;
            4:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable neg. PS no UE");
                END;
        END;
        //FIN
    end;

    procedure getGrupoContableIVAxZona(id_zona: Text[30]): Code[20]
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        //GRUPOS CONTABLES SEGÚN ZONA
        rSalesSetup.GET();
        CASE getImpuestosSegunIdZona(id_zona) OF
            1:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable IVA PS");
                END;
            2:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable IVA PS nac esp");
                END;
            3:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable IVA PS UE");
                END;
            4:
                BEGIN
                    EXIT(rSalesSetup."Grupo contable IVA PS no UE");
                END;
        END;
        //FIN
    end;

    procedure getClienteWebGenerico(): Code[20]
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.GET();
        EXIT(rSalesSetup."Cliente tarifa Web");
    end;

    procedure getLicenseKey(): Text
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.GET();
        EXIT(SalesSetup."License Key 1" + SalesSetup."License Key 2");
    end;

    procedure combineLicenseKey(key1: Text[250]; key2: Text[250]; var Result: Text)
    begin
        Result := key1 + key2;
    end;

    procedure splitLicenseKey(OperationDescription: Text[500]; var Part1: Text[250]; var Part2: Text[250])
    begin
        Part1 := '';
        Part2 := '';

        IF OperationDescription = '' THEN
            EXIT;

        IF STRLEN(OperationDescription) > MAXSTRLEN(Part1) THEN BEGIN
            Part1 := COPYSTR(OperationDescription, 1, MAXSTRLEN(Part1));
            Part2 := COPYSTR(OperationDescription, MAXSTRLEN(Part1) + 1, STRLEN(OperationDescription) - MAXSTRLEN(Part1));
        END ELSE
            Part1 := COPYSTR(OperationDescription, 1, STRLEN(OperationDescription));
    end;

    procedure checkDiferenciasIVA(codPedido: Code[20])
    var
        rSalesHeader: Record "Sales Header";
        rSalesLine: Record "Sales Line";
        TempVATAmountLine1: Record "VAT Amount Line" temporary;
        TempSalesLine: Record "Sales Line";
        baseImponible: Decimal;
        importeIva: Decimal;
        diferencia: Decimal;
        rSalesLineAux: Record "Sales Line";
    begin
        IF rSalesHeader.GET(rSalesHeader."Document Type"::Order, codPedido) THEN BEGIN

            rSalesLine.RESET();
            rSalesLine.SETRANGE(rSalesLine."Document Type", rSalesLine."Document Type"::Order);
            rSalesLine.SETRANGE(rSalesLine."Document No.", codPedido);
            IF rSalesLine.FINDSET THEN BEGIN
                //rSalesLine.CalcVATAmountLines
                rSalesLine.CalcVATAmountLines(0, rSalesHeader, TempSalesLine, TempVATAmountLine1);
            END;

            IF TempVATAmountLine1.FINDSET() THEN
                REPEAT
                    baseImponible += TempVATAmountLine1."VAT Base";
                    importeIva += TempVATAmountLine1."VAT Amount";
                UNTIL TempVATAmountLine1.NEXT = 0;

            diferencia := rSalesHeader.TotalPCiva - (baseImponible + importeIva);

            IF (diferencia <> 0) THEN BEGIN
                //hay que ajustar la línea de iva
                TempVATAmountLine1.FINDFIRST();
                TempVATAmountLine1.VALIDATE("VAT Amount", TempVATAmountLine1."VAT Amount" + diferencia);
                TempVATAmountLine1.Modified := TRUE;
                TempVATAmountLine1.MODIFY();

                rSalesLineAux.UpdateVATOnLines(1, rSalesHeader, rSalesLineAux, TempVATAmountLine1);
            END;

        END;
    end;

    local procedure "//facturacion PS"()
    begin
    end;

    procedure GetCodigoClienteNAV(idPS: Integer): Code[20]
    var
        rCustomer: Record Customer;
    begin
        rCustomer.RESET();
        rCustomer.SETRANGE(rCustomer.IdClientePS, idPS);
        IF rCustomer.FINDFIRST() THEN
            EXIT(rCustomer."No.")
        ELSE
            EXIT('');
    end;

    /*
    procedure GetPDF_FacturaVenta(NumFactura: Code[20];var PDF: array [1000000] of Byte;var "TamañoPDF": Integer) Resultado: Boolean
    var
        SalesHeader: Record "Sales Invoice Header";
        FileName: Text[100];
        FilePath: Text[200];
        FilePDF: File;
        i: Integer;
        k: Integer;
        IdiomaActual: Integer;
        ReportPedido: Report Report50048;
        rSelectionReports: Record "Report Selections";
    begin
        /////////////////////////////////////////////////////////
        // CX_GetPDF_FacturaVenta()
        //----Parámetros----------------------------------------
        // NumFactura : CODE[20]; Nº de la factura a imprimir.
        // PDF : ARRAY[1000000] OF CHAR; Donde se va a almacenar el PDF para devolverlo.
        // TamañoPDF : Integer; Tamaño del fichero PDF generado.
        //----Descripción---------------------------------------
        // Imprime el report de la Aceptación de Retirada de Documentos en PDF y lo devuelve en un array de caracteres
        //----Autor---------------------------------------------
        // COAG-PNC;2009-09-02
        // PARA QUE FUNCIONE DEBEMOS TENER EL REPORT EN FORMATO ADAPTADO A ROLES
        /////////////////////////////////////////////////////////

        // Para depurar
        //MESSAGE('NumFactura: %1; Fecha: %2', NumFactura, Fecha);

        //Obtenemos la ruta donde vamos a generar el PDF y borramos el fichero en el caso de que exista.
        FileName := 'pdfFactura' + sanitizeStringFile(NumFactura) + '.pdf';
        //FilePath := ENVIRON('TMP') + '\' + FileName;
        //+FilePath := TEMPORARYPATH + FileName;
        FilePath := 'C:\WINDOWS\temp\' + FileName;

        IF EXISTS(FilePath) THEN
            ERASE(FilePath);

        // Buscamos la factura
        //SalesInvHeader.SETRANGE("No.", NumFactura);
        //IF NOT SalesInvHeader.GET(NumFactura) THEN
        //IF NOT SalesInvHeader.GET('VF+0900072') THEN

        //ALBERTO. 21/09/2009. Modifico para que coja la factura que viene por parámetro y no la de prueba
        //SalesInvHeader.SETRANGE("No.", 'VF+0900072');
        SalesHeader.RESET();
        SalesHeader.SETRANGE(SalesHeader."No.",NumFactura);
        //FIN 21/09/2009

        IF NOT SalesHeader.FINDFIRST THEN
        BEGIN
            Resultado := FALSE;
            EXIT;
        END;

        // Generamos el PDF
        //Establecemos el idioma Castellano para que el report salga correctamente al llamar a esta funcion desde un
        //web service.


        GLOBALLANGUAGE(1034);  // 1034 = "Español - España (alfabetización tradicional)"
        SalesHeader.SETRECFILTER;
        rSelectionReports.RESET();
        rSelectionReports.SETRANGE(rSelectionReports.Usage,rSelectionReports.Usage::"S.Invoice");
        IF rSelectionReports.FINDFIRST() THEN
          REPORT.SAVEASPDF(rSelectionReports."Report ID", FilePath, SalesHeader)
        ELSE BEGIN
          ReportPedido.SETTABLEVIEW(SalesHeader);
          ReportPedido.LANGUAGE(1034);  // 1034 = "Español - España (alfabetización tradicional)"
          ReportPedido.SAVEASPDF(FilePath);
        END;


        // Y lo devolvemos en el array
        IF EXISTS(FilePath) THEN
        BEGIN
            FilePDF.OPEN(FilePath);
            FilePDF.SEEK(0);
            TamañoPDF := FilePDF.LEN;
            // Rellenamos el array con el contenido del PDF
            FOR k := 1 TO TamañoPDF DO
            BEGIN
                FilePDF.READ(PDF[k]);
            END;
            Resultado := TRUE;
        END
        ELSE
            Resultado := FALSE;

        //CERRAMOS EL FICHERO
        FilePDF.CLOSE;
        CLEAR(FilePDF);

        //BORRAMOS EL FICHERO PARA NO DEJAR BASURA
        IF EXISTS(FilePath) THEN
          ERASE(FilePath);
    end;
*/
    procedure sanitizeStringFile(entrada: Code[20]): Text[30]
    begin
        EXIT(CONVERTSTR(entrada, '/\?*:"<>|', '---------'));
    end;

    procedure getStyleTextOrderStatus(idEstado: Code[10]): Text[30]
    var
        rEstadosPedido: Record "Relacion de estados pedido PS";
        estadoPtePago: Code[10];
    begin
        IF idEstado = '' THEN
            EXIT('Standard');

        rEstadosPedido.RESET();
        rEstadosPedido.SETRANGE(rEstadosPedido."Pte Pago", TRUE);
        IF rEstadosPedido.FINDFIRST() THEN
            REPEAT
                IF idEstado = rEstadosPedido.idEstadoPS THEN
                    EXIT('Unfavorable')
            UNTIL rEstadosPedido.NEXT = 0;

        EXIT('Favorable');
    end;

    procedure compruebaPtePago(codPedido: Code[20]): Boolean
    var
        rEstadosPedido: Record "Relacion de estados pedido PS";
        estadoPtePago: Code[10];
        rSalesHeader: Record "Sales Header";
    begin
        rSalesHeader.GET(rSalesHeader."Document Type"::Order, codPedido);
        IF rSalesHeader.IdPedidoPS = 0 THEN
            EXIT(FALSE);

        rEstadosPedido.RESET();
        rEstadosPedido.SETRANGE(rEstadosPedido."Pte Pago", TRUE);
        IF rEstadosPedido.FINDFIRST() THEN
            REPEAT
                IF rSalesHeader."Estado Pedido PS" = rEstadosPedido.idEstadoPS THEN
                    EXIT(TRUE)
UNTIL rEstadosPedido.NEXT = 0;

        EXIT(FALSE);
    end;

    procedure getMensajeErrorPago(): Text
    begin
        EXIT('No se puede registrar un pedido PS en estado Pendiente de Pago');
    end;


    procedure getIdCategoriaPS(categoryCode: Code[20]): Integer
    var
        rItemCategory: Record "Item Category";
    begin
        rItemCategory.get(categoryCode);
        exit(rItemCategory.IdPs);
    end;

    procedure getSincroCategorias(): Boolean
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        case rSalesSetup."Sincronizar categorias" of
            rSalesSetup."Sincronizar categorias"::Automatica, rSalesSetup."Sincronizar categorias"::Si:
                exit(true);
            else
                exit(false);
        end;
    end;

    procedure getSincroAtributos(): Boolean
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        case rSalesSetup."Sincronizar atributos" of
            rSalesSetup."Sincronizar atributos"::Automatica, rSalesSetup."Sincronizar atributos"::Si:
                exit(true);
            else
                exit(false);
        end;
    end;

    procedure getActivarProductosPS(): Boolean
    var
        rsalesSetup: Record "Sales & Receivables Setup";
    begin
        rsalesSetup.get();
        if (rsalesSetup."Activar productos PS" = rsalesSetup."Activar productos PS"::Si) then
            exit(true)
        else
            exit(false);
    end;

    procedure getLastUpdatedFTP(): DateTime
    var
        rsalesSetup: Record "Sales & Receivables Setup";
    begin
        rsalesSetup.Get();
        exit(rsalesSetup."Last FTP update");
    end;

    procedure getSincronizarImagenesFTP(): Boolean
    var
        rsalesSetup: Record "Sales & Receivables Setup";
    begin
        rsalesSetup.Get();
        exit(rsalesSetup."Sincronizar imagenes FTP");
    end;

    procedure updateLastFTPDateTime(fechaActual: DateTime)
    var
        rsalesSetup: Record "Sales & Receivables Setup";
    begin
        rsalesSetup.Get();
        rsalesSetup."Last FTP update" := fechaActual;
        rsalesSetup."Sincronizar imagenes FTP" := false;
        rsalesSetup.Modify();
    end;

    //v1.0.0.19
    procedure quitarInicioURL(cadena: Text): Text
    begin
        if StrPos(cadena, '/') > 0 then begin
            exit(CopyStr(cadena, StrPos(cadena, '/') + 2));
        end;
        exit(cadena);
    end;

    //personalización de stock bresme
    procedure actualizarStockBresme(itemNo: Code[20]; stock: Decimal; comafe: Decimal)
    var
        rItem: Record Item;
        cuPS: Codeunit PSSincro;
    begin
        if rItem.Get(itemNo) then begin
            //1.0.0.19
            if stock > 1000000 then
                rItem."Stock Bresme" := 1000000
            else
                rItem."Stock Bresme" := stock;
            //1.0.0.19
            rItem."Stock Comafe" := comafe;
            rItem.Modify();

            //corrección mete productos que todavía no están dados de alta en PS - 1.0.0.18
            if rItem.IdPS > 0 then
                cuPS.insertarOperacionActStock(rItem."No.");
        end;
    end;

    //RETORNAMOS INVENTARIO EN NAV + COMAFE EN XML
    //<inventario>
    //  <stock></stock>
    //  <comafe></comafe>
    //</inventario>
    procedure calcularInventarioProducto(codProducto: Code[20]; var xmlTextoRetorno: text)
    var
        rItem: Record Item;
        retorno: Decimal;
        retornoComafe: Decimal;
        xmlRootNode: XmlNode;
        locautXmlDocOut: XmlDocument;
    begin

        CLEAR(retorno);
        rItem.Get(codProducto);

        retorno := rItem."Stock Bresme";
        retornoComafe := rItem."Stock Comafe";
        generaRegistroXMLInventario(xmlRootNode, retorno, retornoComafe);

        locautXmlDocOut := XmlDocument.Create();
        locautXmlDocOut.Add(xmlRootNode);
        locautXmlDocOut.WriteTo(xmlTextoRetorno);
    end;

    local procedure generaRegistroXMLInventario(var xmlNodeOut: XmlNode; stock: Decimal; comafe: Decimal)
    begin
        xmlNodeOut := XmlElement.create('inventario', '').AsXmlNode();
        xmlNodeOut.AsXmlElement().Add(XmlElement.create('stock', '', format(stock)).AsXmlNode());
        xmlNodeOut.AsXmlElement().Add(XmlElement.create('comafe', '', format(comafe)).AsXmlNode());
    end;

    procedure getDescripcionesProducto(codProducto: Code[20]; var descripcionLarga: Text; var descripcionCorta: Text;
        var nombreSEO: Text; var descripcionSEO: Text)
    var
        rItem: Record Item;
        rDescVarias: Record "Descripciones Varias";
        retorno: Text;
        inStr: InStream;
    begin
        rItem.Get(codProducto);
        rItem.CalcFields("DescVar Web Larga");

        rDescVarias.Reset();
        rDescVarias.SetRange("Tipo Descripcion", rDescVarias."Tipo Descripcion"::"Prod Desc Larga");
        rDescVarias.SetRange(Codigo, rItem."No.");
        if rDescVarias.FindSet() then
            repeat
                rDescVarias.CalcFields("Blob Descripcion");
                if rDescVarias."Blob Descripcion".HasValue then begin
                    Clear(inStr);
                    rDescVarias."Blob Descripcion".CreateInStream(inStr, TextEncoding::UTF8);
                    inStr.Read(descripcionLarga);
                end;
            until rDescVarias.Next() = 0;
        rDescVarias.Reset();
        rDescVarias.SetRange("Tipo Descripcion", rDescVarias."Tipo Descripcion"::"Prod Desc Corta");
        rDescVarias.SetRange(Codigo, rItem."No.");
        if rDescVarias.FindSet() then
            repeat
                rDescVarias.CalcFields("Blob Descripcion");
                if rDescVarias."Blob Descripcion".HasValue then begin
                    Clear(inStr);
                    rDescVarias."Blob Descripcion".CreateInStream(inStr, TextEncoding::UTF8);
                    inStr.Read(descripcionCorta);
                end;
            until rDescVarias.Next() = 0;
        rDescVarias.Reset();
        rDescVarias.SetRange("Tipo Descripcion", rDescVarias."Tipo Descripcion"::"Prod Pto 1");
        rDescVarias.SetRange(Codigo, rItem."No.");
        if rDescVarias.FindSet() then
            repeat
                rDescVarias.CalcFields("Blob Descripcion");
                if rDescVarias."Blob Descripcion".HasValue then begin
                    Clear(inStr);
                    rDescVarias."Blob Descripcion".CreateInStream(inStr, TextEncoding::UTF8);
                    inStr.Read(nombreSEO);
                end;
            until rDescVarias.Next() = 0;
        rDescVarias.Reset();
        rDescVarias.SetRange("Tipo Descripcion", rDescVarias."Tipo Descripcion"::"Prod Pto 2");
        rDescVarias.SetRange(Codigo, rItem."No.");
        if rDescVarias.FindSet() then
            repeat
                rDescVarias.CalcFields("Blob Descripcion");
                if rDescVarias."Blob Descripcion".HasValue then begin
                    Clear(inStr);
                    rDescVarias."Blob Descripcion".CreateInStream(inStr, TextEncoding::UTF8);
                    inStr.Read(descripcionSEO);
                end;
            until rDescVarias.Next() = 0;
    end;

    /*
    procedure getDescipcionCortaProducto(codProducto: Code[20]): Text
    var
        rItem: Record Item;
        rDescVarias: Record "Descripciones Varias";
        retorno: Text;
        inStr: InStream;
    begin
        rItem.Get(codProducto);
        rItem.CalcFields("DescVar Web Larga");

        rDescVarias.Reset();
        rDescVarias.SetRange("Tipo Descripcion", rDescVarias."Tipo Descripcion"::"Prod Desc Corta");
        rDescVarias.SetRange(Codigo, rItem."No.");
        if rDescVarias.FindSet() then
            repeat
                rDescVarias.CalcFields("Blob Descripcion");
                if rDescVarias."Blob Descripcion".HasValue then begin
                    Clear(inStr);
                    rDescVarias."Blob Descripcion".CreateInStream(inStr, TextEncoding::UTF8);
                    inStr.Read(retorno);
                end;
            until rDescVarias.Next() = 0;
        exit(retorno);
    end;
    */

    //en este evento se suscribirá la funcionalidad que realiza el pedido de compra y lo envía al NAV de Bresme en la extensión de integración
    [IntegrationEvent(false, false)]
    local procedure OnAfterNewPSOrderCreated(var rec: Record "Sales Header")
    begin
    end;

    procedure getPrecioVentaProductoCombinacion(idProductoPS: Integer; idCombinacion: Integer): Decimal
    var
        rSalesPrice: Record "Sales Price";
        rCustomer: Record Customer;
        rSalesSetup: Record "Sales & Receivables Setup";
        rItem: Record Item;
        rVATSetup: Record "VAT Posting Setup";
    begin
        rSalesSetup.GET();
        rItem.RESET();
        rItem.SETRANGE(rItem.IdPs, idProductoPS);
        if idCombinacion > 0 then begin
            rItem.SetRange(Combinacion, true);
            ritem.SetRange("Id Combinacion", idCombinacion);
        end;
        IF rItem.FINDFIRST() THEN BEGIN
            IF rSalesSetup."Cliente tarifa Web" <> '' THEN BEGIN
                //obtenemos el cliente
                rCustomer.Get(rSalesSetup."Cliente tarifa web");

                rSalesPrice.RESET();
                rSalesPrice.SETRANGE(rSalesPrice."Item No.", rItem."No.");
                rSalesPrice.SETRANGE(rSalesPrice."Sales Type", rSalesPrice."Sales Type"::Customer);
                rSalesPrice.SETRANGE(rSalesPrice."Sales Code", rCustomer."No.");
                rSalesPrice.SETFILTER(rSalesPrice."Starting Date", '<=%1', TODAY);
                rSalesPrice.SETFILTER(rSalesPrice."Ending Date", '>=%1|%2', TODAY, 0D);
                //PERSO PEPEBAR
                rSalesPrice.SetRange("Minimum Quantity", 0, 1);
                IF rSalesPrice.FINDFIRST() THEN begin
                    //PERSO PINTURASPRINCIPADO
                    if rSalesPrice."Price Includes VAT" then begin
                        if rCustomer.Get(rSalesSetup."Cliente tarifa web") then begin
                            rVATSetup.Get(rCustomer."VAT Bus. Posting Group", rItem."VAT Prod. Posting Group");
                            rSalesPrice."Unit Price" := rSalesPrice."Unit Price" / (1 + rVATSetup."VAT %" / 100);
                        end else
                            rSalesPrice."Unit Price" := rSalesPrice."Unit Price" / 1.21;
                    end;
                    EXIT(rSalesPrice."Unit Price")
                end
                ELSE BEGIN
                    //BUSCAMOS EL GRUPO PRECIOS CLIENTE DEL CLIENTE SI EXISTE TARIFA
                    rSalesPrice.SETRANGE(rSalesPrice."Sales Type", rSalesPrice."Sales Type"::"Customer Price Group");
                    rSalesPrice.SETRANGE(rSalesPrice."Sales Code", rCustomer."Customer Price Group");
                    IF rSalesPrice.FINDFIRST() THEN begin
                        //PERSO PINTURASPRINCIPADO
                        if rSalesPrice."Price Includes VAT" then begin
                            if rCustomer.Get(rSalesSetup."Cliente tarifa web") then begin
                                rVATSetup.Get(rCustomer."VAT Bus. Posting Group", rItem."VAT Prod. Posting Group");
                                rSalesPrice."Unit Price" := rSalesPrice."Unit Price" / (1 + rVATSetup."VAT %" / 100);
                            end else
                                rSalesPrice."Unit Price" := rSalesPrice."Unit Price" / 1.21;
                        end;
                        EXIT(rSalesPrice."Unit Price");
                    end
                    ELSE
                        EXIT(rItem."Unit Price");
                END;
            END ELSE
                EXIT(rItem."Unit Price");
        END ELSE
            EXIT(0);
    end;

    procedure insertarOperacionActStock(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        //opcion no sincronizar stock
        rSalesSetup.Get();
        if rSalesSetup."No sincronizar Stock" then
            exit;

        IF rItem.GET(codProducto) THEN BEGIN
            IF (rItem."Producto web") and (rItem.IdPS > 0) THEN BEGIN
                rOperacionesAsincronas.INIT();
                rOperacionesAsincronas.idAsync := 0;
                //combinaciones de producto pinturasprincipado
                rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPs);
                if rItem.Combinacion then
                    rOperacionesAsincronas.IdDestino := Format((rItem."Id Combinacion"));
                rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::Stock;
                rOperacionesAsincronas.Cantidad := calcularInventarioProducto(codProducto);
                rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                rOperacionesAsincronas.INSERT(TRUE);
            END;
        END;
    end;


    procedure RaiseOnAfterNewPSOrderCreated(orderNo: Code[20])
    var
        rSalesHeader: Record "Sales Header";
    begin
        if rSalesHeader.Get(rSalesHeader."Document Type"::Order, orderNo) then
            OnAfterNewPSOrderCreated(rSalesHeader);
    end;

    //ALTA DE CLIENTES B2B
    procedure altaClienteAutomatica(idClientePs: Integer; siret: Text; company: Code[20]): Code[20]
    var
        rCustomer: Record Customer;
    begin
        IF rCustomer.get(company) then begin
            if (UpperCase(siret) = UpperCase(rCustomer."VAT Registration No.")) and (not rCustomer.EsClientePS) then begin
                rCustomer.IdClientePS := idClientePs;
                rCustomer.EsClientePS := true;
                rCustomer.fechaAltaClientePS := CurrentDateTime;
                rCustomer."Pendiente sincro B2B" := false;
                rCustomer.Modify();

                //insertamos la operación asíncrona para actualizar el grupo de cliente (grupo descuento cliente PEPEBAR)
                insertarOperacionActGrupoCliente(rCustomer."No.", rCustomer."Customer Disc. Group");

                exit(rCustomer."No.");
            end;
        end;
    end;

    procedure getListaNuevosClientes(xmlItemsProf: Text; var xmlTextoRetorno: text)
    var
        locautXmlDoc: XmlDocument;
        resultNode: XmlNode;
        listaNodos: XmlNodeList;
        nodeElemento: XmlNode;
        numeroElementos: Integer;
        i: Integer;
        idElementos: array[15000] of Integer;

        enteroId: Integer;
        nodoContenido: XmlNode;
        rCustomer: Record Customer;
        XMLDOMMgt: Codeunit "XML DOM Management";

        locautXmlDocOut: XmlDocument;
        xmlRootNode: XmlNode;
    begin

        XmlDocument.ReadFrom(xmlItemsProf, locautXmlDoc);
        //RECORREMOS TODOS LOS NODOS Y ALMACENAMOS EL VALOR DE ID EN UN ARRAY idElementos
        numeroElementos := 0;
        locautXmlDoc.SelectNodes('//ArrayOfListaClientesDetalle/listaClientesDetalle', listaNodos);
        i := 1;
        foreach nodeElemento in listaNodos do begin
            nodeElemento.SelectSingleNode('idPs', nodoContenido);

            IF EVALUATE(enteroId, nodoContenido.AsXmlElement().InnerText) THEN BEGIN
                idElementos[i] := enteroId;
                numeroElementos += 1;
                i += 1;
            END;
        end;

        //respuesta y procesado
        xmlRootNode := XmlElement.Create('RESPUESTAS').AsXmlNode();
        FOR i := 1 TO numeroElementos DO BEGIN
            rCustomer.Reset();
            rCustomer.SetRange(IdClientePS, idElementos[i]);
            if not rCustomer.FindFirst() then
                generaRegistroXMLPrV2(xmlRootNode, FORMAT(idElementos[i]), '');
        END;

        locautXmlDocOut := XmlDocument.Create();
        locautXmlDocOut.Add(xmlRootNode);
        locautXmlDocOut.WriteTo(xmlTextoRetorno);
    end;

    procedure updateIdDireccionPrincipalCliente(codCliente: Code[20]; idDFPS: Integer)
    var
        rCustomer: Record Customer;
    begin
        if rCustomer.get(codCliente) then begin
            rCustomer.IdDireccionPrincipalPS := idDFPS;
            rCustomer.Modify();
        end;
    end;

    procedure updateIdDireccionEnvioCliente(codCliente: Code[20]; codDirecicon: Code[20]; idDEPS: Integer)
    var
        rShipToAdd: Record "Ship-to Address";
    begin
        if rShipToAdd.get(codCliente, codDirecicon) then begin
            rShipToAdd.IdDireccionPS := idDEPS;
            rShipToAdd.Modify();
        end;
    end;

    ///FACTURACION PS
    procedure GetPDF_DocumentoVenta(NumDocumento: Code[20]; NumCliente: code[20]; var PDFB64: Text): Boolean
    var
        rSalesInvHeader: record "Sales Invoice Header";
        rSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        noEncontrado: Boolean;
    begin
        //verificamos si es una factura o un abono
        if rSalesInvHeader.get(NumDocumento) then begin
            if rSalesInvHeader."Bill-to Customer No." = NumCliente then
                exit(GetPDF_FacturaVenta(NumDocumento, PDFB64))
            else
                noEncontrado := true;
        end;


        if rSalesCrMemoHeader.Get(NumDocumento) then
            if rSalesCrMemoHeader."Bill-to Customer No." = NumCliente then
                exit(GetPDF_AbonoVenta(NumDocumento, PDFB64))
            else
                noEncontrado := true;

        exit(not noEncontrado);
    end;


    procedure GetPDF_FacturaVenta(NumFactura: Code[20]; var b64String: Text) Resultado: Boolean
    var
        SalesHeader: Record "Sales Invoice Header";
        k: Integer;
        IdiomaActual: Integer;
        //ReportPedido: Report Report50048;
        rSelectionReports: Record "Report Selections";
        outStr: OutStream;
        inStr: InStream;
        tmpBlob: Codeunit "Temp Blob";
        recordRf: RecordRef;
        dataTypeMgn: codeunit "Data Type Management";
        b64convert: Codeunit "Base64 Convert";
    begin
        /////////////////////////////////////////////////////////
        // CX_GetPDF_FacturaVenta()
        //----Parámetros----------------------------------------
        // NumFactura : CODE[20]; Nº de la factura a imprimir.
        // PDF : ARRAY[1000000] OF CHAR; Donde se va a almacenar el PDF para devolverlo.
        // TamañoPDF : Integer; Tamaño del fichero PDF generado.
        //----Descripción---------------------------------------
        // Imprime el report de la Aceptación de Retirada de Documentos en PDF y lo devuelve en un array de caracteres
        //----Autor---------------------------------------------
        // COAG-PNC;2009-09-02
        // PARA QUE FUNCIONE DEBEMOS TENER EL REPORT EN FORMATO ADAPTADO A ROLES
        /////////////////////////////////////////////////////////

        // Para depurar
        //MESSAGE('NumFactura: %1; Fecha: %2', NumFactura, Fecha);


        // Buscamos la factura
        //SalesInvHeader.SETRANGE("No.", NumFactura);
        //IF NOT SalesInvHeader.GET(NumFactura) THEN
        //IF NOT SalesInvHeader.GET('VF+0900072') THEN

        //ALBERTO. 21/09/2009. Modifico para que coja la factura que viene por parámetro y no la de prueba
        //SalesInvHeader.SETRANGE("No.", 'VF+0900072');
        SalesHeader.RESET();
        SalesHeader.SETRANGE(SalesHeader."No.", NumFactura);
        //FIN 21/09/2009

        IF NOT SalesHeader.FINDFIRST THEN BEGIN
            Resultado := FALSE;
            EXIT;
        END;

        // Generamos el PDF
        //Establecemos el idioma Castellano para que el report salga correctamente al llamar a esta funcion desde un
        //web service.


        tmpBlob.CreateOutStream(outStr);
        dataTypeMgn.GetRecordRef(SalesHeader, recordRf);
        GLOBALLANGUAGE(1034);  // 1034 = "Español - España (alfabetización tradicional)"
        SalesHeader.SETRECFILTER;
        rSelectionReports.RESET();
        rSelectionReports.SETRANGE(rSelectionReports.Usage, rSelectionReports.Usage::"S.Invoice");
        IF rSelectionReports.FINDFIRST() THEN
            //REPORT.SAVEASPDF(rSelectionReports."Report ID", FilePath, SalesHeader);
            report.SaveAs(rSelectionReports."Report ID", '', ReportFormat::Pdf, outStr, recordRf)
        else begin
            Resultado := false;
            exit;
        end;

        tmpBlob.CreateInStream(inStr);
        /*
        k := 0;
        repeat
            k += 1;
            instr.Read(PDF[k], 1);
        until inStr.EOS;
        TamanoPDF := k;
        */
        b64String := b64convert.ToBase64(inStr);
        Resultado := true;

        Resultado := true;
    end;

    procedure GetPDF_AbonoVenta(NumAbono: Code[20]; var b64String: Text) Resultado: Boolean
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        k: Integer;
        IdiomaActual: Integer;
        //ReportPedido: Report Report50048;
        rSelectionReports: Record "Report Selections";
        outStr: OutStream;
        inStr: InStream;
        tmpBlob: Codeunit "Temp Blob";
        recordRf: RecordRef;
        dataTypeMgn: codeunit "Data Type Management";
        b64convert: Codeunit "Base64 Convert";
    begin
        /////////////////////////////////////////////////////////
        // CX_GetPDF_FacturaVenta()
        //----Parámetros----------------------------------------
        // NumFactura : CODE[20]; Nº de la factura a imprimir.
        // PDF : ARRAY[1000000] OF CHAR; Donde se va a almacenar el PDF para devolverlo.
        // TamañoPDF : Integer; Tamaño del fichero PDF generado.
        //----Descripción---------------------------------------
        // Imprime el report de la Aceptación de Retirada de Documentos en PDF y lo devuelve en un array de caracteres
        //----Autor---------------------------------------------
        // COAG-PNC;2009-09-02
        // PARA QUE FUNCIONE DEBEMOS TENER EL REPORT EN FORMATO ADAPTADO A ROLES
        /////////////////////////////////////////////////////////

        // Para depurar
        //MESSAGE('NumFactura: %1; Fecha: %2', NumFactura, Fecha);


        // Buscamos la factura
        //SalesInvHeader.SETRANGE("No.", NumFactura);
        //IF NOT SalesInvHeader.GET(NumFactura) THEN
        //IF NOT SalesInvHeader.GET('VF+0900072') THEN

        //ALBERTO. 21/09/2009. Modifico para que coja la factura que viene por parámetro y no la de prueba
        //SalesInvHeader.SETRANGE("No.", 'VF+0900072');
        SalesCrMemoHeader.RESET();
        SalesCrMemoHeader.SETRANGE(SalesCrMemoHeader."No.", NumAbono);
        //FIN 21/09/2009

        IF NOT SalesCrMemoHeader.FINDFIRST THEN BEGIN
            Resultado := FALSE;
            EXIT;
        END;

        // Generamos el PDF
        //Establecemos el idioma Castellano para que el report salga correctamente al llamar a esta funcion desde un
        //web service.


        tmpBlob.CreateOutStream(outStr);
        dataTypeMgn.GetRecordRef(SalesCrMemoHeader, recordRf);
        GLOBALLANGUAGE(1034);  // 1034 = "Español - España (alfabetización tradicional)"
        SalesCrMemoHeader.SETRECFILTER;
        rSelectionReports.RESET();
        rSelectionReports.SETRANGE(rSelectionReports.Usage, rSelectionReports.Usage::"S.Cr.Memo");
        IF rSelectionReports.FINDFIRST() THEN
            //REPORT.SAVEASPDF(rSelectionReports."Report ID", FilePath, SalesHeader);
            report.SaveAs(rSelectionReports."Report ID", '', ReportFormat::Pdf, outStr, recordRf)
        else begin
            Resultado := false;
            exit;
        end;

        tmpBlob.CreateInStream(inStr);
        /*
        k := 0;
        repeat
            k += 1;
            instr.Read(PDF[k], 1);
        until inStr.EOS;
        TamanoPDF := k;
        */
        b64String := b64convert.ToBase64(inStr);
        Resultado := true;
    end;

    //FIN FACTURACIÓN PS

    //FUNCIONALIDAD PAGO PREESTABLECIDO CLIENTE
    procedure permitePagoPreestablecido(importePedido: Decimal; codClienteNAV: Code[20]): Boolean
    var
        rCustomer: Record Customer;
    begin
        rCustomer.Get(codClienteNAV);
        rCustomer.CalcFields("Balance (LCY)");
        IF rCustomer."Balance (LCY)" + importePedido > rCustomer."Credit Limit (LCY)" then
            exit(false);

        exit(true);
    end;

    procedure getCreditLimitCustomer(codClienteNAV: Code[20]): Decimal
    var
        rCustomer: Record Customer;
    begin
        rCustomer.get(codClienteNAV);
        exit(rCustomer."Credit Limit (LCY)");
    end;

    procedure getCustomerBalance(codClienteNAV: Code[20]): Decimal
    var
        rCustomer: Record Customer;
    begin
        rCustomer.get(codClienteNAV);
        rCustomer.CalcFields("Balance (LCY)");
        exit(rCustomer."Balance (LCY)");
    end;

    //FIN - FUNCIONALIDAD PAGO PREESTABLECIDO CLIENTE

    //PEPEBAR
    procedure insertarOperacionCamposPersonalizados(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                //buscamos si ya existe operación pendiente
                rOperacionesAsincronas.reset();
                rOperacionesAsincronas.setrange(Tipo, rOperacionesAsincronas.Tipo::"Campos personalizados");
                rOperacionesAsincronas.setrange(IdOrigen, format(rItem."No."));
                rOperacionesAsincronas.SetRange(Procesado, false);
                if not rOperacionesAsincronas.FindSet() then begin
                    rOperacionesAsincronas.INIT();
                    rOperacionesAsincronas.idAsync := 0;
                    rOperacionesAsincronas.IdOrigen := FORMAT(rItem."No.");
                    rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::"Campos personalizados";
                    rOperacionesAsincronas.IdDestino := rItem."No.";
                    rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                    rOperacionesAsincronas.INSERT(TRUE);
                end;
            END;
        END;
    end;

    procedure insertarOperacionMultiplesUnidades(codProducto: Code[20]; multiples: Integer; minOrderQty: Decimal)
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                //buscamos si ya existe operación pendiente
                rOperacionesAsincronas.reset();
                rOperacionesAsincronas.setrange(Tipo, rOperacionesAsincronas.Tipo::"Unidades multiples");
                rOperacionesAsincronas.setrange(IdOrigen, Format(rItem.IdPS));
                rOperacionesAsincronas.SetRange(Procesado, false);
                if not rOperacionesAsincronas.FindSet() then begin
                    rOperacionesAsincronas.INIT();
                    rOperacionesAsincronas.idAsync := 0;
                    rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPS);
                    rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::"Unidades multiples";
                    rOperacionesAsincronas.IdDestino := rItem."No.";
                    rOperacionesAsincronas.Texto := Format(multiples);
                    rOperacionesAsincronas.Cantidad := minOrderQty;
                    rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                    rOperacionesAsincronas.INSERT(TRUE);
                end;
            END;
        END;
    end;

    procedure insertarOperacionMultiplesUnidadesFaltan(codProducto: Code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                //buscamos si ya existe operación pendiente
                rOperacionesAsincronas.reset();
                rOperacionesAsincronas.setrange(Tipo, rOperacionesAsincronas.Tipo::"Unidades multiples");
                rOperacionesAsincronas.setrange(IdOrigen, Format(rItem.IdPS));
                //rOperacionesAsincronas.SetRange(Procesado, false);
                if not rOperacionesAsincronas.FindSet() then begin
                    rOperacionesAsincronas.INIT();
                    rOperacionesAsincronas.idAsync := 0;
                    rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPS);
                    rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::"Unidades multiples";
                    rOperacionesAsincronas.IdDestino := rItem."No.";
                    rOperacionesAsincronas.Texto := Format(rItem."Multiples unidades");
                    rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                    rOperacionesAsincronas.INSERT(TRUE);
                end;
            END;
        END;
    end;

    procedure getIDCampoAtributoCampoPersonalizado(campo: option "descVar1","descVar2","descVar3","descVar4"): Integer
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        case campo of
            campo::descVar1:
                exit(rSalesSetup."Id DescVar Pto 1");
            campo::descVar2:
                exit(rSalesSetup."Id DescVar Pto 2");
            campo::descVar3:
                exit(rSalesSetup."Id DescVar Pto 3");
            campo::descVar4:
                exit(rSalesSetup."Id DescVar Pto 4");
        end;
        exit(0);
    end;

    //FIN PEPEBAR
    //NUEVO ACTUALIZACIÓN ARBOL DE CATEGORIAS
    procedure insertarOperacionActCategoriasTree(CodCategoria: Code[20]; accion: text)
    var
        rAsync: Record "Modificaciones Asincronas PS";
        SalesSetup: Record "Sales & Receivables Setup";
        rItemCategory: Record "Item Category";
    begin
        //COMPROBAMOS QUE NO EXISTA UNA ACTUALIZACIÓN PENDIENTE PARA EL PRODUCTO ANTES DE INSERTAR UNA NUEVA
        //NGPC COMPROBAMOS QUE ESTÉ SINCRONIZADO CON PS
        rItemCategory.Get(CodCategoria);

        IF rItemCategory.IdPs = 0 THEN
            EXIT;

        SalesSetup.GET();
        IF SalesSetup."Sincronizar categorias" <> SalesSetup."Sincronizar categorias"::No THEN BEGIN
            rAsync.INIT();
            rAsync.idAsync := 0;
            rAsync.IdOrigen := rItemCategory.Code;
            rAsync.IdDestino := accion;
            rAsync.Tipo := rAsync.Tipo::"Update Categoria Tree";
            rAsync."Fecha/Hora" := CURRENTDATETIME();
            rAsync.INSERT(TRUE);
        END;
    end;

    procedure getCategoriasProducto(codProducto: Code[20]): Text
    var
        rCategories: Record "Item Category";
        rProductosCategorias: Record "Producto Categoria Relation";
        retorno: Text;
        rItem: Record Item;
        categoriaprincipal: Boolean;
    begin
        rItem.Get(codProducto);
        rProductosCategorias.Reset();
        rProductosCategorias.SetRange("Item No.", codProducto);
        if rProductosCategorias.FindSet() then
            repeat
                if rCategories.Get(rProductosCategorias."Categoria Code") then begin
                    retorno += Format(rCategories.IdPs) + '|';
                    if rItem."Item Category Code" = rProductosCategorias."Categoria Code" then
                        categoriaprincipal := true;
                end;
            until rProductosCategorias.Next() = 0;
        if (not categoriaprincipal) and (rItem."Item Category Code" <> '') then begin
            rCategories.get(rItem."Item Category Code");
            retorno += Format(rCategories.IdPs) + '|';
        end;

        if StrLen(retorno) > 0 then
            retorno := CopyStr(retorno, 1, StrLen(retorno) - 1);

        exit(retorno);
    end;

    //NUEVA FUNCION QUE NOS INDIQUE LA CATEGORÍA PRINCIPAL
    //que la coja del campo de la tabla de producto

    //error en el filtro al crear nuevos productos en los atributos ver log
    procedure getCategoriaPrincipalProducto(codProducto: Code[20]): Integer
    var
        rCategories: Record "Item Category";
        rItem: Record Item;
    begin
        if rItem.Get(codProducto) then begin
            if rCategories.Get(rItem."Item Category Code") then
                exit(rCategories.IdPs);
        end;
    end;

    procedure sincronizarMultiplesUnidadesTodosProductos()
    var
        rItem: Record Item;
        window: Dialog;
    begin
        window.OPEN(Text007);

        rItem.RESET();
        rItem.SETFILTER(rItem.IdPs, '>0');
        rItem.SETRANGE(rItem."Producto web", TRUE);
        //rItem.SetFilter("Multiples unidades", '>0');
        IF rItem.FINDFIRST() THEN
            REPEAT
                insertarOperacionMultiplesUnidades(rItem."No.", rItem."Multiples unidades", rItem."Minimum Order Quantity");
                window.UPDATE(1, rItem."No.");
            UNTIL rItem.NEXT = 0;
        window.CLOSE();
    end;

    procedure sincronizarMultiplesUnidadesTodosProductosFaltan()
    var
        rItem: Record Item;
        window: Dialog;
    begin
        window.OPEN(Text007);

        rItem.RESET();
        rItem.SETFILTER(rItem.IdPs, '>0');
        rItem.SETRANGE(rItem."Producto web", TRUE);
        //rItem.SetFilter("Multiples unidades", '>0');
        IF rItem.FINDFIRST() THEN
            REPEAT
                insertarOperacionMultiplesUnidadesFaltan(rItem."No.");
                window.UPDATE(1, rItem."No.");
            UNTIL rItem.NEXT = 0;
        window.CLOSE();
    end;

    //NUEVA FUNCIONALIDAD MENSAJES DE PEDIDO
    //MENSAJES DE PEDIDO PS COMO NOTAS EN EL PEDIDO DE VENTA BC
    procedure insertMensajePedido(codPedidoNAV: Code[20]; mensaje: Text; fecha: DateTime)
    var
        rPedido: Record "Sales Header";
        recordRf: RecordRef;
        rRecordLink: Record "Record Link";
        oStr: OutStream;
        rLinkMntg: Codeunit "Record Link Management";
    begin
        rPedido.get(rPedido."Document Type"::Order, codPedidoNAV);
        recordRf.GetTable(rPedido);

        rRecordLink.Init();
        rRecordLink."Record ID" := recordRf.RecordId;
        rRecordLink.Description := 'Mensajes PS';
        rRecordLink.Type := rRecordLink.Type::Note;
        //rRecordLink.Note.CreateOutStream(oStr, TextEncoding::Windows);
        //oStr.WriteText(mensaje, StrLen(mensaje));

        rRecordLink.Created := fecha;
        rRecordLink."User ID" := UserId;
        rRecordLink.Company := CompanyName;
        rRecordLink.Notify := true;
        rRecordLink."To User ID" := UserId;
        rRecordLink.Insert(true);

        rLinkMntg.WriteNote(rRecordLink, mensaje);
        rRecordLink.Modify();
    end;

    procedure getPreciosVentaProducto(codProducto: Code[20]; var responseJSON: Text)
    var
        rPriceListLine: Record "Price List Line";
        jsonArr: JsonArray;
        jsonObj: JsonObject;
        rItem: Record Item;
        unitPrice: Decimal;
        discount: Decimal;
        discountGr: Record "Customer Discount Group";
    begin
        rItem.Reset();
        rItem.SetRange("No.", codProducto);
        if rItem.FindSet() then;

        //B2C
        rPriceListLine.Reset();
        rPriceListLine.SetRange("Price Type", rPriceListLine."Price Type"::Sale);
        rPriceListLine.SetRange("Source Type", rPriceListLine."Source Type"::"All Customers");
        rPriceListLine.SetRange("Asset Type", rPriceListLine."Asset Type"::Item);
        rPriceListLine.SetRange("Asset No.", rItem."No.");
        rPriceListLine.SetRange(Status, rPriceListLine.Status::Active);
        rPriceListLine.SetFilter("Ending Date", '>=%1|%2', Today, 0D);
        if rPriceListLine.FindSet() then
            repeat
                unitPrice := 0;
                Clear(jsonObj);
                jsonObj.Add('idProducto', rItem.IdPS);
                jsonObj.Add('idCombinacion', rItem."Id Combinacion");
                jsonObj.Add('idGrupoCliente', 0);
                if (rPriceListLine."Unit Price" > 0) and (rPriceListLine."Line Discount %" > 0) then
                    unitPrice := rPriceListLine."Unit Price" * (1 - rPriceListLine."Line Discount %" / 100);
                if (rPriceListLine."Unit Price" > 0) and (rPriceListLine."Line Discount %" = 0) then
                    unitPrice := rPriceListLine."Unit Price";
                if (rPriceListLine."Unit Price" = 0) and (rPriceListLine."Line Discount %" > 0) then
                    discount := rPriceListLine."Line Discount %";

                jsonObj.Add('precio', unitPrice);
                jsonObj.Add('descuento', discount);
                jsonObj.Add('fromQuantity', rPriceListLine."Minimum Quantity");
                jsonObj.Add('fromDate', Format(rPriceListLine."Starting Date", 0, '<day,2>-<month,2>-<Year4>'));
                jsonObj.Add('toDate', Format(rPriceListLine."Ending Date", 0, '<day,2>-<month,2>-<Year4>'));
                jsonArr.Add(jsonObj);
            UNTIL rPriceListLine.Next() = 0;


        //B2B
        discountGr.Reset();
        discountGr.SetFilter("Id Group PS", '>0');
        if discountGr.FindSet() then
            repeat
                rPriceListLine.Reset();
                rPriceListLine.SetRange("Price Type", rPriceListLine."Price Type"::Sale);
                rPriceListLine.SetRange("Source Type", rPriceListLine."Source Type"::"Customer Disc. Group");
                rPriceListLine.SetRange("Source No.", discountGr.Code);
                rPriceListLine.SetRange("Asset Type", rPriceListLine."Asset Type"::Item);
                rPriceListLine.SetRange("Asset No.", rItem."No.");
                rPriceListLine.SetRange(Status, rPriceListLine.Status::Active);
                rPriceListLine.SetFilter("Ending Date", '>=%1|%2', Today, 0D);
                if rPriceListLine.FindSet() then
                    repeat
                        unitPrice := 0;
                        Clear(jsonObj);
                        jsonObj.Add('idProducto', rItem.IdPS);
                        jsonObj.Add('idCombinacion', rItem."Id Combinacion");
                        jsonObj.Add('idGrupoCliente', discountGr."Id Group PS");
                        if (rPriceListLine."Unit Price" > 0) and (rPriceListLine."Line Discount %" > 0) then
                            unitPrice := rPriceListLine."Unit Price" * (1 - rPriceListLine."Line Discount %" / 100);
                        if (rPriceListLine."Unit Price" > 0) and (rPriceListLine."Line Discount %" = 0) then
                            unitPrice := rPriceListLine."Unit Price";
                        if (rPriceListLine."Unit Price" = 0) and (rPriceListLine."Line Discount %" > 0) then
                            discount := rPriceListLine."Line Discount %";

                        jsonObj.Add('precio', unitPrice);
                        jsonObj.Add('descuento', discount);
                        jsonObj.Add('fromQuantity', rPriceListLine."Minimum Quantity");
                        jsonObj.Add('fromDate', Format(rPriceListLine."Starting Date", 0, '<day,2>-<month,2>-<Year4>'));
                        jsonObj.Add('toDate', Format(rPriceListLine."Ending Date", 0, '<day,2>-<month,2>-<Year4>'));
                        jsonArr.Add(jsonObj);
                    UNTIL rPriceListLine.Next() = 0;
            until discountGr.Next() = 0;

        jsonArr.WriteTo(responseJSON);
    end;

    procedure getManufacturersSinSincronizar(var responseJSON: Text)
    var
        rManufacturer: Record Manufacturer;
        jsonArr: JsonArray;
        jsonObj: JsonObject;
    begin
        rManufacturer.Reset();
        rManufacturer.SetRange("IdPS", 0);
        if rManufacturer.FindSet() then
            repeat
                Clear(jsonObj);
                jsonObj.Add('Code', rManufacturer.Code);
                jsonObj.Add('Name', rManufacturer.Name);
                jsonObj.Add('IdPS', rManufacturer."IdPS");
                jsonArr.Add(jsonObj);
            until rManufacturer.Next() = 0;
        jsonArr.WriteTo(responseJSON);
    end;

    procedure setIdPSManufacturers(jsonArray: Text)
    var
        rManufacturer: Record Manufacturer;
        jsonArr: JsonArray;
        jsonToken: JsonToken;
        jsonObj: JsonObject;
        jsonVal: JsonToken;
        codigo: Code[10];
        idPS: Integer;
    begin
        jsonArr.ReadFrom(jsonArray);
        foreach jsonToken in jsonArr do begin
            jsonObj := jsonToken.AsObject();

            jsonObj.Get('Code', jsonVal);
            codigo := CopyStr(jsonVal.AsValue().AsText(), 1, MaxStrLen(codigo));

            jsonObj.Get('IdPS', jsonVal);
            idPS := jsonVal.AsValue().AsInteger();
            if idPS > 0 then begin
                if rManufacturer.Get(codigo) then begin
                    rManufacturer."IdPS" := idPS;
                    rManufacturer.Modify();
                end;
            end;
        end;
    end;

    procedure getSincroFabricantes(): Boolean
    var
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        case rSalesSetup."Sincronizar fabricantes" of
            rSalesSetup."Sincronizar fabricantes"::Automatica, rSalesSetup."Sincronizar fabricantes"::Si:
                exit(true);
            else
                exit(false);
        end;
    end;

    procedure insertarOperacionActualizacionFabricante(codProducto: Code[20]; codFabricante: code[20])
    var
        rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
        rItem: Record Item;
        rManufacturer: Record Manufacturer;
    begin
        IF rItem.GET(codProducto) THEN BEGIN
            IF rItem."Producto web" THEN BEGIN
                if not rManufacturer.Get(codFabricante) then
                    exit;
                rOperacionesAsincronas.INIT();
                rOperacionesAsincronas.idAsync := 0;
                rOperacionesAsincronas.IdOrigen := FORMAT(rItem.IdPs);
                rOperacionesAsincronas.Tipo := rOperacionesAsincronas.Tipo::Fabricante;
                rOperacionesAsincronas.IdDestino := Format(rManufacturer.IdPS);
                rOperacionesAsincronas."Fecha/Hora" := CURRENTDATETIME();
                rOperacionesAsincronas.INSERT(TRUE);
            END;
        END;
    end;



}


