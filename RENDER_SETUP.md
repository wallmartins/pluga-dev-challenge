# Guia de Deploy no Render

## 🚀 Variáveis de Ambiente Necessárias

Adicione as seguintes variáveis de ambiente no Render (Environment > Environment Variables):

### Backend (Rails API)

| Variável | Valor | Descrição |
|----------|-------|-----------|
| `RAILS_ENV` | `production` | Ambiente de produção |
| `RAILS_LOG_TO_STDOUT` | `true` | Logs no stdout |
| `RAILS_SERVE_STATIC_FILES` | `true` | Serve arquivos estáticos |
| `SECRET_KEY_BASE` | `30b55eba8bbf0e2439bb2cb6396c149d31351d2eefc698f360ea735dfe8287dc155171f98d88b98f3a58eebdd6d7046b6e28c6b5b437fb951dfbd1db282abc04` | Chave criptográfica segura (gerada) |
| `GEMINI_KEY` | `[sua-chave-do-gemini]` | Obtenha em: https://aistudio.google.com/apikey |
| `CLIENT_ORIGIN` | `https://pluga-frontend.onrender.com` | URL do frontend (será atualizada após deploy) |
| `DATABASE_URL` | Automática | Gerada pelo Render (PostgreSQL) |

### Frontend (Next.js)

| Variável | Valor | Descrição |
|----------|-------|-----------|
| `NODE_ENV` | `production` | Ambiente de produção |
| `NEXT_PUBLIC_API_BASE_URL` | `https://pluga-backend.onrender.com` | URL do backend (será atualizada após deploy) |

---

## 📋 Passo a Passo de Deployment

### 1. Preparar o Repositório

```bash
# Certifique-se de que todas as mudanças estão commitadas
git status

# Faça push para GitHub
git push origin feat/production
```

### 2. Acessar Render

- Acesse [render.com](https://render.com)
- Faça login ou crie uma conta
- Conecte seu repositório GitHub

### 3. Criar o Blueprint (Automático)

O Render lê o arquivo `render.yaml` automaticamente:

```bash
# Verifique se o arquivo está no repositório
cat render.yaml
```

Se não estiver, faça upload manual ou use o método abaixo.

### 4. Deploy Manual no Render

**Opção A: Using Blueprint (Recomendado)**
1. Em Render Dashboard → New → Blueprint
2. Selecione seu repositório
3. Render lerá `render.yaml` automaticamente
4. Revise e confirme

**Opção B: Deploy Individual Services**

#### 4.1 Criar PostgreSQL Database
1. Dashboard → New → PostgreSQL
2. Name: `pluga-db`
3. Plan: Free
4. Copie a **Internal Database URL** (você precisará dela)

#### 4.2 Deploy Backend
1. Dashboard → New → Web Service
2. Selecione seu repositório
3. **Name**: `pluga-backend`
4. **Root Directory**: `server`
5. **Runtime**: Ruby
6. **Build Command**:
   ```bash
   bundle install && bundle exec rails assets:precompile && bundle exec rails db:migrate
   ```
7. **Start Command**:
   ```bash
   bundle exec rails server -p $PORT -b 0.0.0.0
   ```
8. **Environment Variables**: Adicione conforme tabela acima
9. Deploy

#### 4.3 Deploy Frontend
1. Dashboard → New → Web Service
2. Selecione seu repositório
3. **Name**: `pluga-frontend`
4. **Root Directory**: `client`
5. **Runtime**: Node
6. **Build Command**:
   ```bash
   npm install && npm run build
   ```
7. **Start Command**:
   ```bash
   npm run start -- -p $PORT -H 0.0.0.0
   ```
8. **Environment Variables**: Adicione conforme tabela acima
9. Deploy

### 5. Configurar URLs Finais

Após o deploy, você terá URLs como:
- Backend: `https://pluga-backend.onrender.com`
- Frontend: `https://pluga-frontend.onrender.com`

**Atualize as variáveis de ambiente:**

1. Backend → Settings → Environment Variables
   - `CLIENT_ORIGIN`: `https://pluga-frontend.onrender.com`

2. Frontend → Settings → Environment Variables
   - `NEXT_PUBLIC_API_BASE_URL`: `https://pluga-backend.onrender.com`

3. Clique em **Revert/Redeploy** para aplicar mudanças

### 6. Teste a Aplicação

1. Abra `https://pluga-frontend.onrender.com`
2. Teste a funcionalidade de resumo de texto
3. Verifique logs em Dashboard → Logs

---

## 🔧 Troubleshooting

### Backend não inicia

**Erro**: "Application exited early"

**Solução**: Verifique logs:
```
Dashboard → Backend Service → Logs
```

Procure por:
- `SECRET_KEY_BASE not set` → Adicione a variável
- `DATABASE_URL not found` → Conecte o banco de dados
- `GEMINI_KEY missing` → Adicione a chave da API

### Frontend não conecta ao backend

**Erro**: "Failed to fetch from API"

**Solução**:
1. Verifique `NEXT_PUBLIC_API_BASE_URL` está correto
2. Verifique CORS no backend está permitindo a origem
3. Limpe cache do navegador

### Banco de dados vazio

**Erro**: "Relation ... does not exist"

**Solução**: Execute migrations manualmente
```bash
# Via Render Shell
rails db:migrate db:seed
```

---

## 📊 Monitoramento

- **Logs**: Dashboard → Logs
- **Métricas**: Dashboard → Metrics
- **Health Check**: `/up` endpoint

---

## 🔐 Segurança

- ✅ SECRET_KEY_BASE gerada com `SecureRandom`
- ✅ GEMINI_KEY armazenada como variável (não no código)
- ✅ DATABASE_URL fornecida pelo Render
- ✅ CORS configurado dinamicamente
- ✅ `.env` arquivo não está no repositório (use `.gitignore`)

---

## 📝 Próximas Etapas

1. Faça commit das mudanças:
   ```bash
   git add .
   git commit -m "fix: prepare for render deployment"
   git push origin feat/production
   ```

2. Crie Pull Request para `main`

3. Deploy no Render

4. Teste em staging antes de mover para main

---

**Dúvidas?** Consulte [Render Docs](https://render.com/docs)
