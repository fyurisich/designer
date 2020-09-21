#include "Inkey.ch"
#include "MiniGui.ch"
#Include "F_Sistema.ch"
/*

	Fun��o CadastroGenerico()
	Humberto Fornazier - Belo Horizonte/MG - Brasil
	humberto_fornazier@yahoo.com.br
	www.geocities.com/harbourminas

	Em muitos casos necessitamos de tabelas de apoio com campos Codigo e Descri��o.
	Esta � uma  fun��o � gen�rica, que cria , abre o arquivo e possibilita a mnanuten��o no mesmo

	Para utilizar o Cadastro utilize a seguinte fun��o:

	CadastroGenerico( cAlias , cTitulo )
	cAlias	= � a area/arquivo que o usu�rio deseja utilizar, caso o arquivo n�o exista, cria.
	cTitulo	= Titulo quye dever� ser apresentado nas janelas
	Exemplo	= CadastroGenerico( "CONTAS" ,  "Cadastro de Contas do Financeiro" ) 	
	Ser� criada a tabela CONTAS.DBF com os campos  -  Codigo	Character	04
						          Descricao	Character	30	
	
	Para utilizar a tabela em qualquer lugar do sistema, utilize a seguinte fun��o: 
	GenericOpen( cAlias )
	cAlias	= Area/Arquivo que dever� ser aberto
	Exemplo	= GenericOpen( "CONTAS" )
	Ser� aberto o Arquivo Contas em uma nova area com Alias CONTAS

	Para Tratamento do arquivo, dever� ser utilizado os comandos:
	Contas->(DBgoTo()) , Contas->(DBGoBottom()) , Contas->(DBSkip()) , Contas->(DBAppend()) , etc, etc.
	
	Para tratar variaveis do Arquivo: Exemplo:
	cVarCodigo := Contas->Codigo
	cvarDesc    := Contas->Descricao	

	Para Gravar as variaveis no Arquivo:
	Contas->Codigo	:= cVariavel
	Contas->Descricao	:= cVariavel
	
*/
*---------------------------------------------------------------------------------------------------*
* Procedure CadastroGenerico | Cadastro Das Tabelas do Sistema    *
*---------------------------------------------------------------------------------------------------*
Procedure CadastroGenerico( oArea , oTitulo )

	  Private CodigoAlt	:= 0		&& Guarda o Codigo Atual para reposicion�r-lo ao sair deste Cadastro 
	  Private cArea	:= oArea		&& Vari�vel usualizada para guardar a �rea/alias utilizada
	  Private cTitulo	:= oTitulo		&& Titulo desta rotina, ser� mostrado em formul�rios
	  Private lNovo	:= .F.		&& Vari�vel para controlar se Est� Incluindo ou alterando usu�rios

	  GenericOpen( oArea )		&& Abre arquivo solicitado

	  (cArea)->(DBSetOrder(2))  		&& Posiciona o arquivo/alias na Ordem 2 - Descricao

	  *** Cria Formul�rio
	  DEFINE WINDOW Grid_Padrao	;
		 AT 05,05		; 
		 WIDTH	425		;
		 HEIGHT 460		;
		 TITLE cTitulo		;
		 ICON 'ICONE01'		;
		 MODAL			;
		 NOSIZE

		@ 010,010 GRID Grid_1P	;
			   WIDTH  400    	;
			   HEIGHT 329     	;
			   HEADERS {"C�digo","Descri��o"};
			   WIDTHS  {60,333};
			   VALUE 1           	;
			   FONT "Arial" SIZE 09;
			   ON DBLCLICK { || Bt_Novo_Generic(2) }

		@ 357,011 LABEL  Label_Pesq_Generic;
			   VALUE "Pesquisa "	;
			    WIDTH 70		;
			    HEIGHT 20		;
			    FONT "Arial" SIZE 09

		@ 353,085 TEXTBOX PesqGeneric	;
			   WIDTH 326		;
			   TOOLTIP "Digite a Descri��o para Pesquisa"   ;
			   MAXLENGTH 40 UPPERCASE		 ;
			   ON ENTER { || Pesquisa_Generic() }

		@ 397,011 BUTTON Generic_Novo	;
			   CAPTION '&Novo'	;
			   ACTION { || Bt_Novo_Generic(1)};
			   FONT "MS Sans Serif" SIZE 09 FLAT

		@ 397,111 BUTTON Generic_Editar	;
			   CAPTION '&Editar'	;
			   ACTION { || Bt_Novo_Generic(2)};
			   FONT "MS Sans Serif" SIZE 09 FLAT

		@ 397,211 BUTTON Generic_Excluir	;
			   CAPTION 'E&xcluir'	;
			   ACTION { || Bt_Excluir_Generic()};
			   FONT "MS Sans Serif" SIZE 09 FLAT

		@ 397,311 BUTTON Generic_Sair	;
			   CAPTION '&Sair'		;
			   ACTION { || Bt_Generic_Sair() };
			   FONT "MS Sans Serif" SIZE 09 FLAT

	END WINDOW

	*** Posiciona o Foco no TextBox PesqGeneric
	Grid_Padrao.PesqGeneric.SetFocus

	*** Efetua pesquisa ao entrar no form para atualizar o Grid
	Renova_Pesquisa_Generic(" ")

	*** Centraliza Janela
	CENTER   WINDOW Grid_Padrao

	*** Ativa Janela
	ACTIVATE WINDOW Grid_Padrao

	Return Nil

/*
	nReg	= Recebe o C�digo do usu�rio utilizando a Fun��o PegaValorDaColuna() - F_Funcoes.PRG
	cStatus	= Vari�vel para informar na barra de Titulos do Formul�rio  se est� Incluindo ou Alterando
*/
Function Bt_Novo_Generic(nTipo)
	Local nReg	    := PegaValorDaColuna( "Grid_1P" , "Grid_Padrao" , 1 )
	Local cStatus	    := Iif(nTipo==1,"Incluindo Registro em "+cTitulo,"Alterando Registro em "+cTitulo)	

	*** Variavel Private que controla se est� sendo efetuada uma inclus�o ou uma altera��o
	lNovo		    := Iif(nTipo==1,.T.,.F.)

	 *** Se Tipo for 2, o usu�rio est� Alterando/Editando um Registro
	If nTipo == 2	    && Editar/Alterar

		*** Se o usu�rio estiver editando/alterando um registro e a vari�vel nReg estiver vazia � porque o grid n�o foi clicado
		*** Esta vari�vel recebeu (veja cima) o valor do Grid em PegavalorDaColuna() 
		If Empty(nReg)

			MsgExclamation("Nenhum Registro Informado para Edi��o!!",SISTEMA)
			Return Nil
		Else

			*** Posicona o Arquivo no Indice 1 (Codigo)	
			(cArea)->(DBSetOrder(1))

			*** Se o codigo n�o foi localizado no Arquivo, houve um erro de pesquisa
			If ! (cArea)->(DBSeek(nReg))

				MsgInfo("Erro de Pesquisa!!")
				Return NIl	   

			EndIf

			*** Se codigo a ser alterado foi localizado, a vari�vel CodigoAlt Guarda o Valor do Codigo para posterior pesquisa e grava��o
			CodigoAlt := (cArea)->Codigo

		EndIf

	EndIf

	DEFINE WINDOW Novo_Generic;
		AT 10,10		       ;
		WIDTH  590             ;
		HEIGHT 129             ;
		TITLE cTitulo		   ;
		MODAL			       ;
		NOSIZE			       

		DEFINE STATUSBAR		
			STATUSITEM "Manuten��o no "+cTitulo
		END STATUSBAR

		       @003,005 FRAME Group_Generic_1 WIDTH 370 HEIGHT 75

		       *------------------------------------------ Campo Codigo
		       @014,020 LABEL  Label_Gen_Codigo    ;
				VALUE "C�digo"             ;
				WIDTH  70		   ;
				HEIGHT 15		   ;
				FONT "MS Sans Serif" SIZE 8 BOLD

		       @010,100 TEXTBOX  Generic_Codigo  ;
				WIDTH 50		 ;
				FONT "Arial" Size 9      ;
				TOOLTIP "Digite o C�digo";
				MAXLENGTH 04 UPPERCASE	

		       *----------------------------------------------- Campo Descricao
		       @044,020 LABEL  Label_Gen_Descricao;
				VALUE "Descri��o"        ;
				WIDTH  80		 ;
				HEIGHT 19		 ;
				FONT "MS Sans Serif" SIZE 8 BOLD

		       @040,100 TEXTBOX  Generic_Descricao;
				WIDTH 250		  ;
				FONT "Arial" Size 9       ;
				TOOLTIP "Digite a Descri��o";
				MAXLENGTH 30 UPPERCASE;
				ON ENTER  Novo_Generic.Generic_Salvar.SetFocus
	  
		      @003,380 FRAME Group_Generic_6 WIDTH 200 HEIGHT 75

		       @10,390 BUTTON Generic_Salvar	;
				CAPTION "&Salvar"            ;
				ACTION { || Bt_Salvar_Generic() } ;
				WIDTH  180		     ;
				HEIGHT	25		     ;
				FONT "MS Sans Serif" SIZE 8 FLAT

		       @40,390 BUTTON Generic_Sair		    ;
				CAPTION "&Cancelar"              ;
				ACTION Novo_Generic.Release ;
				WIDTH  180		     ;
				HEIGHT	25		     ;
				FONT "MS Sans Serif" SIZE 8 FLAT

	 END WINDOW

	 *** Se a opera��o for de Altera��o/Edi��o		
	If ! lNovo

		*** Preenche campos do formul�rio com dados do Arquivo		
		Novo_Generic.Generic_Codigo.Value := AllTrim((cArea)->Codigo)
		Novo_Generic.Generic_Descricao.Value := AllTrim((cArea)->Descricao)	

	EndIf

	*** Coloca na barra de Status do Formul�rio a variavel com informa�	�o de Altera��o ou Inclus�o
	Novo_Generic.StatusBar.Item(1) := cStatus

	*** Como o c�digo � gerado pelo sistema, o campo c�digo � desabilitado 
	 DISABLE CONTROL Generic_Codigo OF Novo_Generic

	 *** Posiciona a �rea/Alias no Indice 2 (Descri��o)
	 (cArea)->(DBSetOrder(2))

	*** Pociociona o Cursor/Foco  no campo Descri��o do Formul�rio
	Novo_Generic.Generic_Descricao.SetFocus

	*** Centraliza Janela
	CENTER   WINDOW Novo_Generic

	*** Ativa janela
	ACTIVATE WINDOW Novo_Generic

	Return NIL

/*
*/		
Function Bt_Excluir_Generic()
	Local nReg	   := PegaValorDaColuna( "Grid_1P" , "Grid_Padrao" , 1 )
	Local cNome	   := ""
	Local cUltimaPesq := Upper(AllTrim( Grid_Padrao.PesqGeneric.Value ))

	*** Verifica se o Usu�rio atual tem permiss�o para Excluir Registros
	If ! NoExclui( Acesso->Status )
		MsgNo( "EXCLUIR")
		Return Nil
	EndIf

	*** Guarda a ultima pesquisa para posterior refresh do Grid
	cUltimaPesq := Iif( ! Empty(cUltimaPesq) , cUltimaPesq , AlLTrim(cNome) )

	*** Se vari�vel nReg estiver em Branco 
	If Empty(nReg)

		MsgExclamation("Nenhum Registro Informado para Edi��o!!",SISTEMA)
		Return Nil

	Else

		*** Posiciona a �rea/Alias na Ordem 1 (por c�digo)
		(cArea)->(DBSetOrder(1))
		
		*** Se Codigo que est� no Grid n�o foi localizado no Arquivo, ocorreu um erro
		If ! (cArea)->(DBSeek(nReg))

			MSGINFO("Erro de Pesquisa!!")
			Return Nil

		EndIf

			*** Solicita confirma��o do Registro
			If MsgYesNo("Excluir "+AllTrim( (cArea)->Descricao )+" ??",SISTEMA)

				*** Bloqueia Registro na Rede
				If BloqueiaRegistroNaRede( cArea )

					*** Exclui Resgistro
					(cArea)->(DBDelete())

					*** Libera registro na Rede
					(cArea)->(DBUnlock())

					*** Efetua Refresh do Grid
					Renova_Pesquisa_Generic(cUltimaPesq)

				EndIf

			EndIf

	EndIf
	Return Nil

/*
	cPesq				= Recebe o valor do campo de pesquisa PesqGeneric sem espa�os em branco
	nTamanhoNomeParaPesquisa	= Guarda o tamanho da vari�vel a ser pesquisada para comparar 
	Local nQuantRegistrosProcessados	= Contador que controla quantos registros j� foram lidos
	Local nQuantMaximaDeRegistrosNoGrid = Limite de registros que ser�o mostrados no Grid
*/
Function Pesquisa_Generic()
	Local cPesq			:= Upper(AllTrim(   Grid_Padrao.PesqGeneric.Value  ))
	Local nTamanhoNomeParaPesquisa	:= Len(cPesq)
	Local nQuantRegistrosProcessados	:= 0
	Local nQuantMaximaDeRegistrosNoGrid := 30

	*** Posiciona Area/Alias na Ordem de Descri��o		
	(cArea)->(DBSetOrder(2))
	
	*** Efetua pesquisa no Arquivo para posicionar no primeiro registro que satisfa�a a condi��o
	(cArea)->(DBSeek(cPesq))

	*** Exclui todos os Dados do Grid
	DELETE ITEM ALL FROM Grid_1P OF Grid_Padrao

	*** Entra no La�o (While ) at� que encontre o fim do arquivo
	Do While ! (cArea)->(Eof())

		*** Se o Substr da Descricao for igual � variavel cPesq ( Conte�do do campo TxtPesquisa)
		if Substr( (cArea)->Descricao,1,nTamanhoNomeParaPesquisa) == cPesq
			
			*** Acumula contador
			nQuantRegistrosProcessados += 1

			*** Se a quantidade de resgistros lidos atingiu o limite de registros definidos para o grid sai do la�o/While
			if nQuantRegistrosProcessados > nQuantMaximaDeRegistrosNoGrid
				EXIT
			EndIf

			*** Nesta rotina, pode-se aproveitar para verificar erros no arquivo
			*** Nesta caso, verifica se existem Descricao em branco, j� que � um campo obrigat�rio
			If Empty( (cArea)->Descricao )
				MSGBOX("Existe Descri��o em Branco Nesta Tabela") 	       
			Endif

			 *** Adiciona registro no Grid
			ADD ITEM { (cArea)->Codigo,(cArea)->Descricao} TO Grid_1P OF Grid_Padrao

		*** Se o Substr de Descricao estiver fora da faixa de pesquisa, abandona o la�o
		ElseIf Substr( (cArea)->Descricao,1,nTamanhoNomeParaPesquisa) > cPesq

			EXIT
		
		Endif

		*** Salta para pr�ximo registro
		(cArea)->(DBSkip())

	EndDo
	
	
	*** Pisiciona o cursor/Foco no campo PesqGeneric		
	Grid_Padrao.PesqGeneric.SetFocus

	 Return Nil

/*
	Recebe um par�metro com o nome a ser pesquisado, colocar os Dez primeiros caracteres no PesqGeneric e
	retorna para a rotina Pesquisa_Generic()
*/
Function Renova_Pesquisa_Generic(cNome)
	Grid_Padrao.PesqGeneric.Value := Substr(AllTrim(cNome),1,10)
	 Grid_Padrao.PesqGeneric.SetFocus
	 Pesquisa_Generic()
	 Return Nil

/*
*/
Function Bt_Salvar_Generic()
	Local cCodigo
	Local cPesq	:= AllTrim( Grid_Padrao.PesqGeneric.Value )

	*** Se o campo Descricao n�o for informados, enviar mensagem e posiciona cursor/Foco no campo Generic_Descricao 
	If Empty( Novo_Generic.Generic_Descricao.Value  )
		PlayExclamation()
		MSGINFO("Descri��o n�o Informada !!","Opera��o Inv�lida")
		Novo_Generic.Generic_Descricao.SetFocus
		Return Nil
	EndIf

	*** Se for um Novo registro
	 If lNovo	  

		*** Verifica se Usu�rio tem permiss�o para Incluir Registros
		If ! NoInclui( Acesso->Status )
			MsgNo( "INCLUIR")
			Return Nil
		EndIf

		*** Muda Status da vari�vel lNovo 
		lNovo    := .F.

		*** Gera o pr�ximo Codigo para o Registro - Fun��o GeraCodigo() est� em F_Funcoes.PRG
		cCodigo  := GeraCodigo( cArea  , 1 , 04 )

		*** Cria um novo Registro e grava
		(cArea)->(DBAppend())
		(cArea)->Codigo	:= cCodigo
		(cArea)->Descricao	:= Novo_Generic.Generic_Descricao.Value

		*** Verifica se Gravou o Codigo no Arquivo - Esta fun��o est� em F_Funcoes.PRG
		GravouCodigoCorretamente( cArea , cCodigo , 1 )
		PlayExclamation()
		MSGExclamation("Inclus�o Efetivada no "+cTitulo,SISTEMA)

		*** Release no Formu�rio
		Novo_Generic.Release

		*** Refresh Grid
		Renova_Pesquisa_Generic(Substr( (cArea)->Descricao,1,10))

	Else	         

		*** Se estiver alterando registro
		*** Verifica se usu�rio atual tem permiss�o para Alterar registros
		If ! NoAltera( Acesso->Status )
			MsgNo( "ALTERAR")
			Return Nil
		EndIf

		*** Posiciona a Area/Alias na ordem de C�digo
		(cArea)->(DBSetOrder(1))

		*** Se c�digo a ser alterado n�o for lozalizado no Arquivo - Ocorreu um erro
		If ! (cArea)->(DBSeek(CodigoAlt))
			PlayExclamation()
			MsgExclamation("ERRO-G01 # C�digo n�o Localizado para Altera��o!!",SISTEMA)
		Else

			*** Bloqueia registro na rede
			If BloqueiaRegistroNaRede( cArea )

				*** Grava a Altera��o no Arquivo	
				(cArea)->Descricao  := Novo_Generic.Generic_Descricao.Value

				*** Desbloqueia registro na rede
				(cArea)->(DBUnlock())

				*** Envia mensagem para Usu�rio					
				MsgINFO("Registro Alterado!!",SISTEMA)

				*** Release no Form
				Novo_Generic.Release

				*** Refresh Grid
				Renova_Pesquisa_Generic(Substr( (cArea)->Descricao,1,10))

			EndIf

		EndIf

	EndIf
	Return Nil
/*
*/
Function Bt_Generic_Sair()
	(cArea)->(DBCloseArea())
	Grid_Padrao.Release

/*
	Select( AREA )	 = retorna 0 se a �rea passada como par�metro N�O estiver em uso
	BasedeDados()	 = Func�o que retorna local da base de Dados do Sistema / L� o arquivo FINANC.INI / Fun��o est� em F_FUNCOES.PRG
	ArqbBase	 = Concatena a variavel cBase + o Arquivo que ser� aberto
	aarq		 = Array para criar estrutura do arquivo

*/
Function GenericOpen( oArea , LPack )
	Local nArea	:= Select( oArea )
	Local aarq	:= {}
	Local xBase	:= BaseDeDados()
	Local ArqBase	:= xBase + oArea + ".DBF"   	 

	*** Se a vari�vel LPack n�o foi passada como par�metro, marca como .F.
	LPack := Iif( LPack == Nil ,  .F.  , lPack )

	*** Se Area/Alias n�oe sta em uso
	If nArea == 0		 

		*** Se arquivo n�o existe, cria
		If ! FILE( (ArqBase) )
			 Aadd( aarq , { 'CODIGO'	, 'C' , 04 , 0 } )
			 Aadd( aarq , { 'DESCRICAO'	, 'C' , 30 , 0 } )                
			 DBCreate     ( (ArqBase)     , aarq   )
		 EndIf     		

		*** Rotina para Efetuar PACK no DBF - Esta fun��o est� em F_Funcoes.PRG
		PacKArquivo( oArea , LPack  )					  

		*** Abre arquivo em uma nova area em mode de compartilhamento
		Use (ArqBase) Alias (oArea) new shared
		
		*** Se indice 1 n�o existe. cria   (codigo)
		If ! File( xBase + oArea + '1.ntx' )
			 Index on Codigo    to (xBase)+oArea+"1"
		Endif
		
		*** Se indice 2 n�o existe, cria  (Descricao)
		If ! File( xBase + oArea + '2.ntx' )
			 Index on Descricao to (xBase)+oArea+"2"
		Endif

		*** Limpa todas as sele��es de Indices na �rea para reposicion�-los
		(oArea)->(DBCLearIndex())
		(oArea)->(DBSetIndex( xBase + oArea + '1'))
		(oArea)->(DBSetIndex( xBase + oArea + '2'))

	Endif

	Return Nil     