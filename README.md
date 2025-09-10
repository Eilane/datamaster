# Integração de Dados Clientes PJ

## Sumário

1. [Objetivo](#objetivo)
2. [Caso de Uso](#caso-de-uso)
3. [Arquitetura da Solução](#arquitetura-da-solução)
4. [Monitoramento e Observabilidade](#monitoramento-e-observabilidade)  
5. [Pipelines de Dados](#Pipelines-de-dados)
6. [Resiliência dos Pipelines de Dados](#Resiliência-dos-pipelines-de-dados)
7. [Cadastro de Tabelas e Modelagem de Dados](#cadastro-de-tabelas-e-modelagem-de-dados)  
8. [Motor de Qualidade de Dados](#motor-de-qualidade-de-dados)  
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

- **Disponibilização via Banco de Dados Transacional (ELT reverso):**  
  Publicar os dados da camada Gold em um banco de dados transacional, por meio de ELT reverso, otimizando o consumo por aplicações analíticas.

### **2.0.3 - Diagrama do Caso de Uso**

<img width="788" height="588" alt="image" src="https://github.com/user-attachments/assets/c61f2c98-5fc6-41f0-87f3-aea69a1ee47c" />

### **2.0.4 - Premissas do Projeto**

**SLA:**
Após a criação do cadastro cliente PJ no sistema de crédito, o processo de integração deverá garantir que as informações públicas coletadas sejam sincronizadas e disponibilizadas no banco transacional em um intervalo de **5** a **15 minutos**. Este tempo compreende todo o fluxo de ingestão, processamento, enriquecimento e carga final, considerando condições normais de operação.

### 2.0.5 - Riscos Operacionais Mapeados na Utilização de Dados Públicos

| Risco                                                        | Impacto Potencial                                                                 | Estratégia de Mitigação                                                                                  |
|--------------------------------------------------------------|-----------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| Alteração no layout da página sem comunicação prévia         | Interrupção na extração automática dos dados, causando falhas no pipeline         | Implementar validação de estrutura HTML antes do processamento e configurar alertas para mudanças         |
| Modificações na estrutura dos datasets sem aviso prévio      | Erros na transformação e carga dos dados, podendo gerar inconsistências           | Criar camada de mapeamento dinâmico e rotinas de verificação de schema                                    |
| Presença de dados duplicados nos arquivos disponibilizados   | Aumento de volume armazenado e risco de análises incorretas                        | Aplicar deduplicação durante o processamento e criar relatórios de controle                              |


## 3. Arquitetura

### 3.0.1 Desenho de Arquitetura
Para viabilizar o caso de uso descrito no item 2, os dados serão extraídos diretamente de suas fontes de origem e integrados a uma arquitetura de dados Lakehouse na nuvem pública Microsoft Azure.




### 3.0.2 - Estrutura lógica das camadas do Data Lake

Os dados estão organizados no Data Lake conforme o padrão de design da arquitetura Medallion, que estrutura a informação em camadas lógicas (Bronze, Silver e Gold), foi adicionado a camada adicional "raw" que mantém os dados em seu formato original (csv,parquet,json). 

As informações de auditoria, monitoramento e qualidade foram separadas dos dados de negócio e serão armazenadas na camada Governance, garantindo maior organização e controle sobre os metadados e processos de governança.

<img width="655" height="554" alt="image" src="https://github.com/user-attachments/assets/089b3c73-b7e7-4bde-8b69-5833d2c3c55d" />


### 3.0.3 – Integração dos Recursos com o Data Lake Gen2

Recursos com acesso direto ao Data Lake Corporativo
<img width="999" height="652" alt="image" src="https://github.com/user-attachments/assets/e88b8b16-0c31-48c2-83e2-50c208288858" />



### 3.0.4 – Estrutura Lógica de Pastas Terraform

## 4. Monitoramento e Observabilidade

<img width="841" height="542" alt="image" src="https://github.com/user-attachments/assets/7444b63c-91d4-421d-9595-3e28a359fe03" />


## 5. Funções e Pipelines de Dados

### **5.0.1 - Azure Function** – `funcaoreceita`

**Descrição:**  
Função responsável por extrair todas as URLs válidas dos arquivos disponíveis para download, a partir do HTML do site:  
`https://arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/{year_month}/`,  


**Trigger:** HTTP  

**Parâmetro de entrada:**  
- `year_month` (formato `YYYY-MM`)  

**Saída:**  
- JSON contendo uma lista de URLs válidas para download dos arquivos.


### **5.0.2 - Pipeline de Dados** – `pipeline_ingest_dados_pj`
**Descrição:**
Pipeline responsável por capturar e armazenar dados públicos de empresas no Data Lake.

**Periodicidade:** Mensal

**Dia:** Último dia do mês

**Horário:** 09:00

<img width="1109" height="397" alt="image" src="https://github.com/user-attachments/assets/52831e40-df37-4d4c-9333-34a8f0b6e100" />






## 6. Resiliência dos Pipelines de Dados

### 6.0.1 - Pipeline: `pipeline_ingest_dados_pj`

**Reprocessamento:**  
O pipeline permite informar o ano e mês a serem reprocessados no formato `YYYY-MM`.  
Caso nenhum valor seja fornecido, o pipeline utiliza automaticamente o ano e mês atuais.

**Configuração de retomada (Retry):**  
- Até 3 tentativas em caso de falha  
- Intervalo de 60 segundos entre cada tentativa


## 7. Data Quality

### Regras 

| Nº  | Dimensão      | Regra de Qualidade                                                  | Criticidade |
|-----|---------------|-----------------------------------------------------------------------|-------------|
| 1   | Completude    | Campos obrigatórios como CNPJ não podem estar nulos              | Alta        | 
| 2   | Unicidade     | CNPJ não pode se repetir entre registros                             | Alta        | 
| 3   | Completude    | Nome da empresa não pode estar em branco                             | Alta        |
| 4   | Validade      | E-mail deve conter “@” e domínio válido                              | Média       | 
| 5   | Atualização   | Status cadastral da empresa deve ser atualizado mensalmente          | Alta        | 
| 6  | Atualização   | Validar se a data da última atualização está dentro do prazo esperado| Alta        |


## 8. Expurgo de Dados
*Em desenvolvimento...*

## 9. Plano de Recuperação e Local de Armazenamento
*Em desenvolvimento...*

## 10. Visualização de Dados
*Em desenvolvimento...*

## 11. Solução Técnica

### 11.0.1 Pré-requisitos

- **Assinatura do Azure** com permissões administrativas  
- **Azure CLI**: [Instalar](https://aka.ms/installazurecliwindows) 
- **Terraform**: [Download](https://www.terraform.io/downloads.html)  
- **Visual Studio Code**: [Download](https://code.visualstudio.com/download)  
  - Extensões recomendadas:  
    - **Azure Resources**  
    - **Microsoft Terraform**  
    - **HashiCorp Terraform**  
- **psql**: [Download](https://www.postgresql.org/download/windows/)  
- **Meu Ip**: [Download](https://meuip.com.br/)    # Para liberacao da regra de firewall
---

### 11.0.2 Passo a passo

1. **Executar os comandos abaixo na raiz do projeto Terraform**:

   ```bash
   terraform init       # Inicializa os providers e módulos
   az login             # Autentica na conta Azure
   terraform plan       # Mostra o que será criado/alterado
   terraform apply      # Aplica as mudanças na Azure

## 12. Análise das Tecnologias Escolhidas

### 12.0.1 Microsoft - Plataforma de Integração como Serviço 

A Microsoft foi nomeada líder no Quadrante Mágico™ da Gartner® de 2024 para Plataforma de Integração como Serviço 
O Azure Integration Services — Inclui o Azure API Management, o Azure Logic Apps, o Azure Service Bus, o Azure Event Grid, o Azure Functions e o **Azure Data Factory**

<img width="656" height="739" alt="image" src="https://github.com/user-attachments/assets/bfad38f6-5e0c-4823-89f2-8a52aca3e82c" />


### 12.0.2 Databricks 

Databricks como Líder no Quadrante Mágico™ da Gartner® de 2025 para Plataformas de Ciência de Dados e Aprendizado de Máquina.
<img width="730" height="748" alt="image" src="https://github.com/user-attachments/assets/3b941f6b-ce65-412c-aebb-3e526e39595a" />



## 13. Referências

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
