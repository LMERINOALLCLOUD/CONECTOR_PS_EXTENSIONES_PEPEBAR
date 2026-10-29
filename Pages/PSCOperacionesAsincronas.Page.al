//7227678
page 60101 "OperacionesAsincronas"
{
    Caption = 'Operaciones Asincronas PS';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Modificaciones Asincronas PS";

    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field(idAsync; Rec.idAsync)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(IdOrigen; Rec.IdOrigen)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(IdDestino; Rec.IdDestino)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Tipo; Rec.Tipo)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Cantidad; Rec.Cantidad)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Texto; Rec.Texto)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Fecha/Hora"; Rec."Fecha/Hora")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Procesado; Rec.Procesado)
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Fecha/Hora proceso"; Rec."Fecha/Hora proceso")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Marcar sinc.productos")
            {
                ApplicationArea = all;
                CaptionML = ESP = 'Procesar operaciones asíncronas', ENU = 'Procesar operaciones asíncronas';
                Image = Reuse;

                trigger OnAction();
                var
                    rOperacionesAsincronas: Record "Modificaciones Asincronas PS";
                begin
                    IF CONFIRM('Esta acción procesará todas las operaciones pendientes ¿Desea continuar?') THEN BEGIN
                        rOperacionesAsincronas.Reset();
                        rOperacionesAsincronas.SetRange(Procesado, false);
                        if rOperacionesAsincronas.FindSet() then
                            rOperacionesAsincronas.ModifyAll(Procesado, true);
                    END;
                end;
            }
        }
    }
}