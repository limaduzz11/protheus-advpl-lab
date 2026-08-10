#include "Protheus.ch"
#include "TOTVS.ch"
#include "REPORT.ch"
#include "TBICONN.CH"

/*--------------------------------------------------------------------*
| Func:  FinancialReport()
| Autor: Eduardo Paranhos (baseado em conceito de Edmar Paranhos)
| Data:  10/08/2026
| Desc:  Relatorio financeiro com TReport — posicao por periodo e grupo
| Obs.:  Exemplo generico — dados e tabelas ficticios
*---------------------------------------------------------------------*/

User Function FinancialReport()

    Local oReport  := Nil
    Local oSection := Nil
    Local cPeriodo := ""
    Local cGroup   := ""

    // ---------- Interface de parametros ----------
    cPeriodo := Space(6)
    cGroup   := Space(2)

    // Define parametros via interface
    @ 01,01 Say "Periodo (AAAAMM):" Get cPeriodo Picture "@!" Valid !Empty(cPeriodo)
    @ 02,01 Say "Grupo..........:" Get cGroup   Picture "@!"
    Read

    If LastKey() == 27
        Return
    EndIf

    // ---------- Processamento ----------
    Processa({|| BuildReport(cPeriodo, cGroup) }, "Gerando relatorio...")

Return

/*--------------------------------------------------------------------*
| BuildReport — Constroi o relatorio TReport
*---------------------------------------------------------------------*/
Static Function BuildReport(cPeriodo, cGroup)

    Local oReport := TReport():New("FinancialReport", "Posicao Financeira", "RelatorioFinanceiro", {|oReport| PrintReport(oReport, cPeriodo, cGroup)})

    // Define secoes
    oReport:SetLandscape()
    oReport:SetTotalInHeader(.F.)

    // Secao de cabecalho
    TReportSection():New(oReport, "Cabecalho", {"Header"}, {|oSection| PrintHeader(oSection, cPeriodo, cGroup)})

    // Secao de detalhe
    TReportSection():New(oReport, "Detalhe", {"SE1"}, {|oSection| PrintDetail(oSection)})

    // Secao de rodape com totais
    TReportSection():New(oReport, "Totais", {}, {|oSection| PrintTotals(oSection)})

    oReport:PrintDialog()

Return

/*--------------------------------------------------------------------*
| PrintHeader — Cabecalho do relatorio
*---------------------------------------------------------------------*/
Static Function PrintHeader(oSection, cPeriodo, cGroup)

    Local oCell := nil

    oCell := TRCell():New(oSection, "Periodo: " + cPeriodo, "Principal", 1, 1, 1, 1, 600, 30)
    oCell := TRCell():New(oSection, "Grupo: " + cGroup, "Principal", 1, 2, 1, 1, 600, 30)

    // Linha de colunas
    oCell := TRCell():New(oSection, "Titulo", "Detalhe", 3, 1, 1, 1, 200, 30)
    oCell:SetText("Titulo")
    oCell := TRCell():New(oSection, "Vencimento", "Detalhe", 3, 2, 1, 1, 100, 30)
    oCell:SetText("Vencimento")
    oCell := TRCell():New(oSection, "Valor", "Detalhe", 3, 3, 1, 1, 150, 30)
    oCell:SetText("Valor R$")

Return

/*--------------------------------------------------------------------*
| PrintDetail — Detalhe dos titulos
*---------------------------------------------------------------------*/
Static Function PrintDetail(oSection)

    Local oCell := nil

    If SE1->E1_FILIAL == xFilial("SE1")
        oCell := TRCell():New(oSection, "Titulo", "Detalhe", oSection:nLine, 1, 1, 1, 200, 30)
        oCell:SetText(AllTrim(SE1->E1_NUM) + " — " + AllTrim(SE1->E1_NOMCLI))

        oCell := TRCell():New(oSection, "Vencimento", "Detalhe", oSection:nLine, 2, 1, 1, 100, 30)
        oCell:SetText(DtoC(SE1->E1_VENCREA))

        oCell := TRCell():New(oSection, "Valor", "Detalhe", oSection:nLine, 3, 1, 1, 150, 30)
        oCell:SetText(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))
        oCell:SetAlign(2) // Direita
    EndIf

Return

/*--------------------------------------------------------------------*
| PrintTotals — Rodape com totais
*---------------------------------------------------------------------*/
Static Function PrintTotals(oSection)

    Local oCell := nil
    Local nTotal := 0.0

    // Calcula total (exemplo — em producao, acumularia durante o loop)
    nTotal := SE1->E1_VALOR

    oCell := TRCell():New(oSection, "Total", "Detalhe", 1, 1, 1, 2, 300, 40)
    oCell:SetText("TOTAL GERAL")
    oCell:SetFontBold(.T.)

    oCell := TRCell():New(oSection, "ValorTotal", "Detalhe", 1, 3, 1, 1, 150, 40)
    oCell:SetText(Transform(nTotal, "@E 999,999,999.99"))
    oCell:SetAlign(2)
    oCell:SetFontBold(.T.)

Return
