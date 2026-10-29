//7227677
pageextension 60100 P21CustomerCardExtension extends "Customer Card"
{
    layout
    {
        addafter(General)
        {
            group("PS Sincro")
            {
                CaptionML = ESP = 'PS Sincro', ENU = 'PS Sync';
                field("Pendiente sincro B2B"; Rec."Pendiente sincro B2B")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(IdClientePS; Rec.IdClientePS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(fechaAltaClientePS; Rec.fechaAltaClientePS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(EsClientePS; Rec.EsClientePS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Email PS"; Rec."Email PS")
                {
                    ApplicationArea = All;
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
                action(MarcarSincroPS)
                {
                    ApplicationArea = All;
                    Caption = 'Marcar sincronización PS';
                    Image = Registered;

                    trigger OnAction()
                    begin
                        if Confirm('Se marcará el cliente para su sincronización con PS.\¿Desea continuar?', true) then
                            Rec.Validate("Pendiente sincro B2B", true);
                    end;
                }
            }
        }
    }
}