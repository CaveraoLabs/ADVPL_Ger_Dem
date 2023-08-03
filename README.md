# Gerenciamento de Demandas - Programa (GABA010)
Uma tela customizada no ERP Protheus para gerenciamento de demandas.

# Requisitos Funcionais
- Essa rotina poderá ser acessada apenas por administradores.
- Essa rotina deverá estar disponível no menu SIGACFG.
- As demandas só poderão ser cadastradas (inseridas) no sistema considerando o mês vigente, ou seja, o período anterior precisa ser fechado em um parâmetro MV.
- Visualizar a lista de demandas em tela.
- Cadastrar uma nova demanda
- Editar uma demanda
- Excluir uma demanda.
- Relatório via impressão do browser das demandas cadastradas.
- Ativar e inativar a demanda.

# Tabelas, Campos e Parâmetros Envolvidos
Z01 - Gerenciamento de Demandas:
-    Z01_NUM     -> Número da demanda
-    Z01_STATUS  -> Status da demanda
-    Z01_TITULO  -> Título da demanda
-    Z01_RESP    -> Responsável pela demanda
-    Z01_NOMRES  -> (Virtual) Nome do responsável
-    Z01_REQUE   -> Requerente
-    Z01_NOMREQ  -> (Virtual) Nome do requerente
-    Z01_DTINI   -> Data de início
-    Z01_DTFIM   -> Data de finalização
-    Z01_QTDHR   -> Quantidade de horas necessárias para atender a essa demanda.
-    Z01_DESC    -> Descrição da demanda

Parâmetros:
- MV_Z01_DMV - Demandas somente no Mês Vigente? - Bool

# Validações Adicionadas
Campos:
* Z01_DTINI: Se o parâmetro MV_Z01_DMV estiver habilitado, a data inicial pode ser somente do mês vigente.
* Z01_DTFIM: Não pode ser maior que o Z01_DTINI
* Z01_QTDHR: Tem que ser maior que zero

# "Facilitadores" Adicionados
Ao incluir uma nova demanda, preencher automaticamente por padrão:
- Z01_NUM de acordo com a sequência designada
- Z01_STATUS definido para Ativo
- Z01_RESP com o código do usuário logado no momento
- Z01_DTINI com a data base atual

# Sugestões de Melhoria
- Criar processos separados para Abertura e Entrega de demandas
- Criar funcionalidade para poder anexar documentos às demandas
- Organizar usuários e demandas por departamento (utilzando funções padrão, como "Papel de Trabalho")

