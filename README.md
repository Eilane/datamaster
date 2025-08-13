# Data Master - Integração de Dados Clientes PJ

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

### **2.0.1 - Integração de Dados Clientes PJ**

Coletar, analisar e disponibilizar dados cadastrais de clientes PJ e dados públicos de empresas com uma base da receita federal, com foco em qualidade, governança e integração ao ecossistema analítico corporativo.

### **2.0.2 - Escopo do Caso de Uso**

**Obtenção de dados fictícios de clientes (PF):**
Simular a ingestão de cadastros de clientes pessoa juridica pertencentes a uma empresa fictícia do setor de empréstimos.

**Integração com dados públicos de empresas (CNPJ):**
Realizar a extração de dados públicos junto ao Ministério da Fazenda

**Armazenamento no Data Lake corporativo:**
Persistir todos os dados obtidos nas no Data Lake.

**Verificação da situação cadastral da empresa:**
Validar se a empresa encontra-se em situação ativa, inativa, inapta ou baixada.

**Análise de possíveis irregularidades:**
Executar regras e validações para identificar possíveis inconsistências ou comportamentos suspeitos nos dados de CNPJ.

**Disponibilização via Banco de Dados Transacional (ELT reverso):**
Publicar os dados da camada Gold em um banco de dados transacional, por meio de ELT reverso, otimizando o consumo por aplicações analíticas.

<img width="788" height="588" alt="image" src="https://github.com/user-attachments/assets/c61f2c98-5fc6-41f0-87f3-aea69a1ee47c" />

**Premissa de SLA:**
Após a gravação do cadastro na base de origem, o processo de integração deverá garantir que as informações estejam sincronizadas e disponíveis no banco transacional em um intervalo de 5 a 15 minutos. Este tempo compreende todo o fluxo de ingestão, processamento, enriquecimento e carga final, considerando condições normais de operação.

## 3. Arquitetura da Solução

Para viabilizar o caso de uso descrito no item 2, os dados serão extraídos diretamente de suas fontes de origem e integrados a uma arquitetura de dados Lakehouse na nuvem pública Microsoft Azure.

<img width="1113" height="677" alt="image" src="https://github.com/user-attachments/assets/0bbeee58-61f0-4137-b51c-419693a669fe" />





### **3.0.1 - Estrutura lógica das camadas do Data Lake**

Os dados estão organizados no Data Lake conforme o padrão de design da arquitetura Medallion, que estrutura a informação em camadas lógicas (Bronze, Silver e Gold), foi adicionado a camada adicional "raw" que mantém os dados em seu formato original (csv,parquet,json). 

<img width="575" height="487" alt="image" src="https://github.com/user-attachments/assets/f96555a8-8d81-4688-846c-e88f119a6362" />


## 4. Monitoramento e Observabilidade

<img width="803" height="568" alt="image" src="https://github.com/user-attachments/assets/e8cd5087-21fb-45d6-864c-21e12cbc5ed0" />




## 5. Funções e Pipelines de Dados

**Azure Function** – `funcaoreceita`

**Descrição:**  
Função responsável por extrair, a partir do HTML do site  
`https://arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/{year_month}/`,  
todas as URLs válidas dos arquivos disponíveis para download.

**Trigger:** HTTP  

**Parâmetro de entrada:**  
- `year_month` (formato `YYYY-MM`)  

**Saída:**  
- JSON contendo uma lista de URLs válidas para download dos arquivos.

<img width="158" height="46" alt="image" src="https://github.com/user-attachments/assets/8b8165a0-706e-4112-97dd-341f49f27dac" />

<img width="1919" height="393" alt="image" src="https://github.com/user-attachments/assets/bb733d53-59b5-4b2b-8d13-8210a262e413" />



Pipeline responsável por capturar e armazenar dados públicos de empresas no Data Lake.

**Nome:** `pipeline_ingest_dados_pj`

**Periodicidade:** Mensal

**Dia:** Último dia do mês

**Horário:** 09:00

*OBS: Reprocessamento do Pipeline*

<img width="1293" height="541" alt="image" src="https://github.com/user-attachments/assets/323366ff-233a-43cc-be49-2d1cb73b1dd2" />


## 6. Resiliência dos Pipelines de Dados
*Em desenvolvimento...*

## 7. Cadastro de Tabelas e Modelagem de Dados

Enriquecimento das tabelas delta na camada GOLD com metadados personalizados para aplicação das regras de qualidade.

## 8. Motor de Qualidade de Dados na Camada Gold

### Regras 

| Nº  | Dimensão      | Regra de Qualidade                                                  | Criticidade |
|-----|---------------|-----------------------------------------------------------------------|-------------|
| 1   | Completude    | Campos obrigatórios como CNPJ não podem estar nulos              | Alta        | 
| 2   | Unicidade     | CNPJ não pode se repetir entre registros                             | Alta        | 
| 3   | Completude    | Nome da empresa não pode estar em branco                             | Alta        |
| 4   | Validade      | E-mail deve conter “@” e domínio válido                              | Média       | 
| 5   | Atualização   | Status cadastral da empresa deve ser atualizado mensalmente          | Alta        | 
| 6  | Atualização   | Validar se a data da última atualização está dentro do prazo esperado| Alta        |


## 9. Expurgo de Dados
*Em desenvolvimento...*

## 10. Plano de Recuperação e Local de Armazenamento
*Em desenvolvimento...*

## 11. Visualização de Dados
*Em desenvolvimento...*

## 12. Solução Técnica
*Em desenvolvimento...*

## 13. Análise das Tecnologias Escolhidas

### 13.0.1 Microsoft - Plataforma de Integração como Serviço 

A Microsoft foi nomeada líder no Quadrante Mágico™ da Gartner® de 2024 para Plataforma de Integração como Serviço 
O Azure Integration Services — Inclui o Azure API Management, o Azure Logic Apps, o Azure Service Bus, o Azure Event Grid, o Azure Functions e o **Azure Data Factory**

<img width="656" height="739" alt="image" src="https://github.com/user-attachments/assets/bfad38f6-5e0c-4823-89f2-8a52aca3e82c" />


### 13.0.2 Databricks 

Databricks como Líder no Quadrante Mágico™ da Gartner® de 2025 para Plataformas de Ciência de Dados e Aprendizado de Máquina.
<img width="730" height="748" alt="image" src="https://github.com/user-attachments/assets/3b941f6b-ce65-412c-aebb-3e526e39595a" />



## 14. Referências

https://www.gartner.com/reviews/market/cloud-database-management-systems/compare/product/amazon-simple-storage-service-amazon-s3-vs-azure-data-lake
https://www.databricks.com/blog/databricks-named-leader-2025-gartner-magic-quadrant-data-science-and-machine-learning
https://azure.microsoft.com/en-us/blog/microsoft-named-a-leader-in-2024-gartner-magic-quadrant-for-integration-platform-as-a-service/

https://learn.microsoft.com/pt-br/azure/databricks/delta/custom-metadata



