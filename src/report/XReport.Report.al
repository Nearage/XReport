report 50101 "XReport"
{
    ApplicationArea = All;
    Caption = 'XReport';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/report/rdl/XReport.rdl';

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
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
            column(Bill_to_Customer_No_; "Bill-to Customer No.") { }
            column(VAT_Registration_No_; "VAT Registration No.") { }
            column(Shipping_Agent_Code; "Shipping Agent Code") { }
            column(VATPct; VATPct) { }
            column(Payment_Terms_Code; "Payment Terms Code") { }

            column(Bill_to_Name; "Bill-to Name") { }
            column(Bill_to_Address; "Bill-to Address") { }
            column(Bill_to_Address_2; "Bill-to Address 2") { }
            column(Bill_to_Post_Code; "Bill-to Post Code") { }
            column(Bill_to_City; "Bill-to City") { }
            column(BillToPhoneNo; BillToPhoneNo) { }

            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemLinkReference = "Sales Invoice Header";
                DataItemLink = "Document No." = field("No."), "Bill-to Customer No." = field("Bill-to Customer No.");
                DataItemTableView = sorting("Document No.", "Line No.", "Bill-to Customer No.");

                column(Item_No; "No.") { }
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(Unit_Price; "Unit Price") { }
                column(Line_Discount__; "Line Discount %") { }
                column(Amount; Amount) { }
                column(VAT__; "VAT %") { }

                trigger OnPreDataItem()
                var
                    Customer: Record Customer;
                begin
                    XLines := "Sales Invoice Header".Count;

                    if Customer.Get("Sales Invoice Header"."Bill-to Customer No.") then
                        BillToPhoneNo := Customer."Phone No.";
                end;

                trigger OnAfterGetRecord()
                begin
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

        SubTotal: Decimal;
        VATPct: Decimal;
        VAT_Amount: Decimal;
        Total: Decimal;
        BillToPhoneNo: Text[30];
}
