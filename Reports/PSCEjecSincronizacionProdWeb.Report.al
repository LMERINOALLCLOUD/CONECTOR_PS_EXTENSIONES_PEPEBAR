//7227677
report 60100 "Ejec. Sincronizacion Prod web"
{
    Caption = 'Ejecutar sincronización productos web';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;

    var
        rSalesSetup: Record "Sales & Receivables Setup";

    trigger OnPostReport()
    var
    begin
        rSalesSetup.Get();
        rSalesSetup.SincronizacionProductos := true;
        rSalesSetup.Modify();
    end;
}