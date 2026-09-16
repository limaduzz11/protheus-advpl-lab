#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  AutoRegister()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Cadastra automaticamente registros em tabelas auxiliares
|        durante processos padrao do Protheus com controle transacional
| Obs.:  Exemplo generico para tabela customizada ZZ1
*---------------------------------------------------------------------*/

User Function AutoRegister(cCode, cName)

    Local aArea     := GetArea()
    Local aAreaZZ1  := ZZ1->(GetArea())
    Local lInserted := .F.

    Default cCode := ""
    Default cName := ""

    If Empty(cCode)
        Return .F.
    EndIf

    DbSelectArea("ZZ1")
    DbSetOrder(1) // ZZ1_FILIAL + ZZ1_CODIGO

    // Verifica se ja existe
    If !DbSeek(xFilial("ZZ1") + cCode)
        Begin Transaction
            RecLock("ZZ1", .T.)
            ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
            ZZ1->ZZ1_CODIGO := cCode
            ZZ1->ZZ1_DESC   := Iif(!Empty(cName), cName, "Auto-cadastro " + DtoS(Date()))
            ZZ1->ZZ1_USER   := __cUserId
            ZZ1->ZZ1_DATA   := Date()
            MsUnlock()
        End Transaction

        lInserted := .T.
        ConOut("[AutoRegister] Registro criado com sucesso: " + cCode + " — " + cName)
    Else
        ConOut("[AutoRegister] Registro ja existente no cadastro: " + cCode)
    EndIf

    RestArea(aAreaZZ1)
    RestArea(aArea)

Return lInserted
