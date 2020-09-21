#Include "minigui.ch"
#Include "F_sistema.ch"
#Include "Common.ch"
#Include "Fileio.CH"
#Include "Directry.ch"

/*
* Fun��o: BloqueiaRegistronaRede( mArea ) == > .T.
*
*/
Function BloqueiaRegistroNaRede( marea )
	Local op := 0

	Do While ! (marea)->(RLock())	

		If ! MSGRetryCancel("Registro em Uso na Rede Tenta Acesso??",SISTEMA)
			Return .F.
		EndIf

	EndDo

	Return .T.
/*
* 
* Gera pr�ximo codigo na �rea selecionada
* Sintaxe: GeraCodigo( ALIAS , INDEX , TAMANHO DO CAMPO ) => proximo Codigo
*
* oArea		= �rea de trabalho (Alias)
* ordem		= Indice do campo Codigo
* tamanho	= Tamanho do campo Codigo 
*
*/
Function GeraCodigo( oArea , ordem , Tamanho )
	 Local regist	:= (oArea)->(Recno())	&& Guarda registro atual	
	 Local ord	:= (oArea)->(IndexOrd())	&& Guarda Indice atual
	 Local cdg	:= 0

	 (oArea)->(DBSetOrder( ordem ))		&& Posiciona a Area na Ordem desejada
	 (oArea)->(DBGoBottom())			&& vai para o fim do arquivo

	 cdg := StrZero( Val ( (oArea)->CODIGO ) + 1 , Tamanho ) && gera o codigo (Ultimo + 1), genado Zeros � esquerda de acordo com o tamanho solicitado

	*** Se o codigo gerado foi Zero, ocorreu um erro e usu�rio � informado
	If Val(cdg) == 0
		
		MSGExclamation(PadC("ATENCAO",70)+QUEBRA+;
			   PadC("*** Erro ao Gerar Codigo em "+oArea+" ***",70)+QUEBRA+;
			   PadC("*** Codigo Gerado EM BRANCO ***",70)+QUEBRA+;
			   PadC("Provavelmente existem indices ou Base de Dado Corrompida!!",70)+QUEBRA+;
			   PadC("Efetue a Manutencao do Sistema Antes de qualquer outra Operacao!!",70)+QUEBRA+;
			   PadC("*** Sistema Sera Finalizado!! ***",70),SISTEMA)
		RELEASE WINDOW ALL

	 Endif

	 *** Se Existem mais de um registro no arquivo e o pr�ximo codigo gerado foi 1 , ocorreu um erro		
	If (oArea)->(LastRec()) > 1 .And. Val(cdg) == 1

		MSGExclamation(PadC("ATENCAO",70)+QUEBRA+;
			   PadC("*** Erro Detectado ao Gravar em "+oArea+" ***",70)+QUEBRA+;
			   PadC("*** Codigo Gerado Invalido!! ***",70)+QUEBRA+;
			   PadC("Provavelmente existem indices ou Base de Dado Corrompida!!",70)+QUEBRA+;
			   PadC("Efetue a Manutencao do Sistema Antes de qualquer outra Operacao!!",70)+QUEBRA+;
			   PadC("*** Sistema Sera Finalizado!! ***",70),SISTEMA)
		RELEASE WINDOW ALL

	 Endif

	 (oArea)->(DBSetOrder( ord ) )  && retorna para a Ordem em que arquivo estava
	 (oArea)->(DBGoTo( regist )  )   && retorna para o Registro que estava
	 Return( cdg )

/*
* Rotina que consiste se o registro foi gravado corretamente no DBF
*
* cArea		= Area de trabalho - (Alias)
* mCODIGO	= Codigo � pesquisar
* nIndex		= Index � pesquisar
*
*/
Function GravouCodigoCorretamente( cArea , mCODIGO , nIndex )
	 Local nInd	:= (cArea)->(IndexOrd())	&& Guarda a Ordem atual
	 Local nReg	:= (cArea)->(Recno())	&& Guarda o registro atual	
	 Local lRet := .T.

	(cArea)->(DBSetOrder(nIndex))	&& Posiciona na ordem/Indice desejado

	*** Se o codigo n�o foi localizado, o usu;ario recebe mensagem
	If ! (cArea)->(DBSeek(mCODIGO))	&& faz a pesquisa do C�digo

		MSGExclamation(PadC("ATENCAO",70)+QUEBRA+;
			   PadC("*** Registro n�o incluido em "+cArea+" ***",70)+QUEBRA+;
			   PadC("Provavelmente existem indices ou Base de Dado Corrompida!!",70)+QUEBRA+;
			   PadC("Efetue a Manutencao do Sistema Antes de qualquer outra Operacao!!",70)+QUEBRA+;
			   PadC("*** Sistema Sera Finalizado!! ***",70),SISTEMA)
		RELEASE WINDO ALL

	 EndIf	
	 (cArea)->(DBSetOrder(nInd))	&& retorna para a Ordem em que arquivo estava
	 (cArea)->(DBGoTo(nReg))		&& retorna para o Registro que estava
	 Return lRet

/*
* Esta fun��o � ma pesquisa gen�rica:
* O usu�rio informa a Area/Alias, a ordem para pesquisa, a variavel a ser pesquisada e o campo que dever� ser retornado
*
* Exemplo1: O usu�rio deseja o Endere�o de um determinado Cliente
* cEnd := Pgeneric( "CLIENTES" ,     1    ,      "0012"             ,  "ENDERECO"    )
*		   Alias             index     C�digo Cliente      ,  Campo de retorno
* a variavel cEnd receber� o conte�do da vari�vel ENDERECO
* O campo para retorno poder� ser qualquer campo do DBF
*
* Exemplo2: O usu�rio deseja a DESCRICAO de Uma Conta no arquivo de Contas do Financeiro
* cDesc := Pgeneric( "CONTAS" ,  1 , "0016" , "DESCRICAO" )
* a variavel cDesc receber� o conte�do da vari�vel DESCRICAO do Arquivo CONTAS.DBF
*
* oArea	= Area de Trabalho/Alias
* oOrd	= Ordem de pesquisa
* oVar	= Vari�vel a pesquisar
* oCampo = Conteudo do Campo que deve ser retornado	
*
*/
Function PGeneric(  oArea , oOrd   ,  oVar ,  oCampo )
	 Local	nord	   := (oArea)->(IndexOrd () )
	 Local	Oreg	   := (oArea)->(RECNO() )
	 Private  oNome
	 (oArea)->(DBSetOrder( oOrd ) )
	 (oArea)->(DBSeek( oVar ) )
	 oNome := '{ ||' + oArea + '->' + oCampo + '}'
	 oNome := &oNome
	 oNome := Eval( oNome )
	 (oArea)->(DBSetOrder( nord ) )
	 (oArea)->(DBGoTo( oReg ) )
	 Return( oNome )
/*
* Salva o Ambiente do Alias Atual em uma Array
* Salva o Alias, o Indice e o Recno()  da �rea corrente e guarda em uma Array
*
* Exemplo:
*
* Function Sample01()
*	  Local aAmb := SvAmb()
*
*	  ... Rotinas da Fun��o	
*
*	  RtAmb( aAmb  )  && Restaura o Ambiente anterior
*	
*	  Return Nil
*/
Function SvAmb()
	Local Local1:= {}
	Aadd(Local1,Alias())
	Aadd(Local1,Indexord())
	Aadd(Local1,Recno())
	Return Local1
/*
*  Veja exemplo em SvAmb()
* Restaura o Ambiente gravado em uma Array pelo cmando SvAmb()
*/
Function RtAmb(Arg1)
	If Arg1[1] != Nil .And. Select(Arg1[1]) != 0
		Select(Arg1[1])
		If Arg1[2] != 0
			(Arg1[1])->(DBSetOrder(Arg1[2]))
		Endif
		If Arg1[3] != 0
			(Arg1[1])->(DBGoTo(Arg1[3]))
		 Endif
	 Endif
	 Return Nil
/*
* Pega valor da coluna em um Grid
*
* Sintaxe: PegavalorDacoluna( "Grid_Clientes" , "Form_Grid_Clientes" , 1 ) -> Valor
*
*/
Function PegaValorDaColuna( xObj, xForm, nCol)
	Local nPos := GetProperty ( xForm , xObj , 'Value' )
	Local aRet := GetProperty ( xForm , xObj , 'Item' , nPos )
	Return aRet[nCol]
/*
*
* Sintaxe: LinhaDeMesagem(  [ cMensagem ] )
* Esta fun��o, recebe uma mensagem e atualiza a Linha de Status do Formul�rio atual
* Se n�o for passado nenhum par�metro, a mensagem ser� atualizada com BaseDeDados()
*
*/
Function LinhaDeStatus(cMensagem)
	cMensagem := Iif( cMensagem == Nil , "Base de Dados: "+BaseDeDados() , AllTrim(cMensagem) )
	Form_0.StatusBar.Item(1) := cMensagem
	Return Nil

*------------------------------------------------------------------------------------------------------------------------------------------
* Fun��o		: Cria_Ini()
* Finalidade	: Cria o Arquivo FINANC.INI assim que o sistema � inicializado no diret�rio atual
* Observa��o	: Sempre que o sistema � executado, verifica se o Arquivo existe, e se n�o existir cria.
*-----------------------------------------------------------------------------------------------------------------------------------------
Function Cria_File_Ini()
	If ! File("FINANC.INI")
	     BEGIN INI FILE "Financ.ini"
		SET SECTION "Base de Dados" ENTRY "Servidor"            To "SIM"
		SET SECTION "Base de Dados" ENTRY "Base de Dados" To DiskName()+":\"+CurDir()+"\BASE\" 	      
		SET SECTION "Seguran�a"        ENTRY "Exit"                 To "SIM"      
		SET SECTION "Seguran�a"        ENTRY "�ltimo BackUp" To DtoC( Date() )
		SET SECTION "Seguran�a"        ENTRY "Data BackUp" 	 To DtoC( Date() )
		SET SECTION "Seguran�a"        ENTRY "Hora BackUp"   To Time()
		SET SECTION "Seguran�a"        ENTRY "Data Ultimo Acesso" To DtoC( Date() )
		SET SECTION "Seguran�a"        ENTRY "Hora Ultimo Acesso" To Time()
		SET SECTION "Seguran�a"        ENTRY "Usuario"  To "NONE"
	     END INI				
	EndIf
              Return Nil
*-------------------------------------------
* L� o arquivo FINANC.INI e retorna a Base De Dados
Function BaseDeDados()
*-------------------------------------------
	Local cValue := ""
	
	If ! File("FINANC.INI")
	   MsgStop("Arquivo FINANC.INI n�o encontrado!!" , SISTEMA )
	   ExitProcess(0)
	EndIf

	BEGIN INI FILE "Financ.Ini"
		GET cValue SECTION "Base De Dados" ENTRY "Base De Dados"
	END INI
	
	Return Upper( cValue )
*-------------------------------------------
* L� o arquivo FINANC.INI e retorna SIM/N�o para Servidor de Dados
Function ServidorDeDados()
*-------------------------------------------
	Local cValue := ""
	
	If ! File("FINANC.INI")
	   MsgStop("Arquivo FINANC.INI n�o encontrado!!" , SISTEMA )
	   ExitProcess(0)
	EndIf

	BEGIN INI FILE "Financ.Ini"
		GET cValue SECTION  "Base De Dados" ENTRY "Servidor"
	END INI
	
	Return Upper( cValue )
*-------------------------------------------
* verifica no Arquivo FINANC.INI se sistema foi desligado corretamente
Function Saida_Irregular()
*-------------------------------------------
	Local cValue := ""
	
	If ! File("FINANC.INI")
	   MsgStop("Arquivo FINANC.INI n�o encontrado!!" , SISTEMA )
	   ExitProcess(0)
	EndIf

	BEGIN INI FILE "Financ.Ini"
		GET cValue SECTION  "Seguran�a" ENTRY "Exit"
	END INI
	
	Return Upper( cValue )
*------------------------------------------------------------------------------------------------------------------------------------------
* Fun��o		: Status_Entrada_Saida(cStatus)
* Finalidade	: Controlar se o Sistema Foi desligado Corrretamente
*-----------------------------------------------------------------------------------------------------------------------------------------
Function Status_Entrada_Saida(cStatus)
	Local cValue := ""
	
	If ! File("FINANC.INI")
	   MsgStop("Arquivo FINANC.INI n�o encontrado!!" , SISTEMA )
	   ExitProcess(0)
	EndIf
	
              BEGIN INI FILE "Financ.ini"       
		SET SECTION "Seguran�a"  ENTRY "Exit"            To cStatus
		SET SECTION "Seguran�a"  ENTRY "Data Ultimo Acesso" To DtoC( Date() )
		SET SECTION "Seguran�a"  ENTRY "Hora Ultimo Acesso" To Time()
		SET SECTION "Seguran�a"  ENTRY "Usuario" To Iif( Select( "Acesso" ) != 0 , Acesso->APELIDO , "NONE" )
              END INI
	
              Return Nil
/*
*/
Function PackArquivo( cArq , LPack )	
	LPack := Iif( LPack == Nil, .F., LPack )
	If LPack
	   LinhaDeStatus("PACK em "+cArq)
	   USE (cArq) Alias ArqLimpa EXCLUSIVE NEW
	   IF ! NetErr()		
	       PACK
                 ENDIF  
	  ArqLimpa->(DBCloseArea())
             Endif       
             Return Nil	
/*
*/
Function Decripta( cPalavra )
	Local nTam	:= 0
	Local cChave	:= "@#$%"
	Local cCripitado	:= ""
	Local i		:=0        	  
	cPalavra := Iif( Empty( cPalavra ), "Ze Coolmeia", cPalavra )
	nTam := Len( cPalavra )
	Do While Len( cChave ) < nTam
		cChave += cChave
	EndDo
	cCripitado := ""
	For i := 1 To nTam
		cCripitado += Chr( Asc( SubStr( cPalavra, i, 1 ) ) - Asc( SubStr( cChave, i, 1 ) ) )
	Next
	Return cCripitado
/*
*/
Function Encripta( cPalavra )
	Local nTam	:= 0
	Local cChave	:= "@#$%"
	Local cCripitado	:= ""
	Local i		:=0                
	cPalavra := Iif( Empty( cPalavra ), "Ze Coolmeia", cPalavra )
	nTam := Len( cPalavra )
	Do While Len( cChave ) < nTam
		cChave += cChave
	EndDo
	cCripitado := ""
	For i := 1 To nTam
		cCripitado += Chr( Asc( SubStr( cPalavra, i, 1 ) ) + Asc( SubStr( cChave, i, 1 ) ) )
	Next	
	Return cCripitado
/*
*/
Function Indexa()
	Local cUsuarioAtual:= Acesso->Codigo
	Local cBase	:= BaseDeDados()
	Local aDir	:= Directory( cBase+"*.NTX" )
	Local i		:= 0

	If ServidorDeDados() == "SIM"

		If  MsgYesNo(PadC("*** Sistema Controle Financeiro V.1.0 ***",60)+QUEBRA+;
		      PadC(" *** Indexa��o do Sistema ***",60)+QUEBRA+;
		      PadC(" ",30)+QUEBRA+;
		      PadC(" Sua Esta��o de Trabalho � um Servidor de Dados!!",60)+QUEBRA+;
		      PadC(" Para indexar o sistema, verifique se n�o existem",60)+QUEBRA+;
		      PadC(" usu�rios ativos no Sistema e s� ap�s desativ�-los",60)+QUEBRA+;
		      PadC(" inicie a Indexa��o!!",60)+QUEBRA+;
		      PadC(" ",30)+QUEBRA+;
	                    PadC(" INICIA indexa��o Agora??",60)+QUEBRA+;
	                    PadC("",60) , SISTEMA ) 

			LinhaDeStatus('Indexando Sistema Financeiro...  Aguarde !!')

			Close All
			
			** Apaga Arquivos de Indices (NTX)
			For i := 1 To Len( aDir )		
				Delete File (cBase+aDir[ i ][ 1 ])
			Next			

			ClientesOpen  (.T.)
			FornecedOpen(.T.)
			PagarOPen(.T.)

			*** Posiciona no Usu�rio Atual
			AcessoOpen()
			Acesso->(DBSetOrder(1))
			If ! Acesso->(DBSeek( cUsuarioAtual ))
				MsgBox("*** Erro *** Usu�rio Ativo n�o localizado... Reinicie o Sistema!!" , SISTEMA )
			EndIf

			MsgInfo("*** Indexa��o Finalizada!! ***" , SISTEMA )
			
		EndIf

	Else

		MsgInfo(PadC("*** Sistema Controle Financeiro V.1.0 ***",60)+QUEBRA+;
		      PadC(" *** Indexa��o do Sistema ***",60)+QUEBRA+;
		      PadC(" ",30)+QUEBRA+;
		      PadC(" Sua Esta��o de Trabalho � um Terminal de Dados",60)+QUEBRA+;
 		      PadC(" e a indexa��o s� poder� ser feita no Servidor de Dados!!",60)+QUEBRA+;	
	                    PadC("",60) , SISTEMA ) 

	Endif
	
	Return Nil
/*
*/
Function GenericMask( xForm , xObj , cMask )
	Local i		:= 0
	Local cCGC	:= AllTrim( GetProperty ( xForm , xObj , 'Value' ) )
	Local nLen	:= 0
	Local cNewCGC	:= ""	

	For i := 1	 To Len( cMask )
		nLen += Iif(  IsDigit( Substr( cMask , i , 1 ) )  , 1 , 0 )
	Next

	For i := 1	 To Len( cCGC )
		cNewCGC += Iif(  IsDigit( Substr( cCGC , i , 1 ) )  , Substr( cCGC , i , 1 ) , ""  )
	Next

	cNewCGC :=  StrZero( Val( cNewCGC ) , nLen )	

	SetProperty ( xForm , xObj , 'Value' , TransForm( cNewCGC , cMask ) )

	Return Nil
/*
*/
Function NoModulo()
         MsgBox("Modulo n�o Dispon�vel !!")
         Return Nil
