//7227677
page 60100 "ProductosPS"
{
    Caption = 'Productos PS';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Item;

    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(general)
            {
                Editable = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("No. 2"; "No. 2")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field(IdPS; IdPS)
                {
                    ApplicationArea = All;
                }
                field("Producto web"; "Producto web")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Descripcion larga PS"; "Descripcion larga PS")
                {
                    ApplicationArea = All;
                }
                field("Descripcion web corta"; descripcionCorta)
                {
                    ApplicationArea = All;
                }
                field("Descripcion web larga"; descripcionLarga)
                {
                    ApplicationArea = All;
                }
                field("DescVar Prod Pto 1"; varDescPto1)
                {
                    ApplicationArea = All;
                }
                field("DescVar Prod Pto 2"; varDescPto2)
                {
                    ApplicationArea = All;
                }
                field("DescVar Prod Pto 3"; varDescPto3)
                {
                    ApplicationArea = All;
                }
                field("DescVar Prod Pto 4"; varDescPto4)
                {
                    ApplicationArea = All;
                }
                field("Multiples unidades"; "Multiples unidades")
                {
                    ApplicationArea = All;
                }
                field(Combinacion; Combinacion)
                {
                    ApplicationArea = All;
                }
                field("Id Combinacion"; "Id Combinacion")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {

    }

    trigger OnAfterGetRecord()
    var
        rDescripcionesVarias: Record "Descripciones Varias";
        instr: InStream;
    begin
        descripcionCorta := '';
        descripcionLarga := '';
        varDescPto1 := '';
        varDescPto2 := '';
        varDescPto3 := '';
        varDescPto4 := '';
        rDescripcionesVarias.Reset();
        rDescripcionesVarias.SetRange(Codigo, Rec."No.");
        if rDescripcionesVarias.FindSet() then
            repeat
                rDescripcionesVarias.CalcFields("Blob Descripcion");
                if rDescripcionesVarias."Blob Descripcion".HasValue() then begin
                    Clear(instr);
                    rDescripcionesVarias."Blob Descripcion".CreateInStream(instr, TextEncoding::UTF8);
                    case rDescripcionesVarias."Tipo Descripcion" of
                        rDescripcionesVarias."Tipo Descripcion"::"Prod Desc Corta":
                            instr.Read(descripcionCorta);
                        rDescripcionesVarias."Tipo Descripcion"::"Prod Desc Larga":
                            instr.Read(descripcionLarga);
                        rDescripcionesVarias."Tipo Descripcion"::"Prod Pto 1":
                            instr.Read(varDescPto1);
                        rDescripcionesVarias."Tipo Descripcion"::"Prod Pto 2":
                            instr.Read(varDescPto2);
                        rDescripcionesVarias."Tipo Descripcion"::"Prod Pto 3":
                            instr.Read(varDescPto3);
                        rDescripcionesVarias."Tipo Descripcion"::"Prod Pto 4":
                            instr.Read(varDescPto4);
                    end;
                end;

            until rDescripcionesVarias.Next() = 0;
    end;

    var
        descripcionLarga: Text;
        descripcionCorta: Text;
        varDescPto1: Text;
        varDescPto2: Text;
        varDescPto3: Text;
        varDescPto4: Text;
}