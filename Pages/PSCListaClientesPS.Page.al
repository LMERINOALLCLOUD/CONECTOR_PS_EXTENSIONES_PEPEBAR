page 60112 PSCListaClientesPS
{
    Caption = 'Lista clientes PS';
    PageType = List;
    UsageCategory = None;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Contact; Contact)
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
                field("Mobile Phone No."; "Mobile Phone No.")
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
                field("VAT Registration No."; "VAT Registration No.")
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
                field("Pendiente sincro B2B"; "Pendiente sincro B2B")
                {
                    ApplicationArea = All;
                }
                field("Email PS"; "Email PS")
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
    begin
        if rContact.Get(Rec."Primary Contact No.") then begin
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

}