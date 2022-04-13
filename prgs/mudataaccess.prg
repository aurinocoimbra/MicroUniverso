************************************************
* MICROUNIVERSO
*************************************************
*
* [ C�digo fonte ]
* MUDataAccess.PRG
*
* [ Descri��o ]
* Defini��o da estrutura do banco de dados
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
***************************************************************
#INCLUDE "INCLUDE\MUCONST.H"


FUNCTION DB_SQL_CONNECT( cUser, cPwd, cTypeConnection, cIP_Server, cDataBase, lRetNewConnection, lShowErrorMessage, cPorta )

 LOCAL ARRAY laError[1]
 LOCAL oErr As Exception 
 LOCAL nConnection, nOldDBConn
 
 SQLSETPROP(0, "DISPLOGIN", DB_PROMPTNEVER  )
 
 lRetNewConnection = IIF( TYPE( 'lRetNewConnection' ) == "L", lRetNewConnection, .F. )
 lShowErrorMessage = IIF( TYPE( 'lShowErrorMessage' ) == "L", lShowErrorMessage, .T. )
 cPorta = IIF( TYPE( 'cPorta' ) != "C", "3306", cPorta )
 
 cMessage = ""
  
 nConnection = 0
 nOldDBConn = 0

 oWhait = CREATEOBJECT( "acWhait", "Aguarde... Estabelecendo conex�o com o servidor de dados..." )
 
 TRY
 
   DO CASE
     CASE cTypeConnection == "1" && MySQL
       *"Connect Timeout=30" + ";" 
       *nConnection = SQLSTRINGCONNECT( "DRIVER={MySQL ODBC 5.1 Driver};"+
		oWhait.Show      
       nConnection = SQLSTRINGCONNECT( "DRIVER={MySQL ODBC 8.0 ANSI Driver};"+;
                              "UID="+cUser + ";"+ ;
                              "Persist Security=true" + ";" + ;
                              "Convet Zero Datetime=true" + ";" + ;
                              "Allow Zero Datetime=true" + ";" + ;
                              "PWD="+cPwd + ";" + ;
                              "OPTION=0;"+;
                              "PORT="+cPorta +";"+;
                              "STMT=;"+;
                              "DATABASE="+cDataBase+";" + ;
                              "SERVER="+cIP_Server,.T.)
       
       IF !lRetNewConnection THEN
         gDbConnection = nConnection 
       ENDIF  
       
     CASE cTypeConnection == "2" && FireBird 1.5
       nConnection = SQLSTRINGCONNECT( "DRIVER=FireBird/InterBase(r) Driver;"+;
                              "UID="+cUser + ";" + ;
                              "PWD="+cPwd + ";" + ;
                              "PORT=3050" + ";" + ;
                              "DBNAME=localhost:"+cDatabase + ";" ;
                             )
       IF ( nConnection < 0 ) THEN
         AERROR( laError )
         cMessage = laError[ 1, 2 ]
         THROW oErr
       ENDIF          
                             
                             *"DATABASE="+cIP_Server+":c:\FireBird\CEP.FDB"
     CASE cTypeConnection == "3" && SQL Server 2005, Enterprise, Express ...
       gDbConnection = SQLSTRINGCONNECT( "DRIVER={SQL Server};"+;
                              "SERVER="+cIP_Server + ";" + ;
                              "DATABASE="+cDataBase+";" + ;
                              "UID="+cUser + ";"+ ;
                              "PWD="+cPwd + ";" + ;
                              "Persist Security Info=True"  )
                              
     CASE cTypeConnection == "4" && IBM DB2 Express-C
        *Provider=IBMDADB2;Database=sample;HOSTNAME=db2host; PROTOCOL=TCPIP;PORT=50000;uid=myUserName;pwd=myPwd; 
        *"driver={IBM DB2 ODBC DRIVER};Database=myDbName;hostname=myServerName;
        *port=myPortNum;protocol=TCPIP; uid=myUserName; pwd=myPwd"                            
       gDbConnection = SQLSTRINGCONNECT( "DRIVER={IBM DB2 ODBC DRIVER};"+;
                              "DATABASE=Dados;" + ;
                              "HOSTNAME=NOTEBOOK;"+;
                              "PORT=50000;"+;
                              "PROTOCOL=TCPIP;"+;
                              "UID="+cUser + ";"+ ;
                              "PWD="+cPwd )
     CASE cTypeConnection == "5" && Oracle
      
       gDbConnection = SQLSTRINGCONNECT( "Driver={Oracle em OraDb11g_home1};"+;
                              "dbq=10.1.1.20:1521/OraDb11g_home1;" + ; 
                              "Uid="+cUser + ";"+ ;
                              "Pwd="+cPwd  )
       nOldDBConn = gDbConnection
       =MESSAGEBOX(STR(gDbConnection))                       
                              &&+cIP_Server + ";" + ;
     CASE cTypeConnection == "6"
       gDbConnection = SQLSTRINGCONNECT( "DRIVER={Microsoft Access Driver (*.mdb,*.accdb)};"+;
                      "Dbq=d:\Access2007\dados.accdb;Exclusive=1;Uid=;Pwd=")
                                 
     CASE cTypeConnection == "7"  && SQL Anywhere 10
         gDbConnection = SQLSTRINGCONNECT( "DRIVER=SQL Anywhere 10;" + ; 
          "DefaultDir=10.0.0.120\dbpath\\;"+;
          "Dbf=10.0.0.120\\palmOS\siaj\\dados.db;" + ;
          "Uid="+cUser+";" + ;
          "Pwd="+cPwd+";"+;
          "Dsn=" )  
     CASE cTypeConnection == "8" && Firebird/Interbase(r)
       IF !FILE(cDataBase)
         MESSAGEBOX("Arquivo n�o existe: " + cDataBase )
       ENDIF
       nConnection = SQLSTRINGCONNECT( "DRIVER={Firebird/InterBase(r) driver};"+;
                              "UID="+cUser + ";"+ ;
                              "PWD="+cPwd + ";" + ;
                              "DBNAME="+cDataBase+";" )
                              *"PORT=3050;"+;
       *"SERVER="+cIP_Server,.T.
       *IF !lRetNewConnection THEN
       *  gDbConnection = nConnection 
       *ENDIF  
       IF ( nConnection < 0 ) THEN
         AERROR( laError )
         cMessage = laError[ 1, 2 ]
         THROW oErr
       ENDIF          
       
     OTHERWISE
   ENDCASE                             
   
   IF ( gDbConnection < 0 ) THEN
      AERROR( laError )
      cMessage = laError[ 1, 2 ]
      THROW oErr
   ENDIF 
   
 CATCH TO oErr
   
   IF lShowErrorMessage THEN
   
	   cMsgErr = ""
	   nTotErr = ALEN(laError,2)
       
       IF ALEN(laError,2) > 0 THEN	   
         DO CASE
           CASE laError[ 1, 5 ] == 1045 
             =MESSAGEBOX( "N�o foi poss�vel conectar ao servidor, verifique o nome do usu�rio/senha.","Aten��o" )
             *EXIT
         ENDCASE       
	   ENDIF
	   
	   *=MESSAGEBOX(STR(laError[1,5]))
	   
	   FOR nX = 1 TO nTotErr
	     cMsgErr = cMsgErr + SF_STRING_CONVERT( laError[ 1, nX ] ) + CHR(13)+CHR(10)
	   NEXT
	   
	   *MESSAGEBOX( cMsgErr, 0 + 16, "..:: Erro SQL ::.." )

	  cScript = "" + CRLF   
	  cScript = cScript +  " Script do Erro em: " + DTOC( DATE() ) + " Hora: " + TIME() + CRLF
	  cScript = cScript +   "-----------------------------------------------------" + CRLF 
	  cScript = cScript +   "     Erro : " + STR(oErr.ErrorNo) + CRLF 
	  cScript = cScript +   "    Linha : " + STR(oErr.LineNo)  + CRLF 
	  cScript = cScript +   "Procedure : " + oErr.Procedure + CRLF 
	  cScript = cScript +   " Detalhes : " + oErr.Details  + CRLF 
	  cScript = cScript +   "    Nivel : " + STR(oErr.StackLevel) + CRLF 
	  cScript = cScript +   "   Linhas : " + oErr.LineContents + CRLF 
	  cScript = cScript +   "    Valor : " + SF_STRING_CONVERT(oErr.UserValue) + CRLF 
	  
	  *=MESSAGEBOX(STR(gDbConnection) + " " + cTypeConnection)                       
	  IF cTypeConnection == "5" AND nOldDBConn > 0 THEN
	    gDbConnection = nOldDBConn
	  ELSE
	    MESSAGEBOX( cMessage + cMsgErr + cScript, 0+48, "Erro de Conex�o")
	  ENDIF  
	  
  ENDIF    
  
 FINALLY
 ENDTRY

 oWhait.Release()      

 IF nConnection <= 0 THEN
   RETURN .F.
 ENDIF
 
 IF lRetNewConnection THEN
   RETURN nConnection   
 ENDIF

 IF gDbConnection < 0 THEN
   RETURN .F.
 ENDIF
 
 && SQLCONNECT( "SAC" )
 
 
   * Somente em conexoes via ODBC
   * =DBSETPROP(gDbConnection,"Connection","Asynchronous",.T.)
 
ENDFUNC

FUNCTION SQL_EXEC( cSQLString, cCursor, aCount, lShowSqlErrorMessage, lShowWait )
 
 LOCAL lSuccess, cMessage
 LOCAL oErr As Exception, oSuccess as Exception 
 LOCAL ARRAY laError[1]
 
 lSuccess = .F.
 cMessage = ""
 
 cCursor              = IIF( VARTYPE( cCursor ) <> "C", "", cCursor )
 lShowSqlErrorMessage = IIF( VARTYPE( lShowSqlErrorMessage ) <> "L" OR PCOUNT() < 5, .T., lShowSqlErrorMessage )
 *cSQLString           = LOWER( cSQLString )

 lShowWait            = IIF( VARTYPE( lShowWait ) <> "L" OR PCOUNT() < 4, .F., lShowWait )

 
 TRY
   nPCount = PCOUNT()
   IF PCOUNT() > 1 THEN
     IF USED(cCursor) AND !EMPTY(cCursor) THEN
       USE IN (cCursor)
     ENDIF
   ENDIF
   
   IF lShowWait THEN
  	 oWhait = CREATEOBJECT( "acWhait", "O sistema est� coletando dados... Por favor Aguarde..." )
	 oWhait.Show      
   ENDIF
   

   DO CASE
     CASE nPCount == 1 OR nPCount == 4
        lSuccess = SQLEXEC( gDbConnection, cSQLString ) > -1
     CASE nPCount == 2 OR nPCount == 5
        lSuccess = SQLEXEC( gDbConnection, cSQLString, cCursor ) > -1
        
        *IF lShowWait THEN
  	    *  SQLSETPROP( gDbConnection,"ASYNCHRONOUS",.T.)
	    *ENDIF
        *lSuccess = .F.
        *lnReply = -1
        *DO WHILE INKEY(.01) <> 27
        *  lnReply = SQLEXEC( gDbConnection, cSQLString, cCursor )
        *  DO CASE
        *    CASE lnReply == 0 && Recuperando dados
      	*      oWhait.Label1.Caption =  TIME()
        *      oWhait.Update()
        *    CASE lnReply < 0  && Ocorreu um erro durante a pesquisa
        *      SQLCANCEL(gDbConnection)
        *      EXIT
        *    CASE lnReply > 0 && Tudo ok.
        *      SQLCANCEL(gDbConnection)
        *      EXIT 
        *  ENDCASE 
        *ENDDO
        *lSuccess = lnReply > 0
        
     CASE nPCount == 3
        lSuccess = SQLEXEC( gDbConnection, cSQLString, cCursor, aCount ) > -1
     OTHERWISE   
   ENDCASE
   
   
   IF !lSuccess THEN
     AERROR( laError )
     cMessage = laError[ 1, 2 ]   
     IF lShowWait THEN    
       oWhait.Release()
     ENDIF
     THROW oErr
   ENDIF     
   
   IF lShowWait THEN    
     oWhait.Release()
   ENDIF

 CATCH TO oErr
    *lSuccess = .F.
    *_CLIPTEXT = cSQLString
    *MESSAGEBOX(cSQLString)
    IF !lSuccess THEN
    
      cMsgErr = ""

      IF !EMPTY(cSQLString)
        
        IF ALEN(laError,2) > 0 THEN
        
          DO CASE
            CASE INLIST( laError[ 1, 5 ] ,2005, 2006, 2013, 2014, 2015, 2055 ) OR ;
               laError[ 1, 1 ] == 1466 && Conexao perdida, handle invalido !!!
              IF MESSAGEBOX( "A conex�o foi perdida... Deseja reestabelecer a conex�o com o servidor ?",4+32,"Aten��o" ) == 6 THEN
                nTentativas = 1
                =SQLDISCONNECT(gDbConnection)
  			  oWhait = CREATEOBJECT( "acWhait", ;
				    "Estabelecendo conex�o com o servidor... " + ALLTRIM(STR(nTentativas))+" tentativa(s) ...")
				  oWhait.Show      
			    
			    DO WHILE INKEY(.01) <> 27
			    
 				     oWhait.Label1.Caption =  "Estabelecendo conex�o com o servidor... " + ALLTRIM(STR(nTentativas))+" tentativa(s) ..."
    
			      lSuccess = DB_SQL_CONNECT( "microuniverso", "123", "1", "191.223.232.45", "microuniverso",,.F. )
			      
                  nTentativas = nTentativas + 1
                  IF lSuccess THEN
					DO CASE
					    CASE nPCount == 1 OR nPCount == 4
					        lSuccess = SQLEXEC( gDbConnection, cSQLString ) > -1 && 1�
					    CASE nPCount == 2
					        lSuccess = SQLEXEC( gDbConnection, cSQLString, cCursor ) > -1 && 2�
					    CASE nPCount == 3
					        lSuccess = SQLEXEC( gDbConnection, cSQLString, cCursor, aCount ) > -1 && 3�
					    OTHERWISE   
					ENDCASE
                  ENDIF
                  IF lSuccess THEN
                    EXIT
                  ENDIF
			    ENDDO
                oWhait.Release()			    
                IF lSuccess THEN
				    =MESSAGEBOX( "A conex�o foi reestabelecida com sucesso.",0+48,"Aten��o" )
                    EXIT
				ENDIF                
              ENDIF
            CASE laError[ 1, 5 ] == 1062 
              IF MESSAGEBOX( "Erro na tentativa de duplica��o de dados."+CRLF+;
              "Click em <OK> para visualizar detalhes do erro.",1+16+256,"Aten��o" ) == 2
                EXIT
              ENDIF  
          ENDCASE  
          
        ENDIF
        
        lInsert    = AT( "INSERT", cSQLString ) > 0
        lUpdate    = AT( "UPDATE", cSQLString ) > 0
        lDelete    = AT( "DELETE", cSQLString ) > 0
        lSelect    = AT( "SELECT", cSQLString ) > 0
        lStoreProc = AT( "CALL", cSQLString ) > 0
        lCreateTable = AT( "CREATE TABLE", cSQLString ) > 0
        
        cMessage   =  ""
        
        DO CASE
          CASE lInsert
            cMessage = "Comando INSERT n�o executado."
            cMsgErr = cMsgErr + cMessage + CHR(13)+CHR(10)
          CASE lUpdate
            cMessage = "Comando UPDATE n�o executado."
            cMsgErr = cMsgErr + cMessage + CHR(13)+CHR(10)
          CASE lDelete
            cMessage = "Comando DELETE n�o executado."
            cMsgErr = cMsgErr + cMessage + CHR(13)+CHR(10)
          CASE lSelect
            cMessage = "Comando SELECT n�o executado."
            cMsgErr = cMsgErr + cMessage + CHR(13)+CHR(10)
          CASE lStoreProc
            cMessage = "Comando CALL (Store Procedure) n�o executado."
            cMsgErr = cMsgErr + cMessage + CHR(13)+CHR(10)
          CASE lCreateTable
            cMessage = "Comando CREATE TABLE n�o executado."
            cMsgErr = cMsgErr + cMessage + CHR(13)+CHR(10)
        ENDCASE  
        
        cMsgErr = cMsgErr + CHR(13)+CHR(10)
        
      ENDIF
      
      nTotErr = ALEN(laError,2)
      
      IF nTotErr > 0 THEN
        FOR nX = 1 TO nTotErr
          cMsgErr = cMsgErr + SF_STRING_CONVERT( laError[ 1, nX ] ) + CHR(13)+CHR(10)
        NEXT
      ELSE
        cMsgErr = cMsgErr + ALLTRIM(STR(oErr.ErrorNo)) + CHR(13)+CHR(10)
        cMsgErr = cMsgErr + oErr.Message + CHR(13)+CHR(10)
      ENDIF
      
      IF !ISNULL(cSQLString)
        cMsgErr = cMsgErr + CHR(13)+CHR(10) + cSQLString
      ENDIF
      
	  cScript = "" + CRLF   
	  cScript = cScript +  " Script do Erro em: " + DTOC( DATE() ) + " Hora: " + TIME() + CRLF
	  cScript = cScript +   "-----------------------------------------------------" + CRLF 
	  cScript = cScript +   "     Erro : " + STR(oErr.ErrorNo) + CRLF 
	  cScript = cScript +   "    Linha : " + STR(oErr.LineNo)  + CRLF 
	  cScript = cScript +   "Procedure : " + oErr.Procedure + CRLF 
	  cScript = cScript +   " Detalhes : " + oErr.Details  + CRLF 
	  cScript = cScript +   "    Nivel : " + STR(oErr.StackLevel) + CRLF 
	  cScript = cScript +   "   Linhas : " + oErr.LineContents + CRLF 
	  cScript = cScript +   "    Valor : " + SF_STRING_CONVERT(oErr.UserValue) + CRLF 
        
      FOR nX = 1 TO 100
        IF !EMPTY(ALIAS(nX))
          IF nX == 1
            cMsgErr = cMsgErr + CHR(13)+CHR(10) + ;
                                "--------------------------" + CHR(13)+CHR(10) + ; 
                                "< Area em uso   >" + CHR(13)+CHR(10) + ;
                                "--------------------------" + CHR(13)+CHR(10)
          ENDIF
          cMsgErr = cMsgErr + ALIAS(nX)+CHR(13)+CHR(10) 
        ELSE
          EXIT  
        ENDIF  
      NEXT
      
      IF TYPE( '_screen.frmError' ) == 'O'
        =MESSAGEBOX( cMessage, 0+48, "Erro de Conex�o")
      ELSE
        IF lShowSqlErrorMessage THEN
	       MESSAGEBOX( cMessage + cMsgErr + cScript, 0+48, "Erro de Conex�o")
          *DO FORM frmError WITH cMessage, cMsgErr + cScript
        ENDIF  
      ENDIF  
      
      *MESSAGEBOX( cMsgErr+cSQLString, 0 + 16, "..:: Erro SQL ::.." )
      
   ENDIF
    * oErr.UserValue = "Nested CATCH message: Unable to handle"
    *  ?[: Nested Catch! (Unhandled: Throw oErr Object Up) ]  
    *  ?[  Inner Exception Object: ]
  
   * =MESSAGEBOX(oErr.Message)
  
  FINALLY
  ENDTRY
  
  RETURN lSuccess
  
ENDFUNC

****************************
* SQL_EXEC_FOUND() 
**************************************************************
FUNCTION SQL_EXEC_FOUND( cSQLCommand, cCursor )
 LOCAL ARRAY aCount(1)
 LOCAL lFound, cAlias
 
 IF PCOUNT() < 2 THEN
   cCursor = ""
 ENDIF
 
 cAlias   = ALIAS()
 
 lExecute = SQL_EXEC( LOWER(cSQLCommand), cCursor, @aCount )
 lFound   = IIF( ALEN(aCount,2)>0, aCount(1,2)>0,.F.)
 
 IF !EMPTY(cAlias) AND cAlias <> ALIAS() THEN
   SELECT (cAlias)
 ENDIF
 
 RETURN lFound
      
ENDFUNC










