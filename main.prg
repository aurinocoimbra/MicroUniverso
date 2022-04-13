************************************************************************************************
* MICROUNIVERSO
************************************************************************************************
*
* [ Código fonte ]
* MAIN.PRG
*
* [ Descrição ]
* Programa principal de acesso ao sistema.
*
* [ Autor ]
* Aurino Coimbra	
*
* 
* [ Última atualização ] 
* Nota: As datas de atualização deve obedecer uma ordem decrescente
*
* 09-Abril-2022 [Aurino Coimbra]
* Revisão e correção de bugs
*
* 02-Abril-2022 [Aurino Coimbra]
* Criação do código
*
#INCLUDE "INCLUDE\MUCONST.H"

CLEAR DLLS
CLOSE DATABASE ALL 

CLEAR
CLEAR PROGRAM
CLEAR TYPEAHEAD

SET LOGERRORS ON  
SET DELETE    ON
SET CONFIRM   ON
SET BELL      ON
SET CENTURY   ON 
SET SAFETY    OFF   

SET CONSOLE   OFF
SET NOTIFY    OFF
SET VIEW      OFF
SET TALK      OFF NOWINDOW
SET EXACT     OFF    

SET DATE     TO DMY
SET CENTURY  TO 19 ROLLOVER 10
SET CURRENCY TO 'R$'
   
SET EXCLUSIVE  OFF
SET REPROCESS  TO AUTOMATIC
SET REFRESH    TO 0
SET MULTILOCKS ON
SET LOCK       ON       
SET MESSAGE    TO
SET BLOCKSIZE  TO 0  && Diminuir o tamanho do buffer para tabelas com campo memo.

SET STATUS OFF
SET STATUS BAR OFF

SET SYSMENU SAVE
SET SYSMENU TO
SET SYSMENU OFF

SET DECIMALS TO 3

SET SEPARATOR TO "."
SET POINT TO ","

**
** Utilizado para remover áreas de formulário com base em cores
** O formulário de LOGIN exemplifica isso.
**
DECLARE LONG CreateRectRgn IN "gdi32"  LONG X1, LONG Y1, LONG X2, LONG Y2
DECLARE LONG CombineRgn    IN "gdi32"  LONG hDestRgn, LONG hSrcRgn1, LONG hSrcRgn2, LONG nCombineMode
DECLARE LONG DeleteObject  IN "gdi32"  LONG hObject
DECLARE LONG SetWindowRgn  IN "user32" LONG HWND, LONG hRgn, Integer bRedraw

LOCAL lProjectManager

lProjectManager = .F.

IF WVISIBLE("Project Manager") THEN
  HIDE WINDOW ("Project Manager")
  lProjectManager = .T.
ENDIF

**
** Remove variáveis globais da memória
**
RELEASE oApp, oScreen, oImageLogo, oMenu, gDataBase, gDbConnection

**
** Declara variáveis globais
**
PUBLIC oApp, oScreen, oImageLogo, oMenu, gDataBase, gDbConnection
gDbConnection   = 0
**
** Configurações de tela
**
PUBLIC _CFnScreenBackColor, _CFnScreenForeColor

=SET_CURRENT_PATH()

oScreen  = NEWOBJECT( "oScreenEvents" )
oApp = CREATEOBJECT("oApplication")

_SCREEN.AddObject("oImageLogo", "imageLogo")

IF TYPE("_SCREEN.oImageLogo") == "O"
	_SCREEN.oImageLogo.Visible = .T.
ENDIF


IF TYPE('oMenu') != "O" THEN
	
	oMenu = CREATEOBJECT("oMenu")
	
	oMenu.AddItem("Usuários", "Cadastro de usuários", "frmUsuarios", "user_32.png")
	oMenu.AddItem("Nota de Compra", "Pedido de Compra", "frmpedcompra","buying_32.png")
	oMenu.AddItem("Hist. de Aprovação", "Histórico de visto/aprovação", "frmHistAprov","historic_32.png")
	oMenu.AddItem("Faixa Financeira", "Faixa financeira padrão de autorização", "frmFaixaFin","finance_32.png")
	oMenu.AddItem("Tabelas", "Tabelas do sistema", "frmTabelas", "tables_32.png")
	
ENDIF

nLeft = (_SCREEN.Width - (oMenu.ControlCount * ( 128 + 5))) / 2 

FOR EACH oItem IN oMenu.Controls
	
	_SCREEN.AddObject(oItem.Name, "shapeButton" )
	
	mnuItem = EVALUATE("_SCREEN." + oItem.Name)
	
	mnuItem.TextButton = oItem.LabelText
	mnuItem.ImageButton = oItem.ImageFile
	mnuItem.FormName = oItem.FormName
	mnuItem.Top = _screen.Height / 2
	
	mnuItem.Left = nLeft
	mnuItem.Width = 128
	mnuItem.Height = 96
	mnuItem.Refresh()
	mnuItem.Visible = .T.
	
	nLeft = nLeft + 128 + 5
    
    BINDEVENT( mnuItem, "OnMouseClick", oScreen, "OnMenuItemClick")
	
ENDFOR

IF TYPE( 'oApp' ) == 'O' THEN
	
	MUCreateVirtualDatabase()
	 
	 ON SHUTDOWN DO OnShutDown

	 _CFnScreenBackColor = _Screen.BackColor
	 _CFnScreenForeColor = _Screen.ForeColor

    IF WVISIBLE( "Project Manager" )
      DEACTIVATE WINDOW "Project Manager"
      oApp.Project_Manager = .T.
    ELSE
      oApp.Project_Manager = lProjectManager
    ENDIF  

      BINDEVENT( _SCREEN, "Activate", oScreen, "Activate")
      BINDEVENT( _SCREEN, "MouseDown", oScreen, "MouseDown")
      BINDEVENT( _SCREEN, "KeyPress", oScreen, "KeyPress")
      BINDEVENT( _SCREEN, "Resize", oScreen, "Resize")

  oApp.Show

  ENDAPP()
  
ENDIF



*****
* Configuração de acesso a arquivos do sistema
*************************************
FUNCTION SET_CURRENT_PATH()
  LOCAL lcSys16, ;
        lcProgram

  lcSys16 = SYS(16)
  lcProgram = SUBSTR(lcSys16, AT(":", lcSys16) - 1)

  CD LEFT(lcProgram, RAT("\", lcProgram))

  IF RIGHT(lcProgram, 3) = "FXP"
    *CD ..
  ENDIF
  SET PATH TO ENTITY, CONTROLES, FORMS, PRGS, IMAGE
     
  SET PROCEDURE TO ;
  		MUUtility, ;
  		MUDataAccess, ;				&& Controle de acesso ao banco de dados
  		MUMenuUtility, ;			&& Controle de Menus
  		MUEntityFramework,	;		&& Definição do objetos para o banco de dados	
  		MUEntityDefinitions			&& Função de criação da estrutura do banco de dados
  		
  SET CLASSLIB TO CONTROLES

  
ENDFUNC