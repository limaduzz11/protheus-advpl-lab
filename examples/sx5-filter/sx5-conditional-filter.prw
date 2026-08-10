#include "Protheus.ch"

/*--------------------------------------------------------------------*
| Func:  SX5ConditionalFilter()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Filtra opcoes da tabela SX5 com base em condicoes de negocio
|        Exemplo: mostrar series especificas por estado (UF)
| Obs.:  Exemplo generico — dados ficticios
*---------------------------------------------------------------------*/

User Function SX5ConditionalFilter()

    Local lShow := .T. // Por padrao, mostra a opcao
    Local cState := AllTrim(SuperGetMV("MV_ESTADO", .F., ""))
    Local cTable := ""
    Local cKey := ""

    // Identifica a tabela SX5 sendo consultada
    If Select("SX5") > 0
        cTable := AllTrim(SX5->X5_TABELA)
        cKey   := AllTrim(SX5->X5_CHAVE)
    EndIf

    // ---------- Exemplo 1: Filtrar series de nota fiscal por estado ----------
    If cTable == "F2" .And. cKey != Nil

        Do Case
        // Estado RJ — mostrar series 1, 2 e RPS
        Case cState == "RJ"
            If !(cKey $ "1/2/RPS")
                lShow := .F.
            EndIf

        // Estado SP — mostrar series 1, 3, 55
        Case cState == "SP"
            If !(cKey $ "1/3/55")
                lShow := .F.
            EndIf

        // Estado ES — mostrar series 1, 2
        Case cState == "ES"
            If !(cKey $ "1/2")
                lShow := .F.
            EndIf
        EndCase
    EndIf

    // ---------- Exemplo 2: Filtrar tipos de saida por modulo ----------
    If cTable == "D2" .And. cKey != Nil

        // Esconde tipos de saida especificos para filiais de servico
        If AllTrim(SuperGetMV("MV_FILSV", .F., "")) == "S"
            If cKey $ "BON/DESC/BRINDE"
                lShow := .F.
            EndIf
        EndIf
    EndIf

Return lShow
