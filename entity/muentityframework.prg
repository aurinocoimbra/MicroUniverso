*************************************************
* MICROUNIVERSO
*************************************************
*
* [ C�digo fonte ]
* MUEntityFramework.PRG
*
* [ Descri��o ]
* Defini��o da estrutura do banco de dados
*
* [ Autor ]
* Aurino Coimbra	
*
* [ Nota t�cnica ]
*
* oDataBase - Banco de dados do sistema
* oDbTable	- Tabela
* oDbField	- Campos
*
* Como funciona?
*
*	[->] oDatabase [Banco de dados]
*			|	
*			 -> oDbTable [Tabela]
*					|
*					 -> oDbField [Coluna]
*
* 02-Abril-2022	[Aurino Coimbra]
* Cria��o do c�digo

* 08-Abril-2022	[Aurino Coimbra]
* Revis�o do c�digo, sem mudan�a significativas
*
***********************************************************
#INCLUDE "INCLUDE\MUCONST.H"

DEFINE CLASS oDataBase AS Custom

	*
	* Configura��o para v�rios banco de dados
	* 1 - SQL Server, 2 - MySQL, 3 - Oracle, 4 - PostgreSQL
	*
	* Nesse projeto foi configurado apenas um banco de dados devido ser apanas para teste na empresa MICROUNIVERSO
	* 
	*
	DataBaseType = DB_MYSQL

	**
	** Adiciona uma tabela ao banco de dados
	*******************************************************
	FUNCTION AddTable( cName )
		LOCAL cCommand
		
		THIS.AddObject( cName, "oDbTable" )
		
		RETURN EVALUATE( "THIS." + cName )
	ENDFUNC
	
	*****
	** Adiciona um campo a tabela selecionada
	*******************************************************
	FUNCTION AddField( oTable, cField, cType, nWidth, nDecimal, cDescription, cComment, nFieldType)
	
		cField        = IIF( TYPE( "cField" )     == "C", cField, "Field"+ALLTRIM(STR(oTable.ControlCount+1))   )
		
	    cType         = IIF( TYPE( "cType" )        <> "C",  "C", cType        )
	    nWidth        = IIF( TYPE( "nWidth" )       <> "N",   10, nWidth       )
	    nDecimal      = IIF( TYPE( "nDecimal" )     <> "N",    0, nDecimal     )
	    cDescription  = IIF( TYPE( "cDescription" ) <> "C",   "", cDescription )
	    cComment      = IIF( TYPE( "cComment" ) 	<> "C",   "", cComment     )
	    nFieldType    = IIF( TYPE( "nFieldType" )   <> "N", DB_FIELD, nFieldType )
	    
	    TRY 
	    
	      oTable.AddObject( cField, "oDbField" )
	    
	    CATCH TO oErr
	      
	      =MESSAGEBOX( "Erro no campo -> " + cField + " Substituido por -> Field"+;
	         ALLTRIM(STR(oTable.ControlCount+1))+CHR(13)+CHR(10)+"Erro: "+oErr.Message,0+16,"Erro na cria��o da tabela!!!")
	      
	       cField  = "Field"+ALLTRIM(STR(oTable.ControlCount+1))   
	       oTable.AddObject( cField, "oDbTable" )
	      
	    FINALLY
	     
	      oField = EVALUATE( "oTable."+cField)
	    
	      oField.cType         = cType
	      oField.nWidth        = nWidth
	      oField.nDecimal      = nDecimal
	      oField.Description   = cDescription
	      oField.Comment       = cComment
	      oField.FieldType     = nFieldType
	      
	    ENDTRY
	    
	    RETURN oField	
	    
	ENDFUNC
	
ENDDEFINE

*************
* oDbTable
*
* Defini��o do objeto para tabelas do sistema
*
* 03-Abril-2022	[Aurino Coimbra]
* Cria��o do c�digo
***********************************************************
DEFINE CLASS oDbTable AS Custom

	TableName = ""
	Description = ""
	Comment = ""
	
	PROCEDURE INIT
	ENDPROC

	FUNCTION AddField( pName, pType, pWidth, pDecimal, pDescription, pComment, nFieldType )
		
        LOCAL oField
		
		pField	      = IIF( TYPE( "pName" ) == "C", pName, "Field"+ALLTRIM(STR(THIS.ControlCount+1))   )
	    
	    pType         = IIF( TYPE( "pType" )         <> "C",  "C", pType        )
	    pWidth        = IIF( TYPE( "pWidth" )        <> "N",   10, pWidth       )
	    pDecimal      = IIF( TYPE( "pDecimal" )      <> "N",    0, pDecimal     )
	    
	    pDescription  = IIF( TYPE( "pDescription" )  <> "C",  "", pDescription  )
	    pComment      = IIF( TYPE( "pComment" )      <> "C",  "", pComment      )
	    nFieldType    = IIF( TYPE( "nFieldType" )   <> "N", DB_FIELD, nFieldType )
	    
	    THIS.AddObject( pField, "oDbField" )
	    
	    oField = EVALUATE( "THIS."+pField)
	    
	    oField.cType        = pType
	    oField.nWidth       = pWidth
	    oField.nDecimal     = pDecimal
	    oField.Description	= pDescription
	    oField.Comment		= pComment
	    oField.nFieldType   = nFieldType
    
   		 RETURN oField
   		 
   	ENDFUNC
	
	FUNCTION GET_EMPTY_CURSOR( cCursor )
	    IF PCOUNT() = 0 THEN
	      cCursor = "crs" + THIS.Name 
	    ENDIF
	    LOCAL iCount
	    cSQLCommand = ""
	    FOR EACH aFields IN THIS.Controls 
	      DO CASE
	        CASE "C" $ aFields.cType
	          cSQLCommand = cSQLCommand + aFields.Name + " C("+ALLTRIM(STR(aFields.nLenght))+"), "
	        CASE "I" $ aFields.cType
	          cSQLCommand = cSQLCommand + aFields.Name + " I("+ALLTRIM(STR(aFields.nLenght))+"), "
	        CASE "N" $ aFields.cType
	          cSQLCommand = cSQLCommand + aFields.Name + " N("+ALLTRIM(STR(aFields.nLenght))+"), "
	        CASE aFields.cType == "L"
	          cSQLCommand = cSQLCommand + aFields.Name + " " + aFields.cType + "("+ALLTRIM(STR(aFields.nLenght))+"), "
	        CASE LEFT(aFields.cType,1) == "I"
	          cSQLCommand = cSQLCommand + aFields.Name + " I(4), "
	        CASE aFields.cType == "M"
	          cSQLCommand = cSQLCommand + aFields.Name + " Memo, "
	        CASE aFields.cType == "D"
	          cSQLCommand = cSQLCommand + aFields.Name + " D, "
	      ENDCASE
	    ENDFOR 
	    IF !EMPTY(cSQLCommand) THEN
	      cSQLCommand = "CREATE CURSOR " + cCursor + " ( " + SUBSTR( cSQLCommand, 1, LEN( cSQLCommand ) - 2 ) + " )"
	      *=MESSAGEBOX(cSQLCommand)
	      &cSQLCommand
	    ENDIF
	    RETURN cSQLCommand
	ENDFUNC
   	
   	FUNCTION GET_CREATE_TABLE( pDataBaseType )
	    
	    pDataBaseType   = IIF( TYPE( "pDataBaseType" ) <> "N",  DB_MYSQL, pDataBaseType )
	    sqlCommand		= ""

	    FOR EACH oField IN THIS.Controls
       		sqlCommand = sqlCommand + IIF(!EMPTY(sqlCommand), "," +  CRLF, "" ) + ;
       			LOWER(oField.Name) + " " + THIS.GET_SQL_TYPE( pDataBaseType, oField.cType, oField.nWidth, oField.nDecimal, oField.nFieldType ) 
	        *? oField.Name, oField.cType, oField.nWidth
	    ENDFOR
	    RETURN "CREATE TABLE IF NOT EXISTS " + LOWER(THIS.TableName) + " ( " + CRLF + sqlCommand + ")"
   	ENDFUNC
   	
    FUNCTION GET_SQL_UPDATE_COMMAND( cCursor, cCondition, lAddAll )
	    LOCAL cSQLCommand, oField, oErr As Exception, cField 
	    IF PCOUNT() < 3 THEN
	      lAddAll = .F.
	    ENDIF
	    cSQLCommand = ""
	    FOR iField = 1 TO FCOUNT( cCursor )
	      IF GETFLDSTATE( iField, cCursor ) = 2 OR lAddAll THEN 
	        *=MESSAGEBOX(FIELD(iField,cCursor) + " - > " + STR(GETFLDSTATE( "DataFinal", "crsContAss" )))       
	        TRY
	          cField      = FIELD( iField, cCursor )
	          oField      = EVALUATE("gDataBase." + PROPER(THIS.Name) + "." + PROPER( cField ))
	          cSQLCommand = cSQLCommand + cField + " = "
	          mValue = EVALUATE( cCursor+"."+cField )
	          cSQLCommand = cSQLCommand + SQLValue( mValue )  
	          cSQLCommand = cSQLCommand + ", "
	        CATCH TO oErr
	           *? "ERRO: " + oErr.Message
	        FINALLY
	        ENDTRY
	      ENDIF
	    ENDFOR        
	    IF !EMPTY( cSQLCommand ) THEN  
	      IF LEFT( cCursor, 3 ) == "crs" THEN
	        cCursor = SUBSTR( cCursor, 4 )
	        IF !USED(cCursor) THEN
	          cCursor = THIS.Name 
	        ENDIF
	      ENDIF
	      cSQLCommand = SUBSTR( cSQLCommand, 1, LEN( cSQLCommand ) -2 )
	      cSQLCommand = "UPDATE "+LOWER(THIS.TableName)+" SET " + cSQLCommand + " WHERE " + cCondition
	    ENDIF  
	    RETURN cSQLCommand
    ENDFUNC
   	
   	
   	***
   	** Retorna um comando SQL para cria��o da coluna
   	*******************
   	FUNCTION GET_SQL_TYPE( pDataBaseType, pType, pWidth, pDecimal, nFieldType )
	    DO CASE
	       CASE pDataBaseType == DB_MYSQL
		   		DO CASE
		   			CASE pType == "M"
		   				RETURN " TEXT"
		   			CASE pType == "D"
		   				RETURN " DATE NOT NULL DEFAULT '0000-00-00'"
		   			CASE pType == "C"
		   				RETURN "VARCHAR(" + ALLTRIM(STR(pWidth)) + ") NOT NULL DEFAULT ''"
		   			CASE pType == "N"
		   				IF pDecimal > 0
			   				RETURN "DOUBLE(" + ALLTRIM(STR(pWidth)) + ", " + ALLTRIM(STR(pDecimal)) + ") DEFAULT 0.00"
			   			ELSE
			   				DO CASE 
			   				  CASE nFieldType == DB_PRIMARY_KEY
	 			   				RETURN "INT PRIMARY KEY"
			   				  CASE nFieldType == DB_AUTO_NUMERIC
	 			   				RETURN "INT AUTO_INCREMENT PRIMARY KEY"
			   				  OTHERWISE
	 			   				RETURN "INT DEFAULT 0"
	 			   			ENDCASE	
			   			ENDIF
			   		OTHERWISE
			   			RETURN ""	
		   		ENDCASE
	       CASE pDataBaseType == DB_SQL_SERVER
	       		RETURN ""
	       OTHERWISE
	       		RETURN ""
	    ENDCASE   
   	ENDFUNC

ENDDEFINE

******
* oDbField
*
* Defini��o do objeto para estrutura de campos em tabelas
*
* 03-Abril-2022	[Aurino Coimbra]
* Cria��o do c�digo
*************************************************************
DEFINE CLASS oDbField AS Custom

	cType			= ""	&& Tipo do campo
	nWidth			= 0		&& Tamanho do campo
	nDecimal		= 0		&& N�mero de casas decimais
		
	Description		= ""	&& Descri��o do campo
	Comment			= ""	&& Coment�rio para o campo
	nFieldType		= DB_FIELD	&& Informa se o campo chave prim�ria

	PROCEDURE INIT
		
	ENDPROC
	
ENDDEFINE

