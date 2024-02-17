report 50100 XReport
{
    ApplicationArea = All;
    Caption = 'XReport';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = 'src/report/layout/XReport.rdl';

    dataset
    {
        dataitem(Parent; Integer)
        {
            DataItemTableView = where(Number = const(1));

            column(Offset; "Report Header Lines") { }
            column(Range; "Lines Per Page") { }

            dataitem(Child; Integer)
            {
                DataItemTableView = where(Number = filter(1 .. 32));

                column(Child_No; Number) { }
            }

            dataitem(Blank; Integer)
            {
                column(Blank_No; Number) { }

                trigger OnPreDataItem()
                begin
                    SetBlankRange;
                end;
            }

            dataitem(Subtotal; Integer)
            {
                DataItemTableView = where(Number = filter(1 .. 2));

                column(Subtotal_No; Number) { }

                trigger OnPreDataItem()
                begin
                    if IsEmpty then CurrReport.Break;
                end;
            }

            dataitem(Total; Integer)
            {
                DataItemTableView = where(Number = filter(1 .. 4));

                column(Total_No; Number) { }

                trigger OnPreDataItem()
                begin
                    if IsEmpty then CurrReport.Break;
                end;
            }
        }

        dataitem(Aside; Integer)
        {
            column(Aside_No; Number) { }

            trigger OnPreDataItem()
            begin
                SetAsideRange;
            end;
        }
    }

    trigger OnInitReport()
    begin
        "Report Header Lines" := 4;
        "Lines Per Page" := 44;
    end;

    var
        "Lines Per Page": Integer;
        "Report Header Lines": Integer;

    local procedure CountLines(): Integer
    begin
        exit("Report Header Lines" + Child.Count + Subtotal.Count + Total.Count)
    end;

    local procedure CalcBlanks(): Integer
    begin
        exit(("Lines Per Page" - (CountLines mod "Lines Per Page")) mod "Lines Per Page");
    end;

    local procedure SetBlankRange()
    begin
        Blank.SetRange(Number, 1, CalcBlanks);

        if Blank.IsEmpty then CurrReport.Break;
    end;

    local procedure SetAsideRange()
    begin
        Aside.SetRange(Number, 1, (CountLines + CalcBlanks) div "Lines Per Page");
    end;
}