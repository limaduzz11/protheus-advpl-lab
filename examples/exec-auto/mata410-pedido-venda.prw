#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  U_Mata410Auto()
| Autor: Eduardo Paranhos
| Data:  16/09/2026
| Desc:  Inclusao automatica de Pedido de Venda via MsExecAuto (MATA410)
|        com tratamento de erro robusto (lMsErroAuto / MostraErro)
| Obs.:  Padrao enterprise para integracao de faturamento / e-commerce
*---------------------------------------------------------------------*/

User Function Mata410Auto(cCliente, cLoja, cCondPag, aItensPed)

    Local aCabec       := {}
    Local aItens       := {}
    Local aLinha       := {}
    Local nI           := 0
    Local cDoc         := ""
    Local lOk          := .T.
    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.

    Default cCliente  := "000001"
    Default cLoja     := "01"
    Default cCondPag  := "001"
    Default aItensPed := {}

    ConOut("[Mata410Auto] Iniciando inclusao de pedido via ExecAuto...")

    // ---------- Cabecalho do Pedido (SC5) ----------
    AAdd(aCabec, {"C5_TIPO"   , "N"      , Nil})
    AAdd(aCabec, {"C5_CLIENTE", cCliente , Nil})
    AAdd(aCabec, {"C5_LOJACLI", cLoja    , Nil})
    AAdd(aCabec, {"C5_CONDPAG", cCondPag , Nil})
    AAdd(aCabec, {"C5_EMISSAO", Date()   , Nil})

    // ---------- Itens do Pedido (SC6) ----------
    If Len(aItensPed) == 0
        // Exemplo padrao se nenhum item for passado
        aLinha := {}
        AAdd(aLinha, {"C6_ITEM"   , "01"         , Nil})
        AAdd(aLinha, {"C6_PRODUTO", "PROD0001"   , Nil})
        AAdd(aLinha, {"C6_QTDVEN" , 2            , Nil})
        AAdd(aLinha, {"C6_PRCVEN" , 150.00       , Nil})
        AAdd(aLinha, {"C6_VALOR"  , 300.00       , Nil})
        AAdd(aLinha, {"C6_TES"    , "501"        , Nil})
        AAdd(aItens, aLinha)
    Else
        For nI := 1 To Len(aItensPed)
            aLinha := {}
            AAdd(aLinha, {"C6_ITEM"   , StrZero(nI, 2)           , Nil})
            AAdd(aLinha, {"C6_PRODUTO", aItensPed[nI][1]         , Nil})
            AAdd(aLinha, {"C6_QTDVEN" , aItensPed[nI][2]         , Nil})
            AAdd(aLinha, {"C6_PRCVEN" , aItensPed[nI][3]         , Nil})
            AAdd(aLinha, {"C6_VALOR"  , aItensPed[nI][2] * aItensPed[nI][3], Nil})
            AAdd(aLinha, {"C6_TES"    , aItensPed[nI][4]         , Nil})
            AAdd(aItens, aLinha)
        Next nI
    EndIf

    // ---------- Execucao do ExecAuto ----------
    Begin Transaction
        MSExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3)

        If lMsErroAuto
            DisarmTransaction()
            lOk := .F.
            ConOut("[Mata410Auto] ERRO na inclusao do pedido via ExecAuto!")
            MostraErro() // Exibe ou grava o log em arquivo dependendo do ambiente
        Else
            cDoc := SC5->C5_NUM
            ConOut("[Mata410Auto] SUCESSO: Pedido de venda " + cDoc + " gerado com sucesso!")
        EndIf
    End Transaction

Return lOk
