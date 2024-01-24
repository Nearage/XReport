report 50101 "XReport"
{
    ApplicationArea = All;
    Caption = 'XReport';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/report/rdl/XReport.rdl';

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
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

            column(Order_No; "No.") { }
            column(Order_Date; "Order Date") { }
            column(Location_Code; "Location Code") { }
            column(Sell_to_Customer_No_; "Sell-to Customer No.") { }
            column(VAT_Registration_No_; "VAT Registration No.") { }
            column(Shipping_Agent_Code; "Shipping Agent Code") { }
            column(VATPct; VATPct) { }
            column(Payment_Terms_Code; "Payment Terms Code") { }

            column(Sell_to_Customer_Name; "Sell-to Customer Name") { }
            column(Sell_to_Address; "Sell-to Address") { }
            column(Sell_to_Address_2; "Sell-to Address 2") { }
            column(Sell_to_Post_Code; "Sell-to Post Code") { }
            column(Sell_to_City; "Sell-to City") { }
            column(Sell_to_Phone_No_; "Sell-to Phone No.") { }

            dataitem("Sales Shipment Line"; "Sales Shipment Line")
            {
                DataItemLinkReference = "Sales Shipment Header";
                DataItemLink = "Document No." = field("No."), "Sell-to Customer No." = field("Sell-to Customer No.");
                DataItemTableView = sorting("Document No.", "Line No.", "Bill-to Customer No.");

                column(Item_No; "No.") { }
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(Unit_Price; "Unit Price") { }
                column(Line_Discount__; "Line Discount %") { }
                column(Amount; Amount) { }
                column(VAT__; "VAT %") { }

                trigger OnPreDataItem()
                begin
                    XLines := "Sales Shipment Line".Count;
                end;

                trigger OnAfterGetRecord()
                begin
                    Amount := Quantity * "Unit Price";
                    SubTotal += Amount;

                    if "VAT %" > VATPct Then
                        VATPct := "VAT %";

                    VAT_Amount += Amount * ("VAT %" / 100);
                    Total += Amount + Amount * ("VAT %" / 100);
                end;
            }

            dataitem(XAuxLines; Integer)
            {
                column(XBlanks; XBlanks) { }
                column(XBlank; Number) { }
                column(SubTotal; SubTotal) { }
                column(VAT_Amount; VAT_Amount) { }
                column(Total; Total) { }

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

        Amount: Decimal;
        SubTotal: Decimal;
        VATPct: Decimal;
        VAT_Amount: Decimal;
        Total: Decimal;
}
