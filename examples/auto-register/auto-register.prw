#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  AutoRegister()
| Autor: Eduardo Paranhos (baseado em conceito de Edmar Paranhos)
| Data:  10/08/2026
| Desc:  Cadastra automaticamente registros em tabelas auxiliares
|        durante processos padrao do Protheus
| Obs.:  Exemplo generico — tabelas e dados ficticios (tabela ZZ1)
*---------------------------------------------------------------------*/

User Function AutoRegister(cCode, cName)

    Local cAlias := Alias()
    Local lInserted := .F.

    Default cCode := ""
    Default cName := ""

    If Empty(cCode)
        Return .F.
    EndIf

    // ---------- Auto-cadastro em tabela customizada (ZZ1) ----------
    DbSelectArea("ZZ1")
    DbSetOrder(1) // ZZ1_FILIAL + ZZ1_CODIGO

    // Verifica se ja existe
    If !DbSeek(xFilial("ZZ1") + cCode)

        // Insere novo registro
        RecLock("ZZ1", .T.)

        ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
        ZZ1->ZZ1_CODIGO := cCode
        ZZ1->ZZ1_DESC   := Iif(!Empty(cName), cName, "Auto-cadastro " + DtoS(Date()))
        ZZ1->ZZ1_USER   := __cUserId
        ZZ1->ZZ1_DATA   := Date()

        MsUnLock()

        lInserted := .T.

        ConOut("[AutoRegister] Registro criado: " + cCode + " — " + cName)
    Else
        ConOut("[AutoRegister] Registro ja existe: " + cCode)
    EndIf

    // Restaura alias original
    DbSelectArea(cAlias)

Return lInserted
