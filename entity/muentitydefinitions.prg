************************************************
* MICROUNIVERSO
*************************************************
*
* [ C�digo fonte ]
* MUEntityDefinitions.PRG
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

FUNCTION MUCreateVirtualDatabase()

	TRY
		gDataBase = CREATEOBJECT("oDataBase")
		gDataBase.Name = "MUDADOS"

		**
		** Pedido compra
		**
		gDataBase.AddTable( "NotaFiscal")			&& Nome do objeto
		gDataBase.NotaFiscal.TableName = "MUCPPDC"	&& Nome da tabela no banco de dados
		gDataBase.NotaFiscal.Description = "Pedido de compra de mercadoria"	&& Descri��o da tabela no ERP
		gDataBase.NotaFiscal.Comment = "Tabela de pedido de compra, todas as informa��es contidas devem ser submetidas a an�lise de pre�o e posterior visto/aprova��o."

		gDataBase.NotaFiscal.AddField("PdcID",			"N",  4, 0, "ID do pedido de compra", "N�mero do pedido de compra (SEQUENCIAL)", DB_AUTO_NUMERIC )
		gDataBase.NotaFiscal.AddField("PdcData",		"D", 10, 0, "Data do pedido de compra", "Data de emiss�o do pedido de compra (AUTOM�TICO)" )
		gDataBase.NotaFiscal.AddField("PdcValor",		"N", 10, 2, "Valor do pedido", "Informe o valor do pedido de compra" )
		gDataBase.NotaFiscal.AddField("PdcValorDesc",	"N", 10, 2, "Valor de desconto", "Informe o valor de desconto do pedido de compra" )
		gDataBase.NotaFiscal.AddField("PdcValorFrete",	"N", 10, 2, "Valor do frete", "Informe o valor do frete" )
		gDataBase.NotaFiscal.AddField("PdcQtdVisto",	"N",  4, 0, "Qtd. de Vistos", "Quantidade de vistos" )
		gDataBase.NotaFiscal.AddField("PdcQtdAprov",	"N",  4, 0, "Qtd. de Aprova��o", "Quantidade de aprova��o" )
		gDataBase.NotaFiscal.AddField("PdcStatus",		"C",  1, 0, "Status da pedido de compra", "Status do pedido de compra (AUTOM�TICO)" )
		gDataBase.NotaFiscal.AddField("PdcDataStatus",	"D", 10, 0, "Data do status da pedido de compra", "Data da �ltima atualiza��o (AUTOM�TICO)" )

		**
		** Usu�rios
		**
		gDataBase.AddTable( "Usuario")				&& Nome do objecto
		gDataBase.Usuario.TableName = "MUCDUSR"		&& Nome da tabela no banco de dados
		gDataBase.Usuario.Description = "Cadastro de usu�rios"	&& Descri��o da tabela no ERP
		gDataBase.Usuario.Comment = "Tabela de usu�rios que ir� acessar o sistema."

		gDataBase.Usuario.AddField("UsrID",				"N",  4, 0, "ID do usu�rio", "C�digo �nico do usu�rio", DB_AUTO_NUMERIC )
		gDataBase.Usuario.AddField("UsrData",			"D", 10, 0, "Data cadastro", "Data de cadastro do usu�rio" )
		gDataBase.Usuario.AddField("UsrNome",			"C", 40, 0, "Nome do usu�rio", "Nome do usu�rio" )
		gDataBase.Usuario.AddField("UsrEmail",			"C", 50, 0, "E-Mail", "Informe um e-mail para contato com o usu�rio" )
		gDataBase.Usuario.AddField("UsrObservacao",		"M", 10, 0, "Observa��o", "Nome do usu�rio" )
		gDataBase.Usuario.AddField("UsrLogin",			"C", 15, 0, "Login", "Informe um nome de login" )
		gDataBase.Usuario.AddField("UsrSenha",			"C", 15, 0, "Senha do usu�rio", "Senha do usu�rio" )
		gDataBase.Usuario.AddField("UsrFuncao",			"C",  1, 0, "Fun��o administrativa", "1 - Verificar (Visto), 2 - Aprovar" )
		gDataBase.Usuario.AddField("UsrPermVisto",		"N",  1, 0, "Permite visto em nota de compra", "Configura��o de permiss�o de visto" )
		gDataBase.Usuario.AddField("UsrPermAprov",		"N",  1, 0, "Permite aprovar pedido de compra", "Configura��o de permiss�o de aprova��o" )
		gDataBase.Usuario.AddField("UsrVlrMinAprov",	"N", 10, 2, "Valor m�nimo para visto/aprova��o", "Configura��o do valor m�nimo para visto/aprova��o" )
		gDataBase.Usuario.AddField("UsrVlrMaxAprov",	"N", 10, 2, "Valor m�ximo para visto/aprova��o", "Configura��o do valor m�ximo para visto/aprova��o" )

		**
		** Hist�rio de visto/aprova��o
		**
		gDataBase.AddTable( "HistAprov")				&& Nome do objecto
		gDataBase.HistAprov.TableName = "MUCPHVA"			&& Nome da tabela no banco de dados
		gDataBase.HistAprov.Description = "Hist�rico de visto e aprova��o"	&& Descri��o da tabela no ERP
		gDataBase.HistAprov.Comment = "Tabela de hist�rico de visto e aprova��o de nota compra"

		gDataBase.HistAprov.AddField("HvaPdcID",		"N",  4, 0, "ID do pedido de compra", "N�mero nota de compra" )
		gDataBase.HistAprov.AddField("HvaData",			"D", 10, 0, "Data do movimento", "Data de emiss�o da nota de compra" )
		gDataBase.HistAprov.AddField("HvaUsrID",		"N",  4, 0, "ID do usu�rio", "C�digo �nico do usu�rio" )
		gDataBase.HistAprov.AddField("HvaQtdVisto",		"N",  4, 0, "Quantidade de vistos", "Quantidade de vistos" )
		gDataBase.HistAprov.AddField("HvaQtdAprov",		"N",  4, 0, "Quantidade de aprova��o", "Quantidade de aprova��o" )

		**
		** Configura��o de visto/aprova��o para todos os usu�rios
		**
		gDataBase.AddTable( "ConfAprov")				&& Nome do objecto
		gDataBase.ConfAprov.TableName = "MUCFAPRV"		&& Nome da tabela no banco de dados
		gDataBase.ConfAprov.Description = "Faixa financeira de visto e aprova��o (GLOBAL)"	&& Descri��o da tabela no ERP
		gDataBase.ConfAprov.Comment = "Tabela de hist�rico de visto e aprova��o de nota compra"
		
		gDataBase.ConfAprov.AddField("AprvID",			"N",  4, 0, "ID", "ID da faixa financira", DB_AUTO_NUMERIC )
		gDataBase.ConfAprov.AddField("AprvFaixaInic",	"N", 10, 2, "Faixa inicial", "Informe a faixa inicial para visto/aprova��o" )
		gDataBase.ConfAprov.AddField("AprvFaixaFinal",	"N", 10, 2, "Faixa final", "Informe a faixa final para visto/aprova��o" )
		gDataBase.ConfAprov.AddField("AprvQtdVisto",	"N", 10, 0, "Qtd de visto", "Quantidade de vistos necess�rios para mudan�a do status do pedido de compra" )
		gDataBase.ConfAprov.AddField("AprvQtdAprov",	"N", 10, 0, "Qtd de aprova��o", "Quantidade de aprova��o necess�rias para mudan�a do status do pedido de compra" )

		
	CATCH TO oErr

		MESSAGEBOX("N�o foi poss�vel criar o banco de dados, erro : " + oErr.Message, 0 + 48, "Aten��o" )

		RETURN .F.
		
	ENDTRY
	
	*
	** Retorna verdadeiro se o banco de dados virtual for criado com sucesso
	*
	RETURN .T.
	
ENDFUNC

