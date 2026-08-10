#include "Protheus.ch"

/*--------------------------------------------------------------------*
| Func:  CostCenterBySeries()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Sugere centro de custo baseado na serie do documento (SF2)
|        Util para operacoes multi-filial onde cada serie tem CC proprio
| Obs.:  Exemplo generico — tabelas e dados ficticios
*---------------------------------------------------------------------*/

User Function CostCenterBySeries()

    Local cCostCenter := ""
    Local cSerie := ""

    // Verifica se esta na tabela de documentos de saida (SF2)
    If Select("SF2") > 0
        cSerie := AllTrim(SF2->F2_SERIE)

        // Define centro de custo por serie
        Do Case
        Case cSerie == "1"
            cCostCenter := "111001" // Centro de Custo — Matriz
        Case cSerie == "2"
            cCostCenter := "112001" // Centro de Custo — Filial Norte
        Case cSerie == "3"
            cCostCenter := "113001" // Centro de Custo — Filial Sul
        Case cSerie == "EC"
            cCostCenter := "114001" // Centro de Custo — E-commerce
        Otherwise
            cCostCenter := "110001" // Centro de Custo — Padrao
        EndCase

        ConOut("[CostCenterBySeries] Serie: " + cSerie + " => CC: " + cCostCenter)
    EndIf

Return cCostCenter
