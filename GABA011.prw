#include 'rwmake.ch'
#include 'protheus.ch'

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: GABA011      || Autor: Gabriel Leão     		|| Data: 03/08/23  ||
||-------------------------------------------------------------------------||
|| Descrição: FILE BROWSER - Arquivos relacionados ao registro posicionado ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/ 
User Function GABA011()

	Local nTab := 1
	Private aTabTmp[01]
	Private cAliasT	:= GetNextAlias()
    // Parâmetros iniciais (Talvez seria bom criar estes parâmetros no configurador...)
	Private cSrvDir	:= "\ARMAZ_ARQUIVOS_CUSTOM\Z01\"
	Private cCliDir	:= "C:\ARQUIVOS_PROTHEUS\DOWNLOAD\"

    // Cria as tabelas temporarias 
	FWMsgRun(, {|oSay| GA011TabTmp( oSay ) }, cCadastro, "Criando Tabelas Temporárias..." )
	
    // Verificação de tabelas temporárias
	For nTab := 1 to Len( aTabTmp )
		If Select( "TabTmp"+cValToChar(nTab) ) == 0
			APMsgStop( 'Erro na criação das tabelas temporárias.', cCadastro )
			Return
		EndIf
	Next nTab
	
    // Chamada do programa principal
	GA011View()
	
    // Apaga as tabelas temporárias ao final da execução
	For nTab := 1 to Len( aTabTmp )
		If Select( "TabTmp"+cValToChar(nTab) ) <> 0
			aTabTmp[nTab]:Delete()
		EndIf
	Next nTab

Return



// *************************************************************
// -------- Função para listagem de arquivos anexados ----------
// *************************************************************
Static Function GA011View()

	Private oDlg
	Private oFont
	Private oLbx

	// Definindo as propriedades do Dialog
	Define msDialog oDlg Title cCadastro From 00,00 To 400,600 Of oMainWnd Pixel
	Define Font oFont Name 'Arial' Size 0,-12 Bold

	dbSelectArea("TabTmp1")
	dbGoTop()
	@ 010,005 ListBox oLbx Fields TabTmp1->NOME,Transform( TabTmp1->TAMANHO, '@E 9,999,999,999') ;
		Header 'Nome do Arquivo', 'Tamanho em KB' Size 290,160 Of oDlg Pixel

	@ 180,250 Button 'Baixar' 		 Size 45,15 Action ArquivosZ01("LER")       Of oDlg Pixel
	@ 180,200 Button 'Enviar' 		 Size 45,15 Action ArquivosZ01("GRAVAR")    Of oDlg Pixel
	@ 180,150 Button 'Excluir' 		 Size 45,15 Action ArquivosZ01("EXCLUIR")   Of oDlg Pixel
	
	Activate Dialog oDlg Centered

Return



// *************************************************************
// ------- Função principal de manipulação de arquivos ---------
// *************************************************************
Static Function ArquivosZ01( cOperacao )

	// Variáveis de controle
	Local cFileType	:= "Acrobat PDF |*.pdf|"
	Local cFileExt	:= ".pdf"
	Local cFileIn 	:= ""
	Local aAreaAnt 	:= GetArea()

	// Cria o diretório na máquina cliente
	If !ExistDir( cCliDir )
		MakeDir( cCliDir )
	EndIf

    // Cria o diretório no servidor
	If !ExistDir( cSrvDir )
		MakeDir( cSrvDir )
	EndIf

	//Iniciando processo de gravação
	If cOperacao == "GRAVAR"

		cFileIn := cGetFile( cFileType , 'Selecione o arquivo', 0, cCliDir )  //Tela de seleção de arquivo para envio
		If cFileIn != ""
			// Cria o diretório para anexo ao registro no servidor
			If !ExistDir( cSrvDir + cValToChar(Z01->Z01_NUM) + "\" )
				MakeDir( cSrvDir + cValToChar(Z01->Z01_NUM) + "\" )
			EndIf
			FWMsgRun(, {|| CpyT2S( cFileIn , cSrvDir + cValToChar(Z01->Z01_NUM) + "\" ) }, cCadastro, Capital("Enviando arquivo " + cFileIn + "...") ) //Upload do arquivo para o servidor
			MsgAlert("Arquivo enviado com sucesso!")
		EndIf

	ElseIf cOperacao == "LER"

		If cCliDir != ""
			FWMsgRun(, {|| CpyS2T( cSrvDir + cValToChar(Z01->Z01_NUM) + '\' + AllTrim(TabTmp1->NOME) , cCliDir ) }, cCadastro, Capital("Baixando arquivo " + AllTrim(TabTmp1->NOME) + "...") )
			MsgAlert("Arquivo baixado com sucesso! Caminho: " + cCliDir + AllTrim(TabTmp1->NOME) )
			winexec("explorer.exe " + cCliDir + AllTrim(TabTmp1->NOME) )
		EndIf

	ElseIf cOperacao == "EXCLUIR"

		If AllTrim(TabTmp1->NOME) != ""
			If MsgYesNo("Após a exclusão não será possível recuperar o arquivo. Deseja continuar?")
				//Usar a função FErase(caminho do arquivo no servidor)
				FErase( cSrvDir + cValToChar(Z01->Z01_NUM) + '\' + AllTrim(TabTmp1->NOME) )
			EndIf
		Else 
			MsgAlert("Nenhum arquivo foi selecionado")
		EndIf

	EndIf

	RestArea(aAreaAnt)
	GA011Busca()

Return



// *************************************************************
// ------ Função para estruturação de tabela temporária --------
// *************************************************************
Static Function GA011TabTmp( oSay )

	Local aFields	:= {}

//Ú--------------------------------------------------------------¿
//³ Dados de Nota Fiscal     							 		 ³
//À--------------------------------------------------------------Ù
	oSay:SetText( 'Buscando Arquivos' )
	ProcessMessage()

	aFields	:= {{ "NOME"	, "C",  60		, 0 }, ;
				{ "TAMANHO"	, "N",  10		, 0 }}
					
	GA011CriaT( 1, aFields, { "NOME" } )

	FWMsgRun(, {|oSay| GA011Query() }, cCadastro, "Selecionando Dados - Arquivos" )

Return



// **************************************************************
// --- Função para preencher a tabela temporária dos arquivos ---
// **************************************************************
Static Function GA011Query()
	
	// Variáveis de requisição de Queries
	Local aDir
    Local nAux := 0

    // Buscar arquivos no diretório
	aDir := Directory( cSrvDir + cValToChar(Z01->Z01_NUM) + "\*.*")
		
    // Construção da tabela de arquivos para usar no listbox
	For nAux := 1 To Len(aDir)
		TabTmp1->( RecLock( 'TabTmp1', .T. ) )
		TabTmp1->NOME	:= aDir[nAux][1]
		TabTmp1->TAMANHO:= aDir[nAux][2]/1024
		TabTmp1->( MsUnLock() )
	Next
	
	TabTmp1->( dbGoTop() )

Return



// *************************************************************
// ------- Função para criação das tabelas temporárias ---------
// *************************************************************
Static Function GA011CriaT( nTab, aFields, aIndex )

	If !Empty( aTabTmp[nTab] ) .and. ( Select( "TabTmp"+cValToChar(nTab) ) <> 0 )
		aTabTmp[nTab]:Delete()
	EndIf

	aTabTmp[nTab] := FWTemporaryTable():New( "TabTmp"+cValToChar(nTab) , aFields )
	aTabTmp[nTab]:AddIndex( "01", aIndex )
	aTabTmp[nTab]:Create()

Return



// *************************************************************
// --------- Função para limpar as tabelas temporárias ---------
// *************************************************************
Static Function GA011LimpaT( nTab )

	Local aAreaAnt := GetArea()
	
	dbSelectArea( "TabTmp"+cValToChar(nTab) )
	dbGoTop()
	
	While !EoF()
		RecLock( "TabTmp"+cValToChar(nTab), .F. )
		dbDelete()
		MsUnLock()
		
		dbSkip()
	End
	
	RestArea( aAreaAnt )

Return


// *************************************************************
// ---------- Função para busca de arquivos anexados -----------
// *************************************************************
Static Function GA011Busca()

	GA011LimpaT( 1 )
	GA011Query()
	oLbx:Refresh()
	oLbx:SetFocus()

Return




