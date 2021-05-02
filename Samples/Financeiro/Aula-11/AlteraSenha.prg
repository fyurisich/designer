/*  SOBRE A IDE
    ==============================================================================================
    Gerado pela IDE Designer
    #Define VERSION_PRODUCT "00.99.20.084 RELEASE CANDIDATE (RC) 200924 0918"
    Vers�o Minigui:  Harbour MiniGUI Extended Edition 20.08 (Update 4)  Grigory Filatov <gfilatov@inbox.ru>
    Vers�o Harbour/xHarbour: Harbour 3.2.0dev (r2008190002)
    Compilador : MinGW GNU C 10.2 (32-bit)
    ----------------------------------------------------------------------------------------------
    SOBRE ESTE C�DIGO GERADO:
    �ltima altera��o : 28/09/2020-18:54:25 M�quina: IMA2018 Usu�rio:ivani
    C�digo do m�dulo Alterasenha
    ----------------------------------------------------------------------------------------------
    Projeto : Financeiro
    */

#include <hmg.ch>
#include <sistema.ch>
memvar hAcesso,rs,cn

Function LoadFrmAlterasenha
    Load window Alterasenha as Alterasenha
        Alterasenha.p_user.Enabled := .F.
        Alterasenha.p_User.Value := hAcesso["apelido"]
        Alterasenha.p_password.Setfocus()
        Alterasenha.Center()
    Alterasenha.activate()

    Return .T.

    ***********************************************
    ///////////////////////////////////////////////
    ***********************************************
Static Function AlteraSenha_Bt_Confirma_Action( )
    if empty(AlteraSenha.newPassword.value) 
        AlteraSenha.newPassword.Setfocus()
        Return Nil
    endif
    if AlteraSenha.newPassword.value <> AlteraSenha.ConfirmPassword.Value
        Msginfo("Senha de confirma��o � inv�lida ",SISTEMA)
        AlteraSenha.ConfirmPassword.Setfocus()
        Return Nil
    endif
    
    if Decripta(hAcesso["senha"]) <> AlteraSenha.p_password.Value
        MsgStop("Senha Inv�lida !",SISTEMA)
        AlteraSenha.p_password.Setfocus()
        Return Nil
    endif
    
    cn:Execute("Update acesso set senha='"+Encripta(AlteraSenha.NewPassword.value)+"' where id="+hb_ntos(hAcesso["coduser"])+";")
    if cn:nReg<=0
        MsgSTop("N�o foi possivel trocar a senha !",SISTEMA)
    endif
    AlteraSEnha.Release()
    Return .T.
