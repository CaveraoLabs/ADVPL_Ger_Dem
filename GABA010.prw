#include 'rwmake.ch'
#include 'protheus.ch'

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Fun��o: GABA010      || Autor: Gabriel Le�o     		|| Data: 01/08/23  ||
||-------------------------------------------------------------------------||
|| Descri��o: Gerenciamento de Demandas		                               ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
���������������������������������������������������������������������������*/ 
User Function GABA010()

    Private cCadastro := "Gerenciamento de Demandas"
    Private aCores 	  := {{ '(Z01->Z01_STATUS = "0")' , 'BR_VERMELHO'  },;
						  { '(Z01->Z01_STATUS = "1")' , 'BR_VERDE'  } }
	Private aRotina		:= {{ 'Pesquisar'			, 'AxPesqui'		, 0, 1 ,, .F. } ,;
							{ 'Visualizar'			, 'U_GA010Con(2)'	, 0, 2 } ,; 
							{ 'Incluir'				, 'U_GA010Con(3)'	, 0, 3 } ,; 
							{ 'Alterar'				, 'U_GA010Con(4)'	, 0, 4 } ,; 
							{ 'Excluir'				, 'U_GA010Con(5)'	, 0, 5 } ,;
							{ 'Legenda'				, 'U_GA010LEG()'	, 0, 6 } }

    // Valida��o - Usu�rio tem que ser administrador (antes de entrar na tela principal)
    If !(FWIsAdmin( __cUserID ) )
        MsgStop(' O usu�rio ' + __cUserID + ' n�o pertence ao grupo de administradores!')
        Return
    Endif

    dbSelectArea("Z01")
    dbSetOrder(1)
    mBrowse(6,1,22,75,"Z01",,,,,,aCores)

Return



// *************************************************************
// ------------ Fun��o para display das legendas ---------------
// *************************************************************
User Function GA010LEG()

    BrwLegenda(cCadastro,"Legenda", {{"BR_VERDE" 	,"Demanda Ativa"},;
									 {"BR_VERMELHO"	,"Demanda Inativa"}})

Return



// *************************************************************
// ----------- Fun��o para tratamento de opera��es -------------
// *************************************************************
User Function GA010Con( nOpc )

    Local nOpcRet := 0  //Vari�vel usada para armazenar o retorno da opera��o de inclus�o
    //Array contendo os campos a serem apresentados na tela
    Local aAcho := {	'Z01_NUM', ;
                        'Z01_STATUS', ;
                        'Z01_TITULO', ;
                        'Z01_RESP', ;
                        'Z01_NOMRES', ;
                        'Z01_REQUE', ;
                        'Z01_NOMREQ', ;
                        'Z01_DTINI', ;
                        'Z01_DTFIM', ;
                        'Z01_QTDHR', ;
                        'Z01_DESC' }

    // Visualiza��o
    If nOpc == 2
        AxVisual("Z01",Z01->(RecNo()), 2, aAcho )
    // Inclus�o
    ElseIf nOpc == 3
        nOpcRet := AxInclui("Z01",,3, aAcho ,"U_GA010Ini()", aAcho ,"U_GA010TOk()",,,,,,, .F. )
    // Altera��o
    ElseIf nOpc == 4
        AxAltera("Z01",Z01->(RecNo()),4,, aAcho ,,,"U_GA010TOk()" )
    // Exclus�o
    ElseIf nOpc == 5
        AxDeleta("Z01",Z01->(RecNo()),5)
    Else
        MsgStop("C�digo de opera��o inv�lido! Cod: " + cValToChar(nOpc), "Erro")
    EndIf
    
    // Controle de numera��o
    If nOpcRet == 1  //Caso seja OK o retorno
        ConfirmSX8()
    ElseIf nOpcRet == 3
        RollbackSX8()
    EndIf

Return



// *************************************************************
// --------- Fun��o para valida��o final de opera��o -----------
// *************************************************************
User Function GA010TOk()
    
    Local lRet := .T.

    If DtoS(M->Z01_DTFIM) <= DtoS(dDataBase) .AND. M->Z01_STATUS == "1"
        If MsgYesNo("A data final j� passou, mas o status segue como ativo. Deseja ajustar para inativo?")
            M->Z01_STATUS := "0"
        EndIf
    EndIf

Return lRet



// *************************************************************
// ---------- Fun��o para inicializa��o do AxInclui ------------
// *************************************************************
User Function GA010Ini()
    // Alimenta o campo do n�mero automaticamente pelo controle de numera��o do Protheus
    M->Z01_NUM := GetSXEnum("Z01", "Z01_NUM")
Return



// *************************************************************
// ------- Fun��o para valida��es de campos (X3_USRVLD) --------
// *************************************************************
User Function GA010Vld( cCampo )

    Local lRet := .T.

    Do Case
        // Valida��o do campo de Data Inicial
        Case cCampo == "Z01_DTINI"
            // Se a data inicial informada for anterior ao m�s corrente E estiver bloqueada via par�metro
            If DtoS(M->Z01_DTINI) < Left( DtoS(dDataBase), 6 ) + "01" .AND. GetMV("MV_Z01_DMV")
                MsgAlert("A data inicial n�o pode ser anterior ao m�s vigente!")
                lRet := .F.
            EndIf
        // Valida��o do campo de Data Final
        Case cCampo == "Z01_DTFIM"
            If DtoS(M->Z01_DTFIM) < DtoS(M->Z01_DTINI)
                MsgAlert("A data final n�o pode ser anterior a data inicial!")
                lRet := .F.
            EndIf
    EndCase

Return lRet





