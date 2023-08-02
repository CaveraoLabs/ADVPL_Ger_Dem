#include 'rwmake.ch'
#include 'protheus.ch'

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: GABA010      || Autor: Gabriel Leão     		|| Data: 01/08/23  ||
||-------------------------------------------------------------------------||
|| Descrição: Gerenciamento de Demandas		                               ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/ 
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

    // Validação - Usuário tem que ser administrador (antes de entrar na tela principal)
    If !(FWIsAdmin( __cUserID ) )
        MsgStop(' O usuário ' + __cUserID + ' não pertence ao grupo de administradores!')
        Return
    Endif

    dbSelectArea("Z01")
    dbSetOrder(1)
    mBrowse(6,1,22,75,"Z01",,,,,,aCores)

Return



// *************************************************************
// ------------ Função para display das legendas ---------------
// *************************************************************
User Function GA010LEG()

    BrwLegenda(cCadastro,"Legenda", {{"BR_VERDE" 	,"Demanda Ativa"},;
									 {"BR_VERMELHO"	,"Demanda Inativa"}})

Return



// *************************************************************
// ----------- Função para tratamento de operações -------------
// *************************************************************
User Function GA010Con( nOpc )

    Local nOpcRet := 0  //Variável usada para armazenar o retorno da operação de inclusão
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

    // Visualização
    If nOpc == 2
        AxVisual("Z01",Z01->(RecNo()), 2, aAcho )
    // Inclusão
    ElseIf nOpc == 3
        nOpcRet := AxInclui("Z01",,3, aAcho ,"U_GA010Ini()", aAcho ,"U_GA010TOk()",,,,,,, .F. )
    // Alteração
    ElseIf nOpc == 4
        AxAltera("Z01",Z01->(RecNo()),4,, aAcho ,,,"U_GA010TOk()" )
    // Exclusão
    ElseIf nOpc == 5
        AxDeleta("Z01",Z01->(RecNo()),5)
    Else
        MsgStop("Código de operação inválido! Cod: " + cValToChar(nOpc), "Erro")
    EndIf
    
    // Controle de numeração
    If nOpcRet == 1  //Caso seja OK o retorno
        ConfirmSX8()
    ElseIf nOpcRet == 3
        RollbackSX8()
    EndIf

Return



// *************************************************************
// --------- Função para validação final de operação -----------
// *************************************************************
User Function GA010TOk()
    
    Local lRet := .T.

    If DtoS(M->Z01_DTFIM) <= DtoS(dDataBase) .AND. M->Z01_STATUS == "1"
        If MsgYesNo("A data final já passou, mas o status segue como ativo. Deseja ajustar para inativo?")
            M->Z01_STATUS := "0"
        EndIf
    EndIf

Return lRet



// *************************************************************
// ---------- Função para inicialização do AxInclui ------------
// *************************************************************
User Function GA010Ini()
    // Alimenta o campo do número automaticamente pelo controle de numeração do Protheus
    M->Z01_NUM := GetSXEnum("Z01", "Z01_NUM")
Return



// *************************************************************
// ------- Função para validações de campos (X3_USRVLD) --------
// *************************************************************
User Function GA010Vld( cCampo )

    Local lRet := .T.

    Do Case
        // Validação do campo de Data Inicial
        Case cCampo == "Z01_DTINI"
            // Se a data inicial informada for anterior ao mês corrente E estiver bloqueada via parâmetro
            If DtoS(M->Z01_DTINI) < Left( DtoS(dDataBase), 6 ) + "01" .AND. GetMV("MV_Z01_DMV")
                MsgAlert("A data inicial não pode ser anterior ao mês vigente!")
                lRet := .F.
            EndIf
        // Validação do campo de Data Final
        Case cCampo == "Z01_DTFIM"
            If DtoS(M->Z01_DTFIM) < DtoS(M->Z01_DTINI)
                MsgAlert("A data final não pode ser anterior a data inicial!")
                lRet := .F.
            EndIf
    EndCase

Return lRet





