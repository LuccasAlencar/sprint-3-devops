# Guia Sprint 4 - CI/CD com Azure DevOps

Este guia explica como configurar e executar o pipeline CI/CD completo para a Sprint 4.

## 📋 Pré-requisitos

1. **Azure CLI** instalado e configurado
   ```bash
   az login
   az account set --subscription "SUA_SUBSCRIPTION"
   ```

2. **Azure DevOps CLI extension**
   ```bash
   az extension add --name azure-devops
   ```

3. **Docker** (para testes locais)
4. **Conta Azure DevOps** com permissões para criar projetos
5. **GitHub** com repositório do projeto

## 🚀 Passo a Passo

### 1. Configurar Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```bash
# Identificador (usado para nomear recursos)
RM=seu_rm_aqui

# Credenciais do banco (serão protegidas no Azure DevOps)
DB_PASSWORD=Admin123!
DB_NAME=sprint3
DB_USER=root
```

### 2. Executar Script de Configuração do Azure DevOps

```bash
chmod +x setup-azure-devops.sh
./setup-azure-devops.sh
```

Este script irá:
- ✅ Criar o projeto no Azure DevOps
- ✅ Configurar grupo de variáveis protegidas
- ✅ Solicitar criação de Service Connections
- ✅ Preparar tudo para o pipeline

**Importante:** O script irá te guiar para criar manualmente as Service Connections (ACR e Azure Subscription) no portal do Azure DevOps.

### 3. Conectar Repositório GitHub

1. Acesse o projeto no Azure DevOps
2. Vá em **Repos** → **Files** → **Import repository**
3. Conecte seu repositório GitHub
4. Autorize a conexão

### 4. Criar Pipeline

1. Acesse **Pipelines** → **New pipeline**
2. Selecione **GitHub** como origem
3. Autorize se necessário
4. Selecione o repositório
5. Escolha **Existing Azure Pipelines YAML file**
6. Selecione o branch `master` e o arquivo `azure-pipelines.yml`
7. Clique em **Run**

### 5. Configurar Variáveis Protegidas

O script `setup-azure-devops.sh` já cria as variáveis, mas você pode verificar/editar:

1. Acesse **Pipelines** → **Library** → **Variable groups**
2. Edite o grupo `Sprint4-Config`
3. Verifique que `DB_PASSWORD` está marcada como **Secret**

### 6. Convidar Professor

**OBRIGATÓRIO:** O professor precisa ter acesso ao projeto:

1. Acesse **Project settings** → **Users**
2. Clique em **Add users**
3. Adicione o email do professor
4. Nível de acesso: **Basic**
5. Envie o convite

### 7. Popular Banco de Dados (Após Deploy)

Após o primeiro deploy, execute:

```bash
chmod +x populate-db.sh
./populate-db.sh
```

Ou manualmente:

```bash
# Obter IP do MySQL
DB_IP=$(az container show --resource-group rg-sprint3-rm${RM} --name aci-db-sprint3-rm${RM} --query ipAddress.ip -o tsv)

# Popular banco
docker run --rm -i -e MYSQL_PWD=Admin123! mysql:8.0 \
  mysql -h $DB_IP -u root -pAdmin123! sprint3 < script_bd.sql
```

### 8. Verificar Status

```bash
chmod +x check-status.sh
./check-status.sh
```

## 🔄 Fluxo CI/CD

### CI (Continuous Integration)
**Trigger:** Push para branch `master`

**Etapas:**
1. Checkout do código
2. Instalar Java e Maven
3. Compilar aplicação
4. **Executar testes unitários**
5. Build do JAR
6. **Build da imagem Docker**
7. **Push para Azure Container Registry (ACR)**
8. **Publicar artefatos** (JAR, Dockerfile, script SQL)

### CD (Continuous Deployment)
**Trigger:** Após geração de artefato (após CI)

**Etapas:**
1. Verificar/criar container MySQL no ACI
2. Obter IP do MySQL
3. **Deploy da aplicação no ACI**
4. Configurar variáveis de ambiente (DB_HOST, DB_PASSWORD, etc.)
5. Publicar informações de acesso (URL, IP)

## 📊 Verificar Pipeline

### No Azure DevOps:
1. Acesse **Pipelines** → Seu pipeline
2. Veja o histórico de execuções
3. Clique em uma execução para ver detalhes
4. Verifique:
   - ✅ Testes executados e resultados
   - ✅ Artefatos publicados
   - ✅ Deploy concluído

### Via Azure CLI:
```bash
# Ver containers criados
az container list --resource-group rg-sprint3-rm${RM} -o table

# Ver logs da aplicação
az container logs --resource-group rg-sprint3-rm${RM} --name aci-app-sprint3-rm${RM} --tail 50
```

## 🧪 Testar CRUD Completo

Após o deploy, acesse a aplicação e realize:

1. **CREATE** - Criar nova moto
2. **READ** - Listar motos
3. **UPDATE** - Editar moto existente
4. **DELETE** - Excluir moto

**URLs de acesso:**
- Login: `admin` / `password`
- Operador: `operador` / `password`
- User: `user` / `password`

## 🔍 Troubleshooting

### Pipeline falha no build
- Verifique se o Java está instalado corretamente
- Verifique se o Maven consegue baixar dependências

### Pipeline falha no deploy
- Verifique se as Service Connections estão configuradas
- Verifique se o Resource Group existe
- Verifique se o ACR está criado e acessível

### Container não inicia
- Verifique os logs: `az container logs --resource-group ... --name ...`
- Verifique se o IP do MySQL está correto
- Verifique variáveis de ambiente

### Não consegue conectar ao banco
- Verifique se o container MySQL está rodando
- Verifique se o IP está acessível
- Execute: `./check-status.sh`

## 📝 Checklist de Entrega

- [ ] Projeto criado no Azure DevOps
- [ ] Pipeline YAML configurado e funcionando
- [ ] Variáveis protegidas configuradas (DB_PASSWORD)
- [ ] Service Connections criadas (ACR e Azure)
- [ ] Repositório GitHub conectado
- [ ] Pipeline trigger configurado (master branch)
- [ ] Testes automáticos executando no CI
- [ ] Artefatos sendo publicados
- [ ] Deploy automático para ACI funcionando
- [ ] Professor convidado com acesso Basic
- [ ] Banco de dados populado
- [ ] CRUD completo funcionando na aplicação deployada

## 🗑️ Limpeza

Para remover todos os recursos:

```bash
./delete.sh
```

Ou apenas o Resource Group:

```bash
az group delete --name rg-sprint3-rm${RM} --yes --no-wait
```

## 📚 Arquivos Criados

- `azure-pipelines.yml` - Pipeline CI/CD completo
- `setup-azure-devops.sh` - Script de configuração inicial
- `populate-db.sh` - Script para popular banco após deploy
- `check-status.sh` - Script para verificar status dos containers
- `SPRINT4-GUIDE.md` - Este guia

## 🎯 Requisitos Atendidos

✅ **Pipeline YAML** configurado  
✅ **CI**: Build + Testes automáticos  
✅ **CD**: Deploy automático para ACI  
✅ **Trigger CI**: Mudanças na branch master  
✅ **Trigger CD**: Após geração de artefato  
✅ **Variáveis protegidas**: DB credentials  
✅ **Artefatos**: Publicação no Azure DevOps  
✅ **Testes**: Execução e publicação de resultados  
✅ **Deploy ACI**: Usando Docker image  
✅ **Banco na nuvem**: MySQL em container ACI  

---

**Desenvolvido para Sprint 4 - DevOps Tools & Cloud Computing - FIAP**

