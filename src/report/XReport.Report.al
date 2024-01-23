report 50101 "XReport"
{
    ApplicationArea = All;
    Caption = 'XReport';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/report/rdl/XReport.rdl';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            RequestFilterFields = "No.";

            column(XLinesPerPage; XLinesPerPage) { }
            column(XTotalsLines; XTotalsLines) { }
            column(XLines; XLines) { }

            column(Company_Picture; CompanyInformation.Picture) { }
            column(Company_Name; CompanyInformation.Name) { }
            column(Company_Name_2; CompanyInformation."Name 2") { }
            column(Company_Address; CompanyInformation.Address) { }
            column(Company_Address_2; CompanyInformation."Address 2") { }
            column(Company_Post_Code; CompanyInformation."Post Code") { }
            column(Company_City; CompanyInformation.City) { }
            column(Company_Country; CompanyInformation.County) { }
            column(Company_Phone_No; CompanyInformation."Phone No.") { }
            column(Company_E_Mail; CompanyInformation."E-Mail") { }
            column(Company_Web; CompanyInformation."Home Page") { }
            column(Company_CIF; CompanyInformation."VAT Registration No.") { }

            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLinkReference = "Sales Header";
                DataItemLink = "Document No." = field("No."), "Sell-to Customer No." = field("Sell-to Customer No.");
                DataItemTableView = sorting("Document No.", "Line No.", "Bill-to Customer No.");

                column(No; "No.") { }
                trigger OnPreDataItem()
                begin
                    XLines := "Sales Line".Count;
                end;
            }

            dataitem(XAuxLines; Integer)
            {
                column(XBlanks; XBlanks) { }
                column(XBlank; Number) { }

                trigger OnPreDataItem()
                begin
                    XBlanks := XLinesPerPage - (XLines Mod XLinesPerPage);

                    if XBlanks < XTotalsLines then begin
                        XBlanks += XLinesPerPage;
                        XLines += XLinesPerPage;
                    end;

                    SetRange(Number, 1, XBlanks);
                end;
            }
        }

        dataitem(XSideBars; Integer)
        {
            column(XSideBar; Number) { }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, XLines div XLinesPerPage);
            end;
        }
    }

    trigger OnInitReport()
    begin
        CompanyInformation.SetAutoCalcFields(Picture);
        CompanyInformation.Get;

        XLinesPerPage := 26;
        XTotalsLines := 4;
    end;

    var
        XLinesPerPage: Integer;
        XTotalsLines: Integer;
        XLines: Integer;
        XBlanks: Integer;

        TempVatAmountLine: Record "VAT Amount Line" temporary;
        CompanyInformation: Record "Company Information";
        CompanyBankAccount: Record "Bank Account";
}
