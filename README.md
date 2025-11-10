# Pluga Challenge - Sumarizador de Texto com IA

[![Backend CI](https://github.com/wallmartins/pluga-dev-challenge/actions/workflows/backend-ci.yml/badge.svg)](https://github.com/wallmartins/pluga-dev-challenge/actions/workflows/backend-ci.yml)
[![Frontend CI](https://github.com/wallmartins/pluga-dev-challenge/actions/workflows/frontend-ci.yml/badge.svg)](https://github.com/wallmartins/pluga-dev-challenge/actions/workflows/frontend-ci.yml)

Aplicação full-stack para gerar resumos de texto utilizando inteligência artificial com Ruby on Rails e Next.js.

## Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
  - [Arquitetura do Servidor](#arquitetura-do-servidor)
  - [Arquitetura do Cliente](#arquitetura-do-cliente)
- [Stack Tecnológica](#stack-tecnológica)
- [Configuração](#configuração)
  - [Pré-requisitos](#pré-requisitos)
  - [Configuração de Ambiente](#configuração-de-ambiente)
  - [Executando com Docker](#executando-com-docker)
  - [Executando Localmente](#executando-localmente)
- [Documentação da API](#documentação-da-api)
- [Testes](#testes)
- [Pipeline CI/CD](#pipeline-cicd)
- [Decisões de Design](#decisões-de-design)
- [Reflexão Pós-Desafio](#reflexão-pós-desafio)

## Visão Geral

Esta aplicação permite que equipes de conteúdo colem textos brutos (rascunhos de blogs, transcrições, etc.) e recebam resumos gerados por IA que podem ser reutilizados. O sistema processa os resumos de forma assíncrona usando background jobs para melhor escalabilidade e experiência do usuário.

**URLs Locais:**

- API Backend: `http://localhost:3000`
- Frontend: `http://localhost:4000`
- Documentação da API: `http://localhost:3000/api-docs`

## Arquitetura

### Arquitetura do Servidor

O backend implementa uma **arquitetura em camadas personalizada** que vai além do padrão MVC tradicional do Rails. Esta abordagem adota os princípios de **Clean Architecture** e **SOLID**, mantendo a lógica de negócio isolada das preocupações do framework.

#### Por que não Rails Padrão?

Embora a convenção sobre configuração do Rails seja poderosa, os padrões de MVC muito utilizado pelo framework que podem levar a:

- Responsabilidades misturadas (HTTP + lógica de negócio + acesso a dados)
- Código difícil de testar
- Acoplamento forte ao framework
- Dificuldade em escalar regras de negócio complexas

Em vez disso, este projeto usa uma **arquitetura em camadas** com fronteiras claras:

```
┌─────────────────────────────────────────────────────────┐
│                    Controllers                          │
│         (Preocupações HTTP, orquestração leve)          │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                  Interactors                            │
│      (Validação de entrada, regras de interação)        │
│         (Coordenação entre camadas)                     │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                    Models                               │
│           (Regras de negócio do domínio)                │
│         (Validações de domínio, enums)                  │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                   Services                              │
│         (Operações específicas de domínio)              │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                    Clients                              │
│         (Integração com APIs externas)                  │
│  ┌─────────────┬──────────────┬─────────────┐          │
│  │ HttpClient  │RequestBuilder│ResponseHandler│         │
│  └─────────────┴──────────────┴─────────────┘          │
└─────────────────────────────────────────────────────────┘
```

#### Responsabilidades das Camadas

**1. Controllers** ([server/app/controllers](server/app/controllers))

- Lidam com requisições/respostas HTTP
- Filtragem de parâmetros
- Delegam para interactors
- Tratamento global de exceções

**2. Interactors** ([server/app/interactors](server/app/interactors))

- **Validam entrada da requisição** (regras de interação cliente-servidor)
- Orquestram workflows de negócio
- Coordenam entre services e models
- Responsabilidade única por caso de uso

**3. Models** ([server/app/models](server/app/models))

- **Contêm regras de negócio do domínio**
- Validações de dados (constraints de banco)
- Enums para gerenciamento de estado
- Models enxutos (evitando fat models)

**4. Services** ([server/app/services](server/app/services))

- Encapsulam operações específicas de domínio
- Transformam dados entre camadas
- Sem conhecimento de HTTP

**5. Clients** ([server/app/clients](server/app/clients))

- Comunicação com APIs externas (Gemini)
- Separados em três responsabilidades:
  - `HttpClient`: Transporte HTTP (Net::HTTP com timeouts)
  - `RequestBuilder`: Construção de payload com validação
  - `ResponseHandler`: Parse de resposta e mapeamento de erros

**6. Jobs** ([server/app/jobs](server/app/jobs))

- Processamento em background com Solid Queue
- Geração assíncrona de resumos
- Atualizações de status e tratamento de erros

**7. Exceptions** ([server/app/exceptions](server/app/exceptions))

- Hierarquia customizada de exceções
- Respostas de erro estruturadas
- Contexto e metadados para debugging

**8. Libs** ([server/app/libs](server/app/libs))

- Funções utilitárias
- Sanitização de entrada com proteção contra prompt injection

#### Princípios SOLID na Prática

**Single Responsibility Principle (SRP)**

- Controllers: apenas HTTP
- Interactors: apenas validação de entrada e orquestração
- Models: apenas regras de negócio do domínio
- Services: apenas lógica de domínio
- Clients: comunicação externa dividida em HttpClient, RequestBuilder, ResponseHandler

**Open/Closed Principle (OCP)**

- Hierarquia de exceções extensível sem modificação
- Novos services podem ser adicionados sem alterar código existente
- Strategy pattern para tratamento de erros

**Dependency Inversion Principle (DIP)**

- Controllers dependem de abstrações de interactors
- Services dependem de interfaces de clients
- Tratamento de erros abstraído através de classes de exceção

#### Features de Segurança

1. **Sanitização de Entrada** ([server/app/libs/input_sanitizer.rb](server/app/libs/input_sanitizer.rb))

   - Detecção de prompt injection
   - Normalização UTF-8
   - Remoção de null bytes
   - Remoção de comentários HTML

2. **Tratamento de Erros**

   - Sem dados sensíveis nas respostas
   - Formato de erro estruturado com contexto
   - Rastreamento de Request ID

3. **Análise Estática**
   - Brakeman para vulnerabilidades de segurança
   - Bundler Audit para checagem de dependências

#### Schema do Banco de Dados

**Tabela: summaries**

```ruby
{
  id: integer (chave primária)
  original_post: text (obrigatório, mín 30 caracteres)
  summary: text (opcional)
  status: string (enum: pending/completed/failed, padrão: pending)
  summarized_at: datetime (opcional)
  created_at: datetime
  updated_at: datetime
}
```

### Arquitetura do Cliente

O frontend segue **padrões modernos do React** com features do React 19, enfatizando componentes funcionais, custom hooks e separação de responsabilidades.

```
┌─────────────────────────────────────────────────────────┐
│                    App Router                           │
│              (Páginas Next.js 16)                       │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                  Components                             │
│         (Puros, apresentacionais)                       │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                Custom Hooks                             │
│         (Extração de lógica de negócio)                 │
│  • useHomeSummaries (polling, mutations)                │
│  • useTextEditorLogic (validação)                       │
│  • useSidebarToggle (estado de UI)                      │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                     Lib                                 │
│    • API Client (Axios)                                 │
│    • Types (definições TypeScript)                      │
│    • Validations (mín 300 caracteres)                   │
│    • Query Provider (config React Query)                │
└─────────────────────────────────────────────────────────┘
```

#### Features Principais

**1. Gerenciamento de Estado**

- **Estado do Servidor**: TanStack React Query v5
  - Cache automático (5 minutos de stale time)
  - Polling para resumos pendentes (intervalo de 1.5s)
  - Atualizações otimistas
  - Refetch em background
- **Estado de UI**: React hooks (useState, useEffect)
- **Estado Global**: React Context (gerenciamento de tema)

**2. Atualizações em Tempo Real**

- Polling automático quando resumo está pendente
- Para o polling ao completar/falhar
- Feedback visual com animações de loading

**3. Type Safety**

- TypeScript end-to-end (modo strict)
- Inferência de tipos para React Query
- Sem tipos `any`

**4. Design Responsivo**

- Abordagem mobile-first
- Drawer de sidebar no mobile
- Suporte a modo escuro
- Componentes acessíveis (Radix UI)

## Stack Tecnológica

### Backend

- **Ruby 3.4** + **Rails 8.1** (modo API-only)
- **PostgreSQL 15**
- **Stack Moderna do Rails 8**:
  - Solid Queue (background jobs)
  - Solid Cache (caching)
  - Solid Cable (WebSockets)
- **Testes**: RSpec, FactoryBot, Shoulda Matchers, SimpleCov, WebMock, Faker
- **Documentação da API**: Rswag (Swagger/OpenAPI)
- **Cliente HTTP**: Faraday
- **Serialização**: Active Model Serializers
- **Qualidade de Código**: RuboCop (Rails Omakase)
- **Segurança**: Brakeman, Bundler Audit

### Frontend

- **Next.js 16** (App Router)
- **React 19**
- **TypeScript** (modo strict)
- **TanStack React Query v5** (estado do servidor)
- **Axios** (cliente HTTP)
- **Tailwind CSS v4** (estilização)
- **Radix UI** (componentes acessíveis)
- **Lucide React** (ícones)
- **Testes**: Jest, React Testing Library

### Infraestrutura

- **Docker** + **Docker Compose**
- **PostgreSQL 15** (containerizado)
- **Puma** (servidor web)

## Configuração

### Pré-requisitos

- Docker e Docker Compose
- (Opcional para desenvolvimento local) Ruby 3.4+, Node.js 20+, PostgreSQL 15+

### Configuração de Ambiente

#### 1. Obter Chave da API Gemini

Visite [Google AI Studio](https://aistudio.google.com/apikey) para obter sua chave de API gratuita.

#### 2. Configurar Ambiente do Servidor

Copie o arquivo de exemplo e configure suas variáveis:

```bash
cd server
cp .env.example .env
```

Edite o arquivo `server/.env` e adicione sua chave do Gemini:

```bash
GEMINI_KEY=sua_chave_gemini_aqui
```

O arquivo [server/.env.example](server/.env.example) contém todas as variáveis necessárias com valores padrão para desenvolvimento.

#### 3. Configurar Ambiente do Cliente

Copie o arquivo de exemplo:

```bash
cd client
cp .env.example .env.local
```

O arquivo [client/.env.example](client/.env.example) já está configurado com os valores padrão. Você só precisa ajustar se estiver usando portas diferentes.

### Executando com Docker

**Iniciar todos os serviços:**

```bash
docker compose up
```

**Configurar banco de dados (primeira execução):**

```bash
docker compose exec server rails db:create db:migrate
```

**Acessar:**

- Frontend: http://localhost:4000
- API Backend: http://localhost:3000
- Documentação da API: http://localhost:3000/api-docs

**Parar serviços:**

```bash
docker compose down
```

**Reiniciar do zero (remover volumes):**

```bash
docker compose down -v
docker compose up --build
```

### Executando Localmente

#### Configuração do Servidor

```bash
cd server
bundle install
rails db:create db:migrate
rails server -p 3000
```

#### Configuração do Cliente

```bash
cd client
npm install
npm run dev
```

## Documentação da API

### Endpoints

**POST /summaries**
Criar um novo resumo (processamento assíncrono via background job)

Requisição:

```bash
curl -X POST http://localhost:3000/summaries \
  -H "Content-Type: application/json" \
  -d '{"original_post": "Seu texto aqui (mínimo 30 caracteres)"}'
```

Resposta (201 Created):

```json
{
  "id": 1,
  "original_post": "Seu texto aqui...",
  "summary": null,
  "status": "pending",
  "summarized_at": null,
  "created_at": "2025-01-09T10:00:00.000Z",
  "updated_at": "2025-01-09T10:00:00.000Z"
}
```

**GET /summaries/:id**
Buscar um resumo específico

Requisição:

```bash
curl http://localhost:3000/summaries/1
```

Resposta (200 OK):

```json
{
  "id": 1,
  "original_post": "Seu texto aqui...",
  "summary": "Resumo gerado por IA...",
  "status": "completed",
  "summarized_at": "2025-01-09T10:00:05.000Z",
  "created_at": "2025-01-09T10:00:00.000Z",
  "updated_at": "2025-01-09T10:00:05.000Z"
}
```

**GET /summaries**
Listar todos os resumos (ordenados do mais recente)

Requisição:

```bash
curl http://localhost:3000/summaries
```

Resposta (200 OK):

```json
[
  {
    "id": 2,
    "original_post": "Segundo texto...",
    "summary": "Resumo 2...",
    "status": "completed",
    "summarized_at": "2025-01-09T10:05:00.000Z",
    "created_at": "2025-01-09T10:04:00.000Z",
    "updated_at": "2025-01-09T10:05:00.000Z"
  },
  {
    "id": 1,
    "original_post": "Primeiro texto...",
    "summary": "Resumo 1...",
    "status": "completed",
    "summarized_at": "2025-01-09T10:00:05.000Z",
    "created_at": "2025-01-09T10:00:00.000Z",
    "updated_at": "2025-01-09T10:00:05.000Z"
  }
]
```

### Respostas de Erro

**400 Bad Request** (erro de validação):

```json
{
  "status": 400,
  "error_code": "VALIDATION_ERROR",
  "message": "Original post is too short (minimum is 30 characters)",
  "details": {
    "original_post": ["is too short (minimum is 30 characters)"]
  },
  "timestamp": "2025-01-09T10:00:00.000Z",
  "request_id": "abc123"
}
```

**404 Not Found**:

```json
{
  "status": 404,
  "error_code": "NOT_FOUND",
  "message": "Summary not found",
  "timestamp": "2025-01-09T10:00:00.000Z",
  "request_id": "abc123"
}
```

**500 Internal Server Error**:

```json
{
  "status": 500,
  "error_code": "INTERNAL_SERVER_ERROR",
  "message": "An unexpected error occurred",
  "timestamp": "2025-01-09T10:00:00.000Z",
  "request_id": "abc123"
}
```

**Documentação Interativa da API**: Visite http://localhost:3000/api-docs para o Swagger UI.

## Testes

### Testes do Servidor

```bash
cd server

# Executar todos os testes
bundle exec rspec

# Executar arquivo de teste específico
bundle exec rspec spec/interactors/generate_summaries_spec.rb

# Executar com cobertura
bundle exec rspec --format documentation

# Lint
bundle exec rubocop
```

**Estrutura de Testes:**

- Testes organizados por features comportamentais (blocos describe)
- FactoryBot para dados de teste
- WebMock para mock de APIs externas
- SimpleCov para relatório de cobertura

### Testes do Cliente

```bash
cd client

# Executar todos os testes
npm test

# Executar em modo watch
npm test -- --watch

# Executar com cobertura
npm test -- --coverage

# Lint
npm run lint
```

**Estratégia de Testes:**

- Testes de comportamento (não de implementação)
- Testes de hooks com renderHook
- Simulação de eventos de usuário
- Cobertura de casos extremos

## Pipeline CI/CD

O projeto utiliza GitHub Actions para integração e entrega contínuas. O pipeline executa automaticamente em cada push e pull request.

### Workflows Configurados

**Backend CI** ([.github/workflows/backend-ci.yml](.github/workflows/backend-ci.yml))

- Lint com RuboCop
- Testes com RSpec
- Análise de segurança com Brakeman
- Auditoria de dependências com Bundler Audit
- Relatório de cobertura

**Frontend CI** ([.github/workflows/frontend-ci.yml](.github/workflows/frontend-ci.yml))

- Lint com ESLint
- Type checking com TypeScript
- Testes com Jest
- Build de produção

### Status dos Workflows

Os badges de status dos workflows aparecem no README e indicam a saúde atual do código.

## Decisões de Design

### Backend: Arquitetura em Camadas ao invés de Rails Tradicional

**Decisão**: Implementar uma arquitetura em camadas personalizada ao invés de fat models ou fat controllers.

**Justificativa**:

- **Manutenibilidade**: Cada camada tem uma única responsabilidade, tornando o código mais fácil de entender e modificar
- **Testabilidade**: Lógica de negócio isolada das preocupações do framework permite testes mais rápidos e focados
- **Escalabilidade**: Fácil adicionar novas features sem tocar em camadas existentes
- **Clean Architecture**: Regras de negócio não dependem do Rails, tornando o core portável

**Trade-offs**:

- Mais arquivos e pastas (maior complexidade inicial)
- Requer alinhamento da equipe sobre padrões de arquitetura
- Levemente mais boilerplate para operações simples

**Benefícios**:

- Sem fat models lotados com lógica de negócio e preocupações HTTP
- Controllers se tornam orquestradores enxutos
- Services permanecem focados em operações de domínio
- Fácil trocar dependências externas (Gemini → OpenAI)

### Separação entre Interactors e Models

**Decisão**: Interactors validam regras de interação (entrada da requisição), Models contêm regras de negócio do domínio.

**Justificativa**:

- **Interactors**: Lidam com validação de entrada (ex: tamanho mínimo do texto para enviar à API)
- **Models**: Contêm regras de negócio do domínio (ex: validações de banco de dados, enums de status)
- Esta separação evita fat models e mantém responsabilidades claras

### Frontend: Custom Hooks ao invés de Lógica em Componentes

**Decisão**: Extrair toda lógica de negócio para custom hooks, mantendo componentes puros.

**Justificativa**:

- **Reusabilidade**: Hooks podem ser compartilhados entre componentes
- **Testabilidade**: Lógica testada independentemente da UI
- **Separação de Responsabilidades**: Componentes apenas renderizam, hooks lidam com estado/efeitos
- **Manutenibilidade**: Mudanças na lógica não requerem updates em componentes

**Exemplos**:

- `useHomeSummaries`: Polling, mutations, invalidação de cache
- `useTextEditorLogic`: Validação, submissão, tratamento de erros
- `useSidebarToggle`: Gerenciamento de estado de UI

### Processamento Assíncrono com Background Jobs

**Decisão**: Processar resumos de forma assíncrona ao invés de sincronamente na requisição.

**Justificativa**:

- **Experiência do Usuário**: Resposta imediata (sem timeout esperando a IA)
- **Escalabilidade**: Lidar com múltiplas requisições concorrentemente
- **Resiliência**: Retry de jobs falhados sem intervenção do usuário
- **Gerenciamento de Recursos**: Não bloquear web workers

**Implementação**: Solid Queue para background jobs, polling no frontend para atualizações de status.

### Atualizações em Tempo Real com Polling

**Decisão**: Usar polling ao invés de WebSockets para atualizações de status.

**Justificativa**:

- **Simplicidade**: Sem necessidade de infraestrutura de WebSocket
- **Confiabilidade**: HTTP é mais estável que conexões persistentes
- **Caching**: Aproveitar estratégias de cache e refetch do React Query
- **Escala**: Aceitável para este caso de uso (intervalo de 1.5s)

**Trade-offs**:

- Mais requisições HTTP que WebSockets
- Leve atraso nas atualizações (máximo de 1.5s)

### Gemini ao invés de OpenAI

**Decisão**: Usar a API do Google Gemini ao invés da OpenAI.

**Justificativa**:

- **Custo**: Gemini oferece tier gratuito generoso
- **Performance**: Qualidade comparável para sumarização
- **Disponibilidade**: Sem lista de espera ou requisitos de billing para testes

**Arquitetura**: Camada de client desenhada para facilmente trocar provedores (apenas implementar nova classe de client).

## Reflexão Pós-Desafio

### O que Melhoraria com Mais Tempo

**1. WebSockets para Atualizações em Tempo Real**
Atualmente usando polling para atualizações de status. WebSockets (via Action Cable) forneceriam atualizações instantâneas e reduziriam overhead de HTTP.

**2. Rate Limiting e Throttling**
Implementar rate limiting usando Rack::Attack para prevenir abuso da API e gerenciar quota da API Gemini.

**3. Camada de Caching**
Adicionar caching Redis para resumos frequentemente acessados e respostas do Gemini para reduzir chamadas à API e melhorar tempos de resposta.

**4. Recuperação de Erros Aprimorada**

- Exponential backoff para retries do Gemini
- Dead letter queue para jobs falhados
- Melhor feedback ao usuário para diferentes tipos de erro

**5. Monitoramento e Observabilidade**

- Logging estruturado (logs JSON)
- Integração com APM (New Relic, DataDog)
- Rastreamento de requisições através das camadas
- Profiling de performance

**6. Autenticação e Multi-tenancy**

- Autenticação de usuário (Devise ou JWT)
- Resumos com escopo de usuário
- Quotas de uso por usuário

**7. Features Avançadas de Frontend**

- Scroll infinito para lista de resumos
- Busca e filtragem
- Exportar resumos (PDF, Markdown)
- Visualização de diff (destacar mudanças entre original e resumo)

**8. Melhorias de Acessibilidade**

- Auditoria de conformidade WCAG 2.1 AA
- Testes com leitores de tela
- Melhorias de navegação por teclado
- Gerenciamento de foco

**9. Otimização de Performance**

- Análise de indexação de banco de dados
- Prevenção de queries N+1 (gem Bullet)
- Code splitting no frontend
- Otimização de imagens

### Trade-offs Realizados

**1. Polling vs WebSockets**
**Escolhido**: Polling
**Por quê**: Implementação mais simples, latência aceitável para este caso de uso
**Trade-off**: Mais requisições HTTP, leve atraso nas atualizações

**2. Processamento Síncrono vs Assíncrono**
**Escolhido**: Async com background jobs
**Por quê**: Melhor UX, escalabilidade, resiliência
**Trade-off**: Arquitetura mais complexa, consistência eventual

**3. Arquitetura Customizada vs Convenções do Rails**
**Escolhido**: Arquitetura em camadas
**Por quê**: Separação limpa de responsabilidades, testabilidade, manutenibilidade
**Trade-off**: Mais arquivos, curva de aprendizado mais íngreme para novos membros da equipe

**4. Validação Client-side (300 chars) vs Server-side (30 chars)**
**Escolhido**: Validação mais estrita no client
**Por quê**: Melhor UX, reduzir chamadas desnecessárias à API
**Trade-off**: Regras de validação inconsistentes (necessita alinhamento)

**5. Tier Gratuito do Gemini**
**Escolhido**: Gemini ao invés de OpenAI
**Por quê**: Sem custo, sem configuração de billing necessária para testes
**Trade-off**: Rate limits, potenciais diferenças de qualidade

**6. Tempo de Cache do React Query (5 minutos)**
**Escolhido**: 5 minutos de stale time
**Por quê**: Equilíbrio entre frescor dos dados e chamadas à API
**Trade-off**: Pode mostrar dados desatualizados por até 5 minutos

### Principais Aprendizados

Este projeto demonstra:

- **Clean Architecture**: Lógica de negócio isolada das preocupações do framework
- **Princípios SOLID**: Responsabilidade única, inversão de dependência, aberto/fechado
- **Stack Moderna**: Rails 8, React 19, Next.js 16 com padrões mais recentes
- **Foco em Qualidade**: Testes abrangentes, linting, scanning de segurança
- **Experiência do Desenvolvedor**: Docker para consistência, documentação clara
- **Pronto para Produção**: Tratamento de erros, background jobs, logging estruturado, CI/CD

A arquitetura customizada pode parecer over-engineered para uma aplicação CRUD simples, mas fornece uma base sólida para crescimento. À medida que os requisitos evoluem (novos provedores de IA, regras de negócio complexas, multi-tenancy), esta arquitetura se adaptará sem refatoração maior.

---

**Desenvolvido com** ❤️ **para o Pluga Challenge**
