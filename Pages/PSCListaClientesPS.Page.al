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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Contact; Rec.Contact)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
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
                field("Pendiente sincro B2B"; Rec."Pendiente sincro B2B")
                {
                    ApplicationArea = All;
                }
                field("Email PS"; Rec."Email PS")
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