page 60113 PSCListaDireccionesEnvioPS
{
    Caption = 'Lista direcciones PS';
    PageType = List;
    UsageCategory = None;
    SourceTable = "Ship-to Address";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field(nombreContacto; nombreContacto)
                {
                    ApplicationArea = All;
                }
                field(apellidosContacto; apellidosContacto)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        nombreContacto: Text;
        apellidosContacto: Text;

    trigger OnAfterGetRecord()
    var
        rContact: Record Contact;
        rCustomer: Record Customer;
    begin
        if Rec.Contact <> '' then begin
            nombreContacto := Contact;
            apellidosContacto := 'No disponible';
        end else begin
            rCustomer.get(Rec."Customer No.");
            if rContact.Get(rCustomer."Primary Contact No.") then begin
                nombreContacto := rContact."First Name";
                if rContact."Middle Name" <> '' then
                    apellidosContacto := rContact."Middle Name" + ' ' + rContact.Surname
                else
                    apellidosContacto := 'No informado';
            end else begin
                nombreContacto := 'No informado';
                apellidosContacto := 'No informado';
            end;
        end;
    end;
}