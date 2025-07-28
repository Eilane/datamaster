# DataMaster

## Projeto DataMaster



---

## Sumário

1. [Objetivo](#objetivo)
2. [Arquitetura da Solução](#arquitetura-da-solução)
3. [Monitoramento e Observabilidade](#monitoramento-e-observabilidade)  
4. [Mascaramento de Dados](#mascaramento-de-dados)  
5. [Cadastro de Tabelas e Modelagem de Dados](#cadastro-de-tabelas-e-modelagem-de-dados)  
6. [Motor de Qualidade de Dados](#motor-de-qualidade-de-dados)  
7. [Expurgo de Dados](#expurgo-de-dados)  
8. [Plano de Recuperação e Local de Armazenamento](#plano-de-recuperação-e-local-de-armazenamento)  
9. [Visualização de Dados](#visualização-de-dados)
10. [Solução Técnica](#solução-técnica)
11. [Análise das Tecnologias Escolhidas](#análise-de-mercado-e-tecnologias-escolhidas)  
12. [Referências](#referências)
---

## 1. Objetivo

O projeto tem como objetivo simular e implementar um caso de uso concreto, abordando os principais conceitos e fundamentos essenciais de uma plataforma de dados moderna.  
A solução será focada na disponibilização de dados com **alta qualidade**, **segurança**, **monitoramento eficiente** e **escalabilidade**, assegurando uma gestão de dados **robusta, confiável e sustentável**.

## 2. Arquitetura da Solução
*Em desenvolvimento...*

## 3. Monitoramento e Observabilidade
*Em desenvolvimento...*

## 4. Mascaramento de Dados
*Em desenvolvimento...*

## 5. Cadastro de Tabelas e Modelagem de Dados
*Em desenvolvimento...*

## 6. Motor de Qualidade de Dados
*Em desenvolvimento...*

## 7. Expurgo de Dados
*Em desenvolvimento...*

## 8. Plano de Recuperação e Local de Armazenamento
*Em desenvolvimento...*

## 9. Visualização de Dados
*Em desenvolvimento...*

## 10. Solução Técnica
*Em desenvolvimento...*

## 11. Análise das Tecnologias Escolhidas

1.0.1 Comparativo: Azure Functions vs Docker vs AKS (Python API Consumer)

| Critério                        | Azure Functions                          | Docker (App Service / ACI)                | AKS (Azure Kubernetes Service)             |
|--------------------------------|-------------------------------------------|-------------------------------------------|--------------------------------------------|
| **Complexidade do Projeto**    | Baixa                                     | Média                                     | Alta                                       |
| **Facilidade de Deploy**       | Muito fácil                               | Fácil                                     | Complexo                                   |
| **Custo**                      | Muito baixo (paga por uso)                | Médio                                     | Alto (infraestrutura contínua)             |
| **Escalabilidade**             | Automática (serverless)                   | Manual ou limitada                        | Avançada (autoescalonamento via K8s)       |
| **Tempo de Execução**          | Limitado (máx. 5–10 min)                  | Ilimitado                                 | Ilimitado                                  |
| **Controle sobre ambiente**    | Limitado (restrições do runtime)          | Alto (ambiente docker customizado)        | Total (Kubernetes completo)                |
| **Manutenção de Infraestrutura** | Nenhuma (gerenciado pela Azure)         | Baixa                                     | Alta (você gerencia o cluster)             |
| **Ciclo de vida do container** | N/A                                       | Controlado por você                        | Totalmente gerenciado por você             |
| **Indicado para**              | Jobs simples, agendamentos, webhooks      | Microsserviços, APIs REST em contêiner    | Sistemas distribuídos, alta escala         |
| **Startup Time (cold start)**  | Médio (em planos gratuitos)               | Rápido                                    | Rápido                                     |
| **CI/CD**                      | Simples com GitHub Actions                | Bom suporte com Docker pipelines           | Avançado com Helm/Kustomize/DevOps         |
| **Persistência de Estado**     | Não recomendado                           | Possível com volume externo               | Gerenciado via Persistent Volume Claims    |

---
| Caso de uso                                       | Melhor opção              |
|--------------------------------------------------|---------------------------|
| Job simples para consumir API periodicamente     | **Azure Functions**     |
| Aplicação com lógica moderada em contêiner       | **Docker (App Service)**|
| Infraestrutura de produção complexa e escalável  | **AKS (Kubernetes)**    |


## 12. Referências

https://www.gartner.com/reviews/market/cloud-database-management-systems/compare/product/amazon-simple-storage-service-amazon-s3-vs-azure-data-lake


