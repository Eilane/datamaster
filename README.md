# DataMaster

## Sumário

1. [Objetivo](#objetivo)
2. [Caso de Uso](#caso-de-uso)
3. [Arquitetura da Solução](#arquitetura-da-solução)
4. [Monitoramento e Observabilidade](#monitoramento-e-observabilidade)  
5. [Pipelines de Dados](#Pipelines-de-dados)  
6. [Cadastro de Tabelas e Modelagem de Dados](#cadastro-de-tabelas-e-modelagem-de-dados)  
7. [Motor de Qualidade de Dados](#motor-de-qualidade-de-dados)  
8. [Expurgo de Dados](#expurgo-de-dados)  
9. [Plano de Recuperação e Local de Armazenamento](#plano-de-recuperação-e-local-de-armazenamento)  
10. [Visualização de Dados](#visualização-de-dados)
11. [Solução Técnica](#solução-técnica)
12. [Análise das Tecnologias Escolhidas](#análise-de-mercado-e-tecnologias-escolhidas)  
13. [Referências](#referências)
---

## 1. Objetivo

O projeto tem como objetivo simular e implementar um caso de uso concreto, abordando os principais conceitos e fundamentos essenciais de uma plataforma de dados moderna.  
A solução será focada na disponibilização de dados com **alta qualidade**, **segurança**, **monitoramento eficiente** e **escalabilidade**, assegurando uma gestão de dados **robusta, confiável e sustentável**.


## 2. Caso de Uso

### **2.0.1 - Integração de Dados Clientes PJ**

Coletar, analisar e disponibilizar dados cadastrais de clientes pessoa física e dados públicos de empresas, com foco em qualidade, governança e integração ao ecossistema analítico corporativo.

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

<img width="674" height="457" alt="image" src="https://github.com/user-attachments/assets/baff0c30-b39f-41e9-9905-bfc177d4209a" />


## 3. Arquitetura da Solução

Para viabilizar o caso de uso descrito no item 2, os dados serão extraídos diretamente de suas fontes de origem e integrados a uma arquitetura de dados Lakehouse, implementada na nuvem pública Microsoft Azure.

<img width="991" height="661" alt="image" src="https://github.com/user-attachments/assets/8e2d9eb2-5fe9-4bc1-b758-2d8262bf1ccc" />



## 4. Monitoramento e Observabilidade
*Em desenvolvimento...*

## 5. Pipelines de Dados
*Em desenvolvimento...*

## 6. Cadastro de Tabelas e Modelagem de Dados
*Em desenvolvimento...*

## 7. Motor de Qualidade de Dados
*Em desenvolvimento...*

## 8. Expurgo de Dados
*Em desenvolvimento...*

## 9. Plano de Recuperação e Local de Armazenamento
*Em desenvolvimento...*

## 10. Visualização de Dados
*Em desenvolvimento...*

## 11. Solução Técnica
*Em desenvolvimento...*

## 12. Análise das Tecnologias Escolhidas

### 12.0.1 Microsoft - Plataforma de Integração como Serviço 

A Microsoft foi nomeada líder no Quadrante Mágico™ da Gartner® de 2024 para Plataforma de Integração como Serviço 
O Azure Integration Services — Inclui o Azure API Management, o Azure Logic Apps, o Azure Service Bus, o Azure Event Grid, o Azure Functions e o **Azure Data Factory**

<img width="656" height="739" alt="image" src="https://github.com/user-attachments/assets/bfad38f6-5e0c-4823-89f2-8a52aca3e82c" />


### 12.0.2 Databricks 

Databricks como Líder no Quadrante Mágico™ da Gartner® de 2025 para Plataformas de Ciência de Dados e Aprendizado de Máquina.
<img width="730" height="748" alt="image" src="https://github.com/user-attachments/assets/3b941f6b-ce65-412c-aebb-3e526e39595a" />



## 13. Referências

https://www.gartner.com/reviews/market/cloud-database-management-systems/compare/product/amazon-simple-storage-service-amazon-s3-vs-azure-data-lake
https://www.databricks.com/blog/databricks-named-leader-2025-gartner-magic-quadrant-data-science-and-machine-learning
https://azure.microsoft.com/en-us/blog/microsoft-named-a-leader-in-2024-gartner-magic-quadrant-for-integration-platform-as-a-service/



