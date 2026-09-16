#include "protheus.ch"
#include "topconn.ch"

/*--------------------------------------------------------------------*
| Func:  U_BatchUpdateTitulos()
| Autor: Eduardo Paranhos
| Data:  16/09/2026
| Desc:  Atualizacao em lote de titulos a receber vencidos (SE1)
|        utilizando TCQuery para leitura rapida e TCSQLExec com
|        Begin Transaction / DisarmTransaction para consistencia ACID.
| Obs.:  Padrao de alta performance para fechamento financeiro
*---------------------------------------------------------------------*/

User Function BatchUpdateTitulos(dDataCorte)

    Local cAlias      := GetNextAlias()
    Local cQuery      := ""
    Local cUpdateSQL  := ""
    Local nTotalLidos := 0
    Local nStatusSQL  := 0
    Local lSucesso    := .T.

    Default dDataCorte := Date()

    ConOut("[BatchUpdate] =========================================")
    ConOut("[BatchUpdate] Iniciando auditoria e atualizacao financeira")

    // Leitura via TCQuery com filtro rigoroso de filial e D_E_L_E_T_
    cQuery := "SELECT E1_NUM, E1_PREFIXO, E1_PARCELA, E1_SALDO, E1_VENCREA "
    cQuery += "  FROM " + RetSqlName("SE1") + " SE1 "
    cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
    cQuery += "   AND SE1.E1_SALDO > 0 "
    cQuery += "   AND SE1.E1_VENCREA < '" + DtoS(dDataCorte) + "' "
    cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)

    TCQuery cQuery New Alias (cAlias)

    While !(cAlias)->(Eof())
        nTotalLidos++
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

    ConOut("[BatchUpdate] Total de titulos identificados para atualizacao: " + cValToChar(nTotalLidos))

    If nTotalLidos == 0
        ConOut("[BatchUpdate] Nenhum titulo elegivel. Finalizando.")
        Return .T.
    EndIf

    // Execucao da atualizacao em bloco com transacao segura
    Begin Transaction

        cUpdateSQL := "UPDATE " + RetSqlName("SE1") + " "
        cUpdateSQL += "   SET E1_HIST = 'TITULO EM COBRANCA JUDICIAL - " + DtoS(Date()) + "' "
        cUpdateSQL += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
        cUpdateSQL += "   AND E1_SALDO > 0 "
        cUpdateSQL += "   AND E1_VENCREA < '" + DtoS(dDataCorte) + "' "
        cUpdateSQL += "   AND D_E_L_E_T_ = ' ' "

        nStatusSQL := TCSQLExec(cUpdateSQL)

        If nStatusSQL < 0
            ConOut("[BatchUpdate] ERRO ao executar TCSQLExec: " + TCSQLError())
            DisarmTransaction()
            lSucesso := .F.
        Else
            ConOut("[BatchUpdate] Atualizacao executada com sucesso via TCSQLExec!")
        EndIf

    End Transaction

    ConOut("[BatchUpdate] Processamento encerrado com status: " + Iif(lSucesso, "OK", "ERRO"))
    ConOut("[BatchUpdate] =========================================")

Return lSucesso
