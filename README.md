# Integração de Dados Clientes PJ

## Sumário

1. [Objetivo](#objetivo)
2. [Caso de Uso](#caso-de-uso)
3. [Arquitetura](#arquitetura-da-solução)
4. [Monitoramento e Observabilidade](#monitoramento-e-observabilidade)  
5. [Funções e Pipelines de Dados](#Pipelines-de-dados)
6. [Resiliência dos Pipelines de Dados](#Resiliência-dos-pipelines-de-dados)
7. [Tabelas](#cadastro-de-tabelas-e-modelagem-de-dados)  
8. [Qualidade de Dados](#motor-de-qualidade-de-dados)  
9. [Expurgo de Dados](#expurgo-de-dados)  
10. [Plano de Recuperação e Local de Armazenamento](#plano-de-recuperação-e-local-de-armazenamento)  
11. [Visualização de Dados](#visualização-de-dados)
12. [Solução Técnica](#solução-técnica)
13. [Análise das Tecnologias Escolhidas](#análise-de-mercado-e-tecnologias-escolhidas)  
14. [Referências](#referências)
---

## 1. Objetivo

O projeto tem como objetivo simular e implementar um caso de uso concreto, abordando os principais conceitos e fundamentos essenciais de uma plataforma de dados moderna.  
A solução será focada na disponibilização de dados com **alta qualidade**, **segurança**, **monitoramento eficiente** e **escalabilidade**, assegurando uma gestão de dados **robusta, confiável e sustentável**.


## 2. Caso de Uso

**Empresa:** CrediFácil Brasil *(fictícia)*  
**Projeto:** Integração dados públicos - Fase 1 Empresas  
**Caso de Uso:** Integração de Dados Clientes PJ  

### **2.0.1 - Descrição**
Coletar, analisar e disponibilizar dados cadastrais de clientes PJ e dados públicos de empresas com uma base da receita federal, com foco em qualidade, governança e integração ao ecossistema analítico corporativo.

### **2.0.2 - Escopo do Caso de Uso**

- **Obtenção de dados fictícios de clientes (PF):**  
  Simular a ingestão de cadastros de clientes pessoa jurídica pertencentes a uma empresa fictícia do setor de empréstimos.

- **Integração com dados públicos de empresas (CNPJ):**  
  Realizar a extração de dados públicos junto ao Ministério da Fazenda.

- **Armazenamento no Data Lake corporativo:**  
  Persistir todos os dados obtidos no Data Lake.

- **Verificação da situação cadastral da empresa:**  
  Validar se a empresa encontra-se em situação ativa, inativa, inapta ou baixada.

- **Análise de possíveis irregularidades:**  
  Executar regras e validações para identificar possíveis inconsistências ou comportamentos suspeitos nos dados de CNPJ.


- **Análise de potenciais clientes:**  
  Analisar potenciais clientes para promover campanhas de crédito


### **2.0.3 - Diagrama do Caso de Uso**

![alt text](image-1.png)


### 2.0.4 - Riscos Operacionais Mapeados na utilização de Dados Públicos

### Matriz de Riscos Mapeados

| **Risco** | **Impacto Potencial** | **Estratégia de Mitigação** |
|-----------|------------------------|-----------------------------|
| Alteração no layout da página ou modificações na estrutura dos datasets sem comunicação prévia | Interrupção na extração automática dos dados, ocasionando falhas no pipeline | Utilizar os dados apenas para fins analíticos, reduzindo o impacto de interrupções temporárias para o cliente final nos sistemas transacionais |
| Presença de dados duplicados nos arquivos disponibilizados | Aumento no volume de armazenamento e risco de análises incorretas | Aplicar deduplicação no processamento e gerar relatórios de controle para acompanhamento contínuo |


### 2.0.5 Premissas

- Atualização dos **dados de clientes** do sistema de crédito no Data Lake.  
- Latência máxima de **15 minutos** para refletir as alterações.  
- Objetivo: **evitar o envio de campanhas de crédito** para clientes já cadastrados na base de dados.


## 3. Arquitetura

### 3.0.1 Desenho de Arquitetura
Para viabilizar o caso de uso descrito no item 2, os dados serão extraídos diretamente de suas fontes de origem e integrados a uma arquitetura de dados Lakehouse na nuvem pública Microsoft Azure.

![alt text](image-2.png)


### 3.0.2 - Estrutura lógica das camadas do Data Lake

Os dados estão organizados no Data Lake conforme o padrão de design da arquitetura Medallion, que estrutura a informação em camadas lógicas (Bronze, Silver e Gold), foi adicionado a camada adicional "raw" que mantém os dados em seu formato original (csv,parquet,json). 

As informações de auditoria, monitoramento e qualidade foram separadas dos dados de negócio e serão armazenadas na camada Governance, garantindo maior organização e controle sobre os metadados e processos de governança.

<img width="575" height="493" alt="image" src="https://github.com/user-attachments/assets/5741328e-1c23-478b-84f2-7f8f5b0fb715" />



### 3.0.3 – Integração dos Recursos com o Data Lake Gen2

Recursos com acesso direto ao Data Lake Corporativo
<img width="969" height="612" alt="image" src="https://github.com/user-attachments/assets/314c2638-0b1f-4482-81fe-07b24b0351fc" />





### 3.0.4 – Estrutura do Terraform
# Estrutura de Diretórios - Terraform

Este repositório organiza a infraestrutura como código (IaC) utilizando **Terraform**, com módulos separados por serviço para facilitar manutenção e reutilização.

---

## 
```bash
.terraform
├── main
├── modules
│   ├── azure_sql
│   │
│   ├── databricks        # Módulo cria os recursos abaixo:
│   │                     # - workspace
│   │                     # - managed_identity
|   │                     # - metastore
│   │                     # - storage_credential
│   │                     # - external_locations
│   │                     # - catalog
│   │                     # - schemas
│   │                     # - notebooks
│   │                     # - cluster
│   │                     # - roles
│   │
│   ├── data_factory      # Módulo cria:
│   │                     # - linked_services
│   │                     # - datasets
│   │                     # - pipelines
│   │                     # - triggers
│   │                     # - roles
│   │
│   ├── functions_app     # Módulo cria uma função python
│   │
│   └── storage_account   # Módulo cria os containers:
                          # - raw
                          # - bronze
                          # - silver
                          # - gold
                          # - governance
```



## 1. Estrutura de pastas

```bash
terraform
├── main.tf              # Arquivo principal com recursos globais e providers
├── variables.tf         # Declaração de variáveis
├── terraform.tfvars     # Valores sensíveis | Não está no git
├── provider.tf          # Configuração do provider
├── modules
│   ├── resource_group
│   │   # Módulo cria o Resource Group principal do projeto
│   │   # - Nome do RG
│   │   # - Localização
│   │  
│   ├── azure_sql        # Módulo cria o SQL DATABASE
│   │   └── scripts      # Scripts SQL, como init_credito.sql para tabelas e CDC
│   │
│   ├── databricks
│   │   # Módulo cria os recursos abaixo:
│   │   # - workspace
│   │   # - managed_identity
│   │   # - metastore
│   │   # - storage_credential
│   │   # - external_locations
│   │   # - catalog
│   │   # - schemas
│   │   # - notebooks (bronze, silver, gold, governance)
│   │   # - cluster
│   │   # - roles
│   │
│   ├── data_factory
│   │   # Módulo cria:
│   │   # - linked_services
│   │   # - datasets
│   │   # - pipelines
│   │   # - triggers
│   │   # - roles
│   │
│   ├── functions_app
│   │   # Módulo cria função Python
│   │
│   ├── keyvault
│   │   # Módulo cria Key Vault e secrets
│   │   # - senha_db
│   │   # - role de permissão de acesso para Data Factory (get)
│   │
│   └── storage_account
│       # Módulo cria os containers:
│       # - raw
│       # - bronze
│       # - silver
│       # - gold
│       # - governance
│       # - Politicas 

```

## 4. Monitoramento e Observabilidade

![alt text](image.png)

## 5. Funções e Pipelines de Dados

### **5.0.1 - Azure Function** – `funcaoreceita`

**Descrição:** Função responsável por extrair todas as URLs válidas dos arquivos disponíveis para download, a partir do HTML do site:  
`https://arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/{year_month}/`,  
**Entrada:**  
- `year_month` (formato `YYYY-MM`)  
**Saída:**  
- JSON contendo uma lista de URLs válidas para download dos arquivos.


### **5.0.2 - Pipeline de Dados** – `pipeline_ingest_dados_pj`
**Descrição:** Pipeline responsável por capturar e armazenar dados públicos de empresas no Data Lake.
**Periodicidade:** Mensal
**Dia:** Último dia do mês
**Horário:** 09:00

<img width="1147" height="297" alt="image" src="https://github.com/user-attachments/assets/4fcb6490-772b-4a47-a71d-b5031a84572a" />


## 6. Resiliência dos Pipelines de Dados

### 6.0.1 - Pipeline: `pipeline_ingest_dados_pj`

**Reprocessamento:**  
O pipeline permite informar o ano e mês a serem reprocessados no formato `YYYY-MM`.  
Caso nenhum valor seja fornecido, o pipeline utiliza automaticamente o ano e mês atuais.

**Configuração de retomada (Retry):**  
- Até 3 tentativas em caso de falha  
- Intervalo de 60 segundos entre cada tentativa

## 7. Tabelas

### SCD - Slowly Changing Dimensions  

Técnica de gerenciamento de dados que define como as tabelas lidam com informações que mudam ao longo do tempo.  

#### Aplicado Tipo 1 nas Tabelas *Silver* e *Gold*  

- **Tipo 1**: Sem histórico — apenas os dados atuais são mantidos.  
  - **Forma de escrita**: *Overwrite*  



## 8. Qualidade de Dados
### 8.0.1 - Tabela com regras de qualidade

**Objetivo:**  
Registrar as **regras de qualidade** que devem ser aplicadas nas tabelas **Silver** e **Gold** para garantir a integridade e consistência dos dados.

**Tabela:** `prd.governance.regras_qualidade`

**Descrição:**  
- Centraliza todas as regras de validação de dados.  
- Permite auditoria e monitoramento da conformidade dos dados.  

**Exemplo de uso:**  
- Validar campos obrigatórios (`NOT NULL`)  
- Calcular scores de qualidade por tabela e coluna

<img width="988" height="430" alt="image" src="https://github.com/user-attachments/assets/5c066b05-2a8c-45d8-bce8-6d90a0f697a6" />


## 9. Expurgo de Dados
*Em desenvolvimento...*

## 10. Plano de Recuperação e Local de Armazenamento
*Em desenvolvimento...*

## 11. Visualização de Dados
*Em desenvolvimento...*

## 12. Solução Técnica

### 12.0.1 Pré-requisitos

- **Assinatura do Azure** com permissões administrativas  
- **Azure CLI**: [Instalar](https://aka.ms/installazurecliwindows) 
- **Terraform**: [Download](https://www.terraform.io/downloads.html)
- **SQLCMD**:[Download](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-download-install?view=sql-server-ver17&tabs=windows)
- **Visual Studio Code**: [Download](https://code.visualstudio.com/download)  
  - Extensões recomendadas:  
    - **Azure Resources**  
    - **Microsoft Terraform**  
    - **HashiCorp Terraform**  
- **Meu Ip** [Link](https://meuip.com.br/) Liberar o firewall no banco de dados 
---

### 12.0.2 Passo a passo


1. **Criar o arquivo de variáveis**:

Dentro da pasta `terraform`, crie o arquivo `terraform.tfvars`:

**Nome do arquivo:** `terraform.tfvars`

**Conteúdo:**
```bash
senha_db        = ""  # Exemplo de senha válida:!CfacilBr489@demo  A senha deve conter letras maiúsculasminúsculas, números e caracteres especiais
tenant_id       = ""  # ID do Tenant
subscription_id = ""  # ID da Subscription
account_id      = ""  # ID da Account
```
 

2. **Executar os comandos abaixo na raiz do projeto Terraform**:

```bash
terraform init       # Inicializa os providers e módulos
az login             # Autentica na conta Azure
terraform plan       # Mostra o que será criado
terraform apply      # Aplica as mudanças na Azure
```

3. **Executar oo comando abaixo para criar a tabela no Banco de Dados e habilitar o CDC. Obs: O script init_credito.sql está na pasta terraform/modules/azure_sql**:
```bash
sqlcmd -S tcp:sqlcfacilbr.database.windows.net -d sqlcfacilbr -U sqladmin -P "InformarSenhaBanco" -i init_credito.sql
```
## 13. Análise das Tecnologias Escolhidas

### 13.0.1 Microsoft - Plataforma de Integração como Serviço 

A Microsoft foi nomeada líder no Quadrante Mágico™ da Gartner® de 2024 para Plataforma de Integração como Serviço 
O Azure Integration Services — Inclui o Azure API Management, o Azure Logic Apps, o Azure Service Bus, o Azure Event Grid, o Azure Functions e o **Azure Data Factory**

<img width="656" height="739" alt="image" src="https://github.com/user-attachments/assets/bfad38f6-5e0c-4823-89f2-8a52aca3e82c" />


### 13.0.2 Databricks 

Databricks como Líder no Quadrante Mágico™ da Gartner® de 2025 para Plataformas de Ciência de Dados e Aprendizado de Máquina.
<img width="730" height="748" alt="image" src="https://github.com/user-attachments/assets/3b941f6b-ce65-412c-aebb-3e526e39595a" />



## 14. Referências

Captura de dados alterados (CDC) com o Banco de Dados SQL do Azure
https://learn.microsoft.com/en-us/azure/azure-sql/database/change-data-capture-overview?view=azuresql


Microsoft.DataFactory factories/adfcdcs
https://learn.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/adfcdcs?pivots=deployment-language-bicep


SQLCMD
https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-download-install?view=sql-server-ver17&tabs=windows

Use Azure managed identities in Unity Catalog to access storage
https://learn.microsoft.com/en-us/azure/databricks/connect/unity-catalog/cloud-storage/azure-managed-identities

TERRAFORM -> 
https://www.youtube.com/watch?v=YlY9WMURc50&t=661s    
https://registry.terraform.io/providers/hashicorp/azurerm/4.39.0/docs  
https://www.youtube.com/watch?v=YwloG_qq5aA 
https://registry.terraform.io/modules/Azure/naming/azurerm/latest#output_data_factory

UNITY CATALOG
https://learn.microsoft.com/pt-br/azure/databricks/data-governance/unity-catalog/

OUTROS
https://www.gartner.com/reviews/market/cloud-database-management-systems/compare/product/amazon-simple-storage-service-amazon-s3-vs-azure-data-lake
https://www.databricks.com/blog/databricks-named-leader-2025-gartner-magic-quadrant-data-science-and-machine-learning
https://azure.microsoft.com/en-us/blog/microsoft-named-a-leader-in-2024-gartner-magic-quadrant-for-integration-platform-as-a-service/

DEBEZIUM
https://debezium.io/documentation/reference/stable/connectors/postgresql.html (Debezium connector for PostgreSQL)

https://github.com/ycamargo/debezium-on-aks
