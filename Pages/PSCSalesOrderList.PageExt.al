//7227683
pageextension 60106 P9305_SalesOrderListExtension extends "Sales Order List"
{
    layout
    {
        addafter("Campaign No.")
        {
            field(EsPedidoPS; EsPedidoPS)
            {
                ApplicationArea = All;
                StyleExpr = StyleText;
            }
            field(IdPedidoPS; IdPedidoPS)
            {
                ApplicationArea = All;
                StyleExpr = StyleText;
            }
            field("Estado Pedido PS"; "Estado Pedido PS")
            {
                ApplicationArea = All;
                StyleExpr = StyleText;
            }
            field("Desc. Estado Pedido PS"; "Desc. Estado Pedido PS")
            {
                ApplicationArea = All;
                StyleExpr = StyleText;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        StyleText := CUPS.getStyleTextOrderStatus("Estado Pedido PS");
    end;

    var
        StyleText: Text;
        CUPS: codeunit PSSincro;
}