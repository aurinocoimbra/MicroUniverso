************************************************
* MICROUNIVERSO
*************************************************
*
* [ Código fonte ]
* MUEntityDefinitions.PRG
*
* [ Descrição ]
* Definição da estrutura do banco de dados
*
* [ Autor ]
* Aurino Coimbra	
*
*
* 09-Abril-2022 [ Aurino Coimbra ]
* Revisão
*
* 02-Abril-2022 [ Aurino Coimbra ]
* Criação do código
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
		gDataBase.NotaFiscal.Description = "Pedido de compra de mercadoria"	&& Descrição da tabela no ERP
		gDataBase.NotaFiscal.Comment = "Tabela de pedido de compra, todas as informações contidas devem ser submetidas a análise de preço e posterior visto/aprovação."

		gDataBase.NotaFiscal.AddField("PdcID",			"N",  4, 0, "ID do pedido de compra", "Número do pedido de compra (SEQUENCIAL)", DB_AUTO_NUMERIC )
		gDataBase.NotaFiscal.AddField("PdcData",		"D", 10, 0, "Data do pedido de compra", "Data de emissão do pedido de compra (AUTOMÁTICO)" )
		gDataBase.NotaFiscal.AddField("PdcValor",		"N", 10, 2, "Valor do pedido", "Informe o valor do pedido de compra" )
		gDataBase.NotaFiscal.AddField("PdcValorDesc",	"N", 10, 2, "Valor de desconto", "Informe o valor de desconto do pedido de compra" )
		gDataBase.NotaFiscal.AddField("PdcValorFrete",	"N", 10, 2, "Valor do frete", "Informe o valor do frete" )
		gDataBase.NotaFiscal.AddField("PdcQtdVisto",	"N",  4, 0, "Qtd. de Vistos", "Quantidade de vistos" )
		gDataBase.NotaFiscal.AddField("PdcQtdAprov",	"N",  4, 0, "Qtd. de Aprovação", "Quantidade de aprovação" )
		gDataBase.NotaFiscal.AddField("PdcStatus",		"C",  1, 0, "Status da pedido de compra", "Status do pedido de compra (AUTOMÁTICO)" )
		gDataBase.NotaFiscal.AddField("PdcDataStatus",	"D", 10, 0, "Data do status da pedido de compra", "Data da última atualização (AUTOMÁTICO)" )

		**
		** Usuários
		**
		gDataBase.AddTable( "Usuario")				&& Nome do objecto
		gDataBase.Usuario.TableName = "MUCDUSR"		&& Nome da tabela no banco de dados
		gDataBase.Usuario.Description = "Cadastro de usuários"	&& Descrição da tabela no ERP
		gDataBase.Usuario.Comment = "Tabela de usuários que irá acessar o sistema."

		gDataBase.Usuario.AddField("UsrID",				"N",  4, 0, "ID do usuário", "Código único do usuário", DB_AUTO_NUMERIC )
		gDataBase.Usuario.AddField("UsrData",			"D", 10, 0, "Data cadastro", "Data de cadastro do usuário" )
		gDataBase.Usuario.AddField("UsrNome",			"C", 40, 0, "Nome do usuário", "Nome do usuário" )
		gDataBase.Usuario.AddField("UsrEmail",			"C", 50, 0, "E-Mail", "Informe um e-mail para contato com o usuário" )
		gDataBase.Usuario.AddField("UsrObservacao",		"M", 10, 0, "Observação", "Nome do usuário" )
		gDataBase.Usuario.AddField("UsrLogin",			"C", 15, 0, "Login", "Informe um nome de login" )
		gDataBase.Usuario.AddField("UsrSenha",			"C", 15, 0, "Senha do usuário", "Senha do usuário" )
		gDataBase.Usuario.AddField("UsrFuncao",			"C",  1, 0, "Função administrativa", "1 - Verificar (Visto), 2 - Aprovar" )
		gDataBase.Usuario.AddField("UsrPermVisto",		"N",  1, 0, "Permite visto em nota de compra", "Configuração de permissão de visto" )
		gDataBase.Usuario.AddField("UsrPermAprov",		"N",  1, 0, "Permite aprovar pedido de compra", "Configuração de permissão de aprovação" )
		gDataBase.Usuario.AddField("UsrVlrMinAprov",	"N", 10, 2, "Valor mínimo para visto/aprovação", "Configuração do valor mínimo para visto/aprovação" )
		gDataBase.Usuario.AddField("UsrVlrMaxAprov",	"N", 10, 2, "Valor máximo para visto/aprovação", "Configuração do valor máximo para visto/aprovação" )

		**
		** Histório de visto/aprovação
		**
		gDataBase.AddTable( "HistAprov")				&& Nome do objecto
		gDataBase.HistAprov.TableName = "MUCPHVA"			&& Nome da tabela no banco de dados
		gDataBase.HistAprov.Description = "Histórico de visto e aprovação"	&& Descrição da tabela no ERP
		gDataBase.HistAprov.Comment = "Tabela de histórico de visto e aprovação de nota compra"

		gDataBase.HistAprov.AddField("HvaPdcID",		"N",  4, 0, "ID do pedido de compra", "Número nota de compra" )
		gDataBase.HistAprov.AddField("HvaData",			"D", 10, 0, "Data do movimento", "Data de emissão da nota de compra" )
		gDataBase.HistAprov.AddField("HvaUsrID",		"N",  4, 0, "ID do usuário", "Código único do usuário" )
		gDataBase.HistAprov.AddField("HvaQtdVisto",		"N",  4, 0, "Quantidade de vistos", "Quantidade de vistos" )
		gDataBase.HistAprov.AddField("HvaQtdAprov",		"N",  4, 0, "Quantidade de aprovação", "Quantidade de aprovação" )

		**
		** Configuração de visto/aprovação para todos os usuários
		**
		gDataBase.AddTable( "ConfAprov")				&& Nome do objecto
		gDataBase.ConfAprov.TableName = "MUCFAPRV"		&& Nome da tabela no banco de dados
		gDataBase.ConfAprov.Description = "Faixa financeira de visto e aprovação (GLOBAL)"	&& Descrição da tabela no ERP
		gDataBase.ConfAprov.Comment = "Tabela de histórico de visto e aprovação de nota compra"
		
		gDataBase.ConfAprov.AddField("AprvID",			"N",  4, 0, "ID", "ID da faixa financira", DB_AUTO_NUMERIC )
		gDataBase.ConfAprov.AddField("AprvFaixaInic",	"N", 10, 2, "Faixa inicial", "Informe a faixa inicial para visto/aprovação" )
		gDataBase.ConfAprov.AddField("AprvFaixaFinal",	"N", 10, 2, "Faixa final", "Informe a faixa final para visto/aprovação" )
		gDataBase.ConfAprov.AddField("AprvQtdVisto",	"N", 10, 0, "Qtd de visto", "Quantidade de vistos necessários para mudança do status do pedido de compra" )
		gDataBase.ConfAprov.AddField("AprvQtdAprov",	"N", 10, 0, "Qtd de aprovação", "Quantidade de aprovação necessárias para mudança do status do pedido de compra" )

		
	CATCH TO oErr

		MESSAGEBOX("Não foi possível criar o banco de dados, erro : " + oErr.Message, 0 + 48, "Atenção" )

		RETURN .F.
		
	ENDTRY
	
	*
	** Retorna verdadeiro se o banco de dados virtual for criado com sucesso
	*
	RETURN .T.
	
ENDFUNC

