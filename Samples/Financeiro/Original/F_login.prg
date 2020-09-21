/*
* Controle Financeiro - Pequeno Exemplo
* Humberto Fornazier - Maio/2003
* hfornazier@brfree.com.br
* www.geocities.com/harbourminas
*
* Harbour Compiler (MiniGUI Distribution) 2003.05.03 (Flex)
* Copyright 1999-2003, http://www.harbour-project.org/
*
* Harbour MiniGUI R.62a Copyright 2002-2003 Roberto Lopez,
* MINIGUI - Harbour Win32 GUI library - Release 62a - 23/05/2003
* Copyright 2002 Roberto Lopez <roblez@ciudad.com.ar>
* http://www.geocities.com/harbourminigui/
*
* Algumas das telas do sistema foram contru�das com auxilio do
* GUIDES - Release 0.12 for MiniGUI
* Carlos Andres - carlos.andres@navegalia.com
* http://www.geocities.com/harbour_links
*
* Este exemplo � uma contribui��o ao Projeto Harbour/MiniGUI  e pode ser modificado e distribu�do livremente.
*
* Importante	: Este sistema foi desenvolvido com intens�o de auxiliar usu�rios
*	 	  que utilizem o Harbour e o MiniGUI.   � um projeto apenas para			
*		  estudo dos comandos.   N�o deve ser utilizado comercialmente 
*		  por estar sujeito a apresentar possiveis erros n�o detectados em
*		  testes feitos pelo autor. 
*/
#include "minigui.ch"
#Include "F_Sistema.ch"
/*
*/
Function AcessoAoSistema()          
              Local cUser           := ""
              Local cPassWord  := ""        

	*** Abre Aquivo Acesso.DBF
	AcessoOpen(.F.)

	*** Caso exista apenas UM Usu�rio cadastrado no Arquivo Acesso.dbf
	If Acesso->(LastRec()) == 1 	

		*** Caso o Unico Usu�rio cadastrado seja o Usu�rio Padr�o, Mostra uma mensagem para o usu�rio.
		If AllTrim(Acesso->APELIDO) == "USUARIO" .And. Decripta( Acesso->Senha ) == "SENHA"

			**** Muda Status do Label Mensagens (F_MENU.PRG) para Visivel
			Form_0.Label_Mensagens.Visible := .T.	
			
			**** Coloca a Mensagem no Valor do Label			 
			Form_0.Label_Mensagens.value := "Se voc� ainda n�o cadastrou nenhum usu�rio,  Digite:  USUARIO no campo  USUARIO   e   SENHA no campo  SENHA"

		EndIf

	EndIf

	*** Define Janela do Login Principal ao Sistema
	DEFINE WINDOW Form_acesso ;
		AT 0,0 ;
		WIDTH 280 HEIGHT 160 ;
		TITLE 'Acesso ao Sistema'   MODAL NOSYSMENU BACKCOLOR BLUE                                                          

		@010,030 LABEL Label_User                 ;
			 VALUE "Usu�rio          "          ;
			 WIDTH 120		    ;
			 HEIGHT 35		    ;
			 FONT "Arial" SIZE 09;
                                           BACKCOLOR BLUE ;
                                           FONTCOLOR WHITE BOLD

	 	 @045,030 LABEL Label_Password	;
			   VALUE "Senha       "	;
			   WIDTH 120		;
			   HEIGHT 35		;
			   FONT "Arial" SIZE 09	;
                                             BACKCOLOR BLUE 	;
                                             FONTCOLOR WHITE BOLD	

                             @013,120 TEXTBOX  p_User	;
                                            HEIGHT 25		;                           
                                            VALUE cUser		;                       
                                            WIDTH 120		;                           
                                            FONT "Arial" SIZE 09	;              
			  MAXLENGTH 10		;	
			  UPPERCASE		;	               
			  ON ENTER Iif( ! Empty( Form_acesso.p_User.Value ) , Form_acesso.p_Password.SetFocus , Form_acesso.p_User.SetFocus  )
									
                             @048,120 TEXTBOX  p_password	;
                                            VALUE cPassWord	;          
                                            PASSWORD		;                         
                                            FONT "Arial" SIZE 09	;             
                                            TOOLTIP "Senha de Acesso";
			  MAXLENGTH 05		;
			  UPPERCASE		;
			  ON ENTER  Iif( ! Empty( Form_acesso.p_password.Value ) ,  Form_acesso.Bt_Login.SetFocus , Form_acesso.p_password.SetFocus )

                             @ 090,030 BUTTON Bt_Login                 ;
                                            CAPTION '&Login'                  ;
                                            ACTION Verifica_Login()   ;
                                            FONT "MS Sans Serif" SIZE 09 FLAT

                             @ 090,143 BUTTON Bt_Logoff                   ;
                                             CAPTION '&Cancela'                 ;
                                             ACTION Form_0.Release           ;
                                            FONT "MS Sans Serif" SIZE 09 FLAT

	END WINDOW

	*** Coloca o Cursor no TEXTBOX p_user
	Form_acesso.p_User.SetFocus

	*** Centraliza janela
	CENTER WINDOW Form_acesso

	*** Ativa janela de Login
	ACTIVATE WINDOW Form_acesso

/*

	cUser		:= Pega o Valor digitado no TextBox p_User
	cPass		:= Pega o Valor digitado no TextBox p_Password
	aStatusDoUsuario	:= {} Array

*/
Function Verifica_Login()
	Local cUser	:= AllTrim(  Form_acesso.p_User.Value        )
	Local cPass	:= AllTrim(  Form_acesso.p_password.Value )
              Local aStatusDoUsuario := {}	

	*** Se o TextBox p_User n�o foi informado
	If Empty( cUser )
		MsgINFO("Usu�rio n�o informado!!",SISTEMA)
		Form_acesso.p_user.SetFocus
		Return Nil
	EndIf   

	*** Posiciona o Arquivo Accesso no Indice 2 - Indexado por Apelido
	Acesso->(DBSetOrder(2))

	*** Se o Apelido digitado em TextBox p_User for encontrado
	If Acesso->(DBSeek( cUser ))	

		*** Decriptografa a Senha do usu�rio armazenada no arquivo e compara com a senha digitada		
		If Decripta( Acesso->Senha ) != cPass

			*** Se for diferente, envia mensagem e posiciona o cursor no campos p_password
			MsgInfo("Senha de acesso Inv�lida!!",SISTEMA)
			Form_acesso. p_password .SetFocus
			Return Nil

		EndIf

		** Se a senha for v�lida,  efetua o release da janela de Login
		Release Form_acesso    

	Else

		** Se o usu�rio/Apelido n�o existir, emite mensagem e posiciona o cursor em p_User
		MsgInfo("Usu�rio: "+cUser+" n�o Cadastrado!!",SISTEMA)
		Form_acesso.p_User.SetFocus
		Return Nil

	EndIf

	*** A fun��o Status do usu�rio coloca em uma Array as configura��es do usu�rio ( neste caso a array aStstusDoUsuario )
              aStatusDoUsuario := StatusDoUsuario( Acesso->Codigo ) && Status do Usu�rio Atual

	*** A Fun��o StatusDoUSuario est� em ( F_USUARIOS.PRG )
	*** Obs: a Array cont�m as configura��es na seguintre ordem
	*** 1� Posic�o: N�ivel do usu�rio: 0 �  9 - Somente os usu�rios de n�ve 0 podem acessar o cadastro de USUARIOS
	*** 2� Posi��o : Inclus�es  no Sistema		.T. ou .F.	 
	*** 3� Posi��o : Altera��es no Sistema	.T. ou .F.	 
	*** 4� Posi��o : Exclus�oes no Sistema	.T. ou .F.	 
	*** 5� Posi��o : Emiss�o de relat�rios		.T. ou .F.	 
	*** 6� Posi��o : Usu�rio Ativo ou Inativo	.T. ou .F.	 
	*** 7� Posi��o : Data de Validade da Senha       Cari�vel tipo Date	 

	*** Se Usu�rio estiver Inativo, envia mensagem para o usu�rio, limpa os campos do formulario  e posiicona o cursor em p_User 
              If aStatusDoUsuario[ 6 ]   
                 MsgInfo( "Usu�rio est� Inativo.. Imposs�vel Continuar!!" , SISTEMA )
                 Form_acesso.p_user.Value := ""
                 Form_acesso.p_password .Value := ""
                 Form_acesso.p_user .SetFocus                
	   Return Nil
              EndIf  

	*** Muda o Status do Menu Usu�rios para Habilitado
	MODIFY CONTROL Mn_Usuarios OF Form_0 ENABLED .T.

              if aStatusDoUsuario[ 1 ] != "0"    && Somente usu�rios de N�vel "0" (Zero) Podem acessar cadastro de Usu�rios

		*** Se usu�rio atual n�o tem Nivel 0 (Zero) Desabilita o menu Usu�rios
		MODIFY CONTROL Mn_Usuarios OF Form_0 ENABLED .F.	

		*** Se a data de validade � menor que a Data atual do sistema,  envia mensagem para o usu�rio, limpa os campos do formulario  e posiicona o cursor em p_User 
	              If aStatusDoUsuario[ 7 ] < Date() 
		                 MsgInfo( "Senha do Usu�rio est� Vencida!!. Imposs�vel Continuar!!" , SISTEMA )
		                 Form_acesso.p_user.Value := ""
		                 Form_acesso.p_password .Value := ""
		                 Form_acesso.p_user .SetFocus                
			   Return Nil
		EndIf 

	EndIf 

	*** Efetua Release no formulario de Login
              Form_acesso.Release

	*** Muda Status da linha de mensagens para Invisivel	
	Form_0.Label_Mensagens.Visible := .F.	
          
          	*** Coloca o Apelido do usu�rio atual na linha de Status do Menu
	Form_0.StatusBar.Item(3) := Acesso->Apelido

	*** Cria uma janela para mostrar ao usu�rio seuas configura��es atuais
	DEFINE WINDOW Form_Status ;
		AT 0,0 ;
		WIDTH 280 HEIGHT 205 ;
		TITLE "Status do Usu�rio: "+Acesso->Apelido;
                            ICON 'ICONE01';
                            MODAL NOSIZE BACKCOLOR BLUE           

		@010,065 LABEL CONTROL_1	; 
			VALUE "N�vel do Usu�rio"	;
			WIDTH 150		; 
			HEIGHT 15		; 
		              FONT 'ARIAL'  SIZE 9	;
		              BACKCOLOR BLUE	;
		              FONTCOLOR WHITE BOLD

		@010,160 LABEL CONTROL_1a	; 
			VALUE ': ' +aStatusDoUsuario[ 1 ]; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	        
     
		@030,065 LABEL CONTROL_2	; 
			VALUE "Inclus�es"	; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD

		@030,160 LABEL CONTROL_2a	; 
			VALUE ": "+ Iif( aStatusDoUsuario[2] , "SIM" , "N�O")  ; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	        

		@050,065 LABEL CONTROL_3	; 
			VALUE 'Altera��es'	; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	        

		@050,160 LABEL CONTROL_3a	; 
			VALUE ": "+Iif( aStatusDoUsuario[3] , "SIM" , "N�O")  ; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	        

		@070,065 LABEL CONTROL_4	; 
			VALUE 'Exclus�es'	; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	        

		@070,160 LABEL CONTROL_4a	; 
			VALUE ': '+Iif( aStatusDoUsuario[4] , "SIM" , "N�O")  ; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	        

		@090,065 LABEL CONTROL_5	; 
			VALUE 'Relat�rios'		; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	; 
			FONTCOLOR WHITE BOLD	   

		@090,160 LABEL CONTROL_5a	; 
			VALUE ': '+Iif( aStatusDoUsuario[5] , "SIM" , "N�O")  ; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	 

		@110,65 LABEL CONTROL_6	; 
			VALUE 'Senha Vence em'	; 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	   

		@110,160 LABEL CONTROL_6a	; 
			VALUE ': '+DtoC( aStatusDoUsuario[7] ); 
			WIDTH 150 HEIGHT 15	; 
			FONT 'ARIAL'  SIZE 9	;
			BACKCOLOR BLUE	;
			FONTCOLOR WHITE BOLD	   

		@145,095 BUTTON Bt_Fechar	;
			CAPTION '&Fechar'	;
			ACTION Form_Status.Release;
			FONT "MS Sans Serif" SIZE 09 FLAT
	
	END WINDOW

	*** Coloca o Focus no Bot�o Fechar
              Form_Status.Bt_Fechar.SetFocus                

	*** Centraliza Janela
	CENTER WINDOW Form_Status

	*** Ativa Janela
	ACTIVATE WINDOW Form_Status
	Return Nil

/* 
	Select( AREA )	 = retorna 0 se a �rea passada como par�metro N�O estiver em uso
	BasedeDados()	 = Func�o que retorna local da base de Dados do Sistema / L� o arquivo FINANC.INI / Fun��o est� em F_FUNCOES.PRG
	ArqbBase	 = Concatena a variavel cBase + o Arquivo que ser� aberto
	aarq		 = Array para criar estrutura do arquivo
*/
FUNCTION AcessoOpen()
  	   Local nArea	:= Select( 'ACESSO' )	
	   Local cBase	:= BaseDeDados()
	   Local ArqBase	:= cBase+"ACESSO.DBF"
	   Local aarq := {}	

	   *** Se a �rea n�o estiver em uso
	   If nArea == 0	     

		** Se N�o existir o arquivo	
		If ! FILE( ArqBase )			

			** Se n�o for o Servidor de Dados houve erro no acesso de Rede
			If ServidorDeDados() != "SIM"
				MsgBox("Aquivo de Usu�rios n�o Localizado em "+AllTrim(cBase),SISTEMA)
				Release Window ALL
			EndIf
			
			*** Adciona na Array a estrutura do arquivo ACESSO.DBF que ser�  criado
			Aadd( aarq , { 'CODIGO'	, 'C' , 04 , 0 } )
			Aadd( aarq , { 'USUARIO'	, 'C' , 30 , 0 } )
			Aadd( aarq , { 'APELIDO'	, 'C' , 10 , 0 } )
			Aadd( aarq , { 'SENHA'	, 'C' , 05 , 0 } )
			Aadd( aarq , { 'ACESSO'	, 'C' ,250 , 0 } )
			Aadd( aarq , { 'STATUS'	, 'C' ,20  , 0 } )		                    

			*** Cria o Arquivo
			DBCreate     (  (ArqBase)   , aarq )

			*** Abre o arquivo Acesso.DBF na pr�xima �rea dispon�vel em modo de compartilhamento
			USE (ArqBase) Alias ACESSO NEW SHARED 

			*** Quando o arquivo � criado, cria-se tamb�m um usu�rio Padr�o
			ACESSO->(DBappend())
			ACESSO->CODIGO  := '0001'
			ACESSO->USUARIO := 'USUARIO'
			ACESSO->APELIDO := 'USUARIO'
			ACESSO->SENHA   := Encripta( 'SENHA' )
			ACESSO->STATUS  := Encripta( '011110'+DtoC( Date( )+90) )
		
			** Fecha Arquivo
			ACESSO->(DBCloseArea())

			*** Func�o Encripta est� no PRG F_Funcoes.Prg
			*** STATUS =  S�o seis posi�oes que podem ser 0 (Zero)  ou  1 (UM) - exceto a primeira que pode ir at� 09 (NOVE)
			*** 1� Posic�o: N�ivel do usu�rio: 0 �  9 - Somente os usu�rios de n�ve 0 podem acessar o cadastro de USUARIOS
			*** 2� Posi��o : Inclus�es  no Sistema		1 = SIM   0 = N�O.
			*** 3� Posi��o : Altera��es no Sistema	1 = SIM   0 = N�O
			*** 4� Posi��o : Exclus�oes no Sistema	1 = SIM   0 = N�O
			*** 5� Posi��o : Emiss�o de relat�rios		1 = SIM   0 = N�O
			*** 6� Posi��o : Usu�rio Ativo ou Inativo	1 = SIM   0 = N�O			 
			*** 7� Posi��o : Data de Validade da Senha       90 Dias ap�s a cria��o		

		Endif	         

		** Abre Arquivo Acesso.DBF na pr�xima �rea dispon�vel em modo de compartilhamento
		Use (ArqBase) Alias ACESSO New Shared                  

		*** Se n�o existir o Arquivo Acesso1.NTX, cria.
		If ! File( cBase+'ACESSO1.NTX' )
			Index ON CODIGO To (cBase)+"Acesso1"
		EndIf

		*** Se n�o existir o Arquivo Acesso1.NTX, cria.
		If ! FIle(cBase+'ACESSO2.NTX' )
			Index ON APELIDO To (cBase)+"Acesso2"
		Endif

		*** Limpa todas as sele��es de Indices na �rea para reposicion�-los
		Acesso->(DBCLearIndex())
		Acesso->(DBSetIndex(cBase+'ACESSO1'))
		Acesso->(DBSetIndex(cBase+'ACESSO2'))
	   
	   Endif
                 Return Nil