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
            RequestFilterFields = "No.", "Sell-to Customer No.";

            column(XLinesPerPage; XLinesPerPage) { }
            column(XTotalsLines; XTotalsLines) { }
            column(XLines; XLines) { }

            column(No_; "No.") { IncludeCaption = true; }

            dataitem("Sales Invoice Line"; "Sales Line")
            {
                DataItemLinkReference = "Sales Header";
                DataItemLink = "Document No." = field("No."), "Bill-to Customer No." = field("Bill-to Customer No.");
                DataItemTableView = sorting("Document No.", "Line No.", "Bill-to Customer No.");

                column(No; "No.") { }
                trigger OnPreDataItem()
                begin
                    XLines := "Sales Invoice Line".Count;
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
        XLinesPerPage := 26;
        XTotalsLines := 4;
    end;

    var
        XPage: Integer;
        XLinesPerPage: Integer;
        XTotalsLines: Integer;
        XLines: Integer;
        XLine: Integer;
        XBlanks: Integer;
}
