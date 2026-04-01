//7227680
report 60103 "Resincronizar pedidoPS"
{
    Caption = 'Resincronización de pedidos PS';
    UsageCategory = None;
    ProcessingOnly = true;
    UseRequestPage = true;


    requestpage
    {
        SaveValues = false;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Opciones';
                    field(idPedidoSincronizar; idPedidoSincronizar)
                    {
                        ApplicationArea = All;
                        Caption = 'Id Pedido PS';
                    }
                }
            }
        }
    }

    var
        idPedidoSincronizar: Integer;

    trigger OnPostReport()
    var
        cups: Codeunit PSSincro;
        rPedido: Record "Sales Header";
        rSalesSetup: Record "Sales & Receivables Setup";
    begin
        rSalesSetup.Get();
        if idPedidoSincronizar > 0 then begin
            rPedido.Reset();
            rPedido.SetRange(IdPedidoPS, idPedidoSincronizar);
            if not rPedido.FindSet() then begin
                if rSalesSetup."Id pedido PS ultimo" >= idPedidoSincronizar then
                    cups.insertarOperacionResincronizarPedido(idPedidoSincronizar)
                else
                    Error('El id pedido a sincronizar no puede ser mayor al último id pedido sincronizado');
            end else
                Error('No se puede resincronizar el pedido. Elimine el pedido asociado antes de resincronizar el pedido con IdPS = ' + Format(idPedidoSincronizar));
        end;
    end;

}