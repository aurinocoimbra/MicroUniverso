*************************************************
* MICROUNIVERSO
*************************************************
*
* [ C�digo fonte ]
* MUUtility.PRG
*
* [ Descri��o ]
* Regras gerais de inicializa��o do sistema
*
* [ Autor ]
* Aurino Coimbra	
*
*
* 09-Abril-2022 [ Aurino Coimbra ]
* Revis�o
*
* 02-Abril-2022 [ Aurino Coimbra ]
* Cria��o do c�digo
*
FUNCTION ENDAPP()
  
  WITH _SCREEN
  
    .BackColor   = _CFnScreenBackColor  
    .ForeColor   = _CFnScreenForeColor 
    .Picture     = ""
    .BorderStyle = 3
    *.WindowState = 0
    .Icon        = ""
    
  ENDWITH
  
  IF TYPE("_screen.oImageLogo")= "O"   
    _SCREEN.RemoveObject( "oImageLogo" )
  ENDIF
  
  IF TYPE("_screen.oImageBack")= "O"   
    _SCREEN.RemoveObject( "oImageBack" )
  ENDIF
  
  IF TYPE("_screen.imgSystemStatus") == "O" THEN
    _screen.RemoveObject("imgSystemStatus")  
  ENDIF
  
  IF TYPE("_screen.oPopupMenu") == "O" THEN
    _screen.RemoveObject("oPopupMenu")  
  ENDIF

  IF TYPE("_screen.oActiveForms") == "O" THEN
    _screen.RemoveObject("oActiveForms")  
  ENDIF
  
  IF TYPE("_screen.objClock") == "O" THEN
    _screen.RemoveObject("objClock")  
  ENDIF

  IF TYPE("_screen.oStatusBar") == "O" THEN
    _screen.RemoveObject("oStatusBar")  
  ENDIF
    
  IF TYPE( 'oApp' ) == 'O'
    IF oApp.Project_Manager THEN
      ACTIVATE WINDOW "Project Manager"
    ENDIF  
  ENDIF
  
  IF TXNLEVEL() > 0
    *ROLLBACK
    *END TRANSACTION
  ENDIF
  
	IF TYPE('oMenu') == "O" THEN
		FOR EACH oItem IN oMenu.Controls
			_SCREEN.RemoveObject(oItem.Name)
		ENDFOR
	ENDIF
  
    
  IF gDbConnection > 0 THEN
    *=MESSAGEBOX("Desconectado!" )
    =SQLDISCONNECT( gDbConnection )
  ENDIF

  RELEASE oApp, oError, oScreen, oMenuAcess, oMenu, oSysConfig
  RELEASE gDataBase

  CLOSE DATA ALL
  CLOSE DATABASE ALL

  SET SYSMENU TO DEFAULT 

  CLEAR DLLS
  RELEASE ALL EXTENDED
 *CLEAR ALL

  ON SHUTDOWN
  ON ERROR
  ON KEY 
  
ENDFUNC

FUNCTION OnShutdown()
 LOCAL cForm
 IF _screen.formCount > 1 THEN
   =MESSAGEBOX( "Todas as janelas devem ser fechar antes de sair do sistema !!!",0+48,"Aten��o")
 ELSE
   IF MESSAGEBOX( "Sair do Sistema ?",4+32+256,"Sair" ) == 6
     
     ON SHUTDOWN
     ON ERROR
     
     CLEAR EVENTS            
     SET SYSMENU TO default
   ENDIF 
 ENDIF
ENDFUNC

FUNCTION SF_STRING_CONVERT( xValue )
  DO CASE
    CASE VARTYPE(xValue)=="N"
       xValue = ALLTRIM(STR(xValue))
    CASE VARTYPE(xValue)="X"
       xValue = ".NULL."   
    CASE VARTYPE(xValue)=="L"
       xValue = IIF( xValue, ".T.",".F.")
  ENDCASE
  RETURN xValue   
ENDFUNC

**
** SQLValue() - Retorna o formato correto para SQL
**
FUNCTION SQLValue( xValue, xDefault )
 LOCAL cType, nPos
 cType = TYPE( 'xValue' )
 cTypeDefault = TYPE( 'xDefault' )
 DO CASE
   CASE cType $ 'G-B' && Salvando imagens
   CASE cType == 'T' && Datetime
     xValue = "'" + DTOC( TTOD( xValue ) ) + "'"
   CASE cType == 'L'
     xValue = IIF( xValue, '1', '0' )
   CASE cType == 'D'
     IF EMPTY(xValue) OR ISNULL(xValue)
       xValue = "'0000-00-00'"
     ELSE  
       xValue = "'"+SQLDTOC( xValue )+"'"
     ENDIF  
   CASE cType $ 'N-I'
     IF ISNULL(xValue) THEN
       xValue = '0'
     ELSE  
       xValue = ALLTRIM(TRANSFORM(xValue))  
       IF AT( ",", xValue ) > 0 
         xValue = STRTRAN( xValue, ",", "." )
       ENDIF
     ENDIF  
   CASE cType == 'C' 
     IF AT( "'", xValue ) > 0 
       IF AT( '"', xValue ) > 0 
         xValue = "'" + xValue + "'"
       ELSE  
         xValue = '"' + xValue + '"'
       ENDIF
     ELSE
       IF ISNULL(xValue) THEN
         xValue = ""
       ENDIF
       xValue = "'" + ALLTRIM(xValue) + "'"
     ENDIF  
   CASE cType == 'M'  
     xValue = "'" + ALLTRIM(xValue) + "'"
   OTHERWISE
     =MESSAGEBOX(cType,0+48,"Erro na convers�o: SQLValue()")
      xValue = ''
 ENDCASE      
     
RETURN xValue

**
** Converte valor inteiro para caractere
**
FUNCTION ITOC( iNumber )
 iNumber = ALLTRIM(STR(iNumber))
RETURN iNumber


**
** Converte o padrao data dd/mm/aaaa em aaaa-mm-dd
**
FUNCTION SQLDTOC( dDate )
  LOCAL cYear, cMonth, cDay
  IF EMPTY(dDate)
    cData = ""
  ELSE
    cYear  = STR( YEAR( dDate ), 4 )
    cMonth = STRZERO( MONTH( dDate ), 2 )
    cDay   = STRZERO( DAY( dDate ), 2 )
    cData = cYear + "-" + ALLTRIM( cMonth ) + "-" + ALLTRIM( cDay )
  ENDIF
RETURN cData

**
** StrZero( <nValue>, <nHeight> )
**
FUNCTION STRZERO()
 PARAMETERS nValue, nHeight
 IF !(TYPE("nValue") $ "N-Y") OR TYPE( "nHeight" ) <> "N" THEN
   RETURN "ERRO"
 ELSE
   RETURN PADL( ALLTRIM( STR( nValue ) ), nHeight, "0" )
 ENDIF
ENDFUNC