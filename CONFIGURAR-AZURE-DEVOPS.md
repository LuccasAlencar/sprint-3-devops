# 🔧 Configurar Azure DevOps - Sprint 4

## ⚡ IMPORTANTE: Antes de Rodar a Pipeline

Você precisa de **apenas 1 service connection**: Azure Resource Manager

## 📋 Passo a Passo

### 1️⃣ Execute o Script de Deploy Primeiro

**ANTES** de configurar a pipeline, execute o script para criar os recursos:

```bash
chmod +x deploy-sprint4.sh
./deploy-sprint4.sh
```

Isso vai criar:
- ✅ Resource Group
- ✅ Azure Container Registry
- ✅ MySQL Server
- ✅ Key Vault
- ✅ Azure Container Instance

### 2️⃣ Criar Projeto no Azure DevOps

1. Acesse: https://dev.azure.com
2. Clique em **+ New project**
3. Preencha:
   - **Project name**: `Sprint 4 - Azure DevOps`
   - **Visibility**: Private
   - **Version control**: Git
   - **Work item process**: Scrum
4. Clique em **Create**

### 3️⃣ Fazer Push do Código

#### Opção A: Azure Repos (Interno)

```bash
# Remover origin antigo se existir
git remote remove origin

# Adicionar novo origin do Azure Repos
git remote add origin https://dev.azure.com/SEU-ORG/Sprint%204%20-%20Azure%20DevOps/_git/Sprint%204%20-%20Azure%20DevOps

# Push
git add .
git commit -m "Sprint 4 - Deploy Azure DevOps"
git push -u origin main
```

#### Opção B: Manter no GitHub

Se já está no GitHub, apenas conecte o Azure DevOps ao seu repositório.

### 4️⃣ Criar Service Connection (OBRIGATÓRIO)

1. No projeto Azure DevOps, vá em **Project Settings** (canto inferior esquerdo)

2. No menu lateral, clique em **Service connections**

3. Clique em **New service connection**

4. Selecione **Azure Resource Manager** → **Next**

5. Selecione **Service principal (automatic)** → **Next**

6. Preencha:
   - **Scope level**: Subscription
   - **Subscription**: Selecione sua subscription Azure
   - **Resource group**: `rg-sprint4-rm558253`
   - **Service connection name**: `azure-service-connection`
   - ✅ **Grant access permission to all pipelines**

7. Clique em **Save**

### 5️⃣ Criar a Pipeline

1. No Azure DevOps, vá em **Pipelines** (menu lateral)

2. Clique em **New pipeline** (ou **Create pipeline**)

3. **Where is your code?**
   - Se Azure Repos: Selecione **Azure Repos Git**
   - Se GitHub: Selecione **GitHub**

4. Selecione o repositório

5. **Configure your pipeline**:
   - Selecione **Existing Azure Pipelines YAML file**

6. **Select an existing YAML file**:
   - Branch: `main` (ou `master`)
   - Path: `/azure-pipelines.yml`

7. Clique em **Continue**

8. **Revise** a pipeline e clique em **Run**

### 6️⃣ Acompanhar a Execução

A pipeline vai executar 3 stages:

```
┌─────────────────────────────────────────┐
│  STAGE 1: BUILD                         │
│  ├─ Maven Build                         │
│  ├─ Testes Unitários                    │
│  └─ Publicar Artefatos                  │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  STAGE 2: IMAGE                         │
│  ├─ Login no ACR                        │
│  ├─ Build Docker Image                  │
│  └─ Push para ACR                       │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  STAGE 3: DEPLOY                        │
│  ├─ Obter credenciais                   │
│  ├─ Deploy no ACI                       │
│  └─ Verificar status                    │
└─────────────────────────────────────────┘
```

## 🎯 Convidar o Professor

Após tudo configurado:

1. **Project Settings** → **Teams**
2. Clique em **Members**
3. Clique em **+ Add**
4. Digite o email do professor
5. Selecione role: **Contributor**
6. Clique em **Save**

## ❌ Troubleshooting

### ❌ Erro: "azure-service-connection not found"

**Solução**: Você não criou a service connection. Volte ao passo 4️⃣.

### ❌ Erro: "Resource group not found"

**Solução**: Execute o `deploy-sprint4.sh` primeiro para criar os recursos.

### ❌ Erro: "ACR not found"

**Solução**: Execute o `deploy-sprint4.sh` primeiro. O ACR deve existir antes da pipeline rodar.

### ❌ Erro: "Environment production not found"

**Solução**: O Azure DevOps vai criar automaticamente no primeiro run. Aprove quando solicitado.

## ✅ Checklist Final

Antes de rodar a pipeline:

- [ ] Executei `./deploy-sprint4.sh` e os recursos foram criados
- [ ] Criei o projeto no Azure DevOps (Private, Git, Scrum)
- [ ] Fiz push do código para o repositório
- [ ] Criei a service connection `azure-service-connection`
- [ ] Criei a pipeline a partir de `azure-pipelines.yml`
- [ ] A pipeline rodou com sucesso (3 stages verdes)
- [ ] Convidei o professor para o projeto

## 🌐 Após o Deploy

URL da aplicação:
```
http://sprint4-rm558253.eastus.azurecontainer.io:8080
```

Credenciais:
- **admin** / **password**
- **operador** / **password**
- **user** / **password**

---

**Agora sim, tudo está configurado! 🎉**
