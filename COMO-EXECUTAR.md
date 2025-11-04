# 🚀 COMO EXECUTAR - Sprint 4 (RM558253)

## ⚡ Deploy Completo em 2 Passos

### 1️⃣ Login no Azure
```bash
az login
```

### 2️⃣ Executar Deploy
```bash
chmod +x deploy-sprint4.sh delete-sprint4.sh
./deploy-sprint4.sh
```

**Aguarde 8-10 minutos. O script cria automaticamente:**
- ✅ Resource Group
- ✅ Azure Container Registry (ACR)
- ✅ MySQL Container (ACI com MySQL 8.0)
- ✅ Build e Push da imagem Docker
- ✅ Execução do script SQL
- ✅ Application Container (ACI)

---

## 🌐 Acessar Aplicação

Após o deploy, você verá:

```
🌐 URL da Aplicação: http://sprint4-rm558253.westeurope.azurecontainer.io:8080
```

**Credenciais:**
- **admin** / **password** (acesso completo)
- **operador** / **password** (operações)
- **user** / **password** (visualização)

---

## 🔄 Pipeline Azure DevOps (Opcional)

### Passo 1: Criar Projeto
1. Acesse https://dev.azure.com
2. **+ New project**
3. Nome: `Sprint 4 - Azure DevOps`
4. Private, Git, Scrum

### Passo 2: Criar Service Connection
1. **Project Settings** → **Service connections**
2. **New service connection** → **Azure Resource Manager**
3. **Service principal (automatic)**
4. Preencha:
   - Subscription: Sua subscription
   - Resource Group: `rg-sprint4-rm558253`
   - Nome: `azure-service-connection`
   - ✅ Grant access permission to all pipelines
5. **Save**

### Passo 3: Push do Código
```bash
# Se usar Azure Repos
git remote remove origin
git remote add origin <URL-DO-AZURE-REPOS>
git push -u origin main

# Se usar GitHub
git push
```

### Passo 4: Criar Pipeline
1. **Pipelines** → **New pipeline**
2. Selecione seu repositório (Azure Repos ou GitHub)
3. **Existing Azure Pipelines YAML file**
4. Path: `/azure-pipelines.yml`
5. **Run**

**A pipeline executará 3 stages automaticamente:**
```
BUILD (Maven + Testes) → IMAGE (Docker) → DEPLOY (ACI)
```

---

## 🗑️ Deletar Tudo

```bash
./delete-sprint4.sh
```

---

## 🔍 Comandos Úteis

### Ver logs do container
```bash
az container logs -g rg-sprint4-rm558253 -n aci-sprint4-rm558253 --tail 100
```

### Ver status
```bash
az container show -g rg-sprint4-rm558253 -n aci-sprint4-rm558253
```

### Listar recursos
```bash
az resource list -g rg-sprint4-rm558253 -o table
```

### Conectar ao MySQL
```bash
# Credenciais em: .mysql-credentials
source .mysql-credentials
mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME
```

---

## 📋 Checklist Entrega

- [ ] Deploy realizado com sucesso
- [ ] Aplicação acessível pela URL
- [ ] Pipeline Azure DevOps configurada
- [ ] Professor convidado no Azure DevOps
- [ ] PDF com links (GitHub, Azure DevOps, YouTube)
- [ ] Vídeo demonstrativo gravado

---

## ❓ Troubleshooting

### Deploy falha?
- Verifique se está logado: `az account show`
- Verifique subscription ativa: `az account list`

### Container não inicia?
```bash
# Ver logs completos
az container logs -g rg-sprint4-rm558253 -n aci-sprint4-rm558253
```

### Pipeline falha?
- Certifique-se que criou a service connection `azure-service-connection`
- Execute o `deploy-sprint4.sh` antes (cria os recursos Azure)

---

**É isso! Execute `./deploy-sprint4.sh` e aguarde. Tudo será criado automaticamente! 🎉**
