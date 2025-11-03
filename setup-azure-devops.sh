#!/bin/bash

# Script para configurar o projeto Azure DevOps para Sprint 4
# Este script configura:
# - Projeto no Azure DevOps
# - Variáveis protegidas (grupo de variáveis)
# - Service Connections (ACR e Azure Subscription)
# - Permissões e configurações

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configuração do Azure DevOps para Sprint 4 ===${NC}"
echo ""

# Verificar se Azure CLI está instalado
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI não está instalado.${NC}"
    echo "Instale em: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar se Azure DevOps CLI está instalado
if ! command -v az devops &> /dev/null; then
    echo -e "${YELLOW}⚠️  Azure DevOps CLI extension não encontrada. Instalando...${NC}"
    az extension add --name azure-devops
fi

# Carregar variáveis do .env
if [ -f .env ]; then
    set -a
    . ./.env
    set +a
fi

# Variáveis obrigatórias
if [ -z "${RM:-}" ]; then
    echo -e "${RED}❌ Variável RM não definida. Crie um .env com RM=seu_rm${NC}"
    exit 1
fi

# Solicitar informações do Azure DevOps
echo -e "${YELLOW}Informe os dados do Azure DevOps:${NC}"
read -p "Organização Azure DevOps (ex: https://dev.azure.com/minhaorg): " ORG_URL
read -p "Nome do Projeto (padrão: Sprint 4 - Azure DevOps): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-"Sprint 4 - Azure DevOps"}

read -p "Nome do Professor: " PROFESSOR_NAME
read -p "Turma (ex: 2TDSX): " TURMA

# Descrição do projeto
PROJECT_DESCRIPTION="Projeto para entrega da Sprint 4 do professor ${PROFESSOR_NAME} - Integrantes: RM${RM}"

echo ""
echo -e "${YELLOW}Informe os dados do Azure:${NC}"
read -p "Subscription ID ou Name: " SUBSCRIPTION_ID
read -p "Resource Group (padrão: rg-sprint3-rm${RM}): " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-"rg-sprint3-rm${RM}"}

read -p "ACR Name (padrão: acrsprint3rm${RM}): " ACR_NAME
ACR_NAME=${ACR_NAME:-"acrsprint3rm${RM}"}

read -p "ACI DB Name (padrão: aci-db-sprint3-rm${RM}): " ACI_DB_NAME
ACI_DB_NAME=${ACI_DB_NAME:-"aci-db-sprint3-rm${RM}"}

read -p "ACI App Name (padrão: aci-app-sprint3-rm${RM}): " ACI_APP_NAME
ACI_APP_NAME=${ACI_APP_NAME:-"aci-app-sprint3-rm${RM}"}

read -p "DNS Name Label (padrão: sprint3-rm${RM}): " DNS_NAME_LABEL
DNS_NAME_LABEL=${DNS_NAME_LABEL:-"sprint3-rm${RM}"}

# Credenciais do banco (serão protegidas)
echo ""
echo -e "${YELLOW}Informe as credenciais do banco de dados (serão protegidas):${NC}"
read -sp "DB Password (padrão: Admin123!): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-"Admin123!"}
echo ""

read -p "DB Name (padrão: sprint3): " DB_NAME
DB_NAME=${DB_NAME:-"sprint3"}

read -p "DB User (padrão: root): " DB_USER
DB_USER=${DB_USER:-"root"}

# Configurar Azure DevOps
echo ""
echo -e "${GREEN}Configurando Azure DevOps...${NC}"

# Fazer login no Azure DevOps (se necessário)
echo "Verificando autenticação no Azure DevOps..."
az devops configure --defaults organization="${ORG_URL}" project="${PROJECT_NAME}" 2>/dev/null || true

# Criar projeto (se não existir)
echo "Verificando/criando projeto..."
PROJECT_EXISTS=$(az devops project show --project "${PROJECT_NAME}" --query name -o tsv 2>/dev/null || echo "")

if [ -z "$PROJECT_EXISTS" ]; then
    echo "Criando projeto: ${PROJECT_NAME}"
    az devops project create \
        --name "${PROJECT_NAME}" \
        --description "${PROJECT_DESCRIPTION}" \
        --visibility private \
        --source-control git \
        --process scrum \
        --output none
    
    echo -e "${GREEN}✅ Projeto criado!${NC}"
else
    echo -e "${GREEN}✅ Projeto já existe.${NC}"
fi

# Criar/atualizar grupo de variáveis
echo ""
echo "Criando grupo de variáveis protegidas..."
VARIABLE_GROUP_NAME="Sprint4-Config"

# Verificar se grupo já existe
GROUP_EXISTS=$(az pipelines variable-group list --project "${PROJECT_NAME}" --query "[?name=='${VARIABLE_GROUP_NAME}'].name" -o tsv 2>/dev/null || echo "")

if [ -z "$GROUP_EXISTS" ]; then
    echo "Criando grupo de variáveis: ${VARIABLE_GROUP_NAME}"
    az pipelines variable-group create \
        --name "${VARIABLE_GROUP_NAME}" \
        --project "${PROJECT_NAME}" \
        --variables \
            RESOURCE_GROUP="${RESOURCE_GROUP}" \
            ACR_NAME="${ACR_NAME}" \
            ACI_DB_NAME="${ACI_DB_NAME}" \
            ACI_APP_NAME="${ACI_APP_NAME}" \
            DNS_NAME_LABEL="${DNS_NAME_LABEL}" \
            DB_NAME="${DB_NAME}" \
            DB_USER="${DB_USER}" \
        --output none
    
    echo -e "${GREEN}✅ Grupo de variáveis criado!${NC}"
else
    echo "Atualizando grupo de variáveis existente..."
    az pipelines variable-group variable update \
        --group-id "$(az pipelines variable-group list --project "${PROJECT_NAME}" --query "[?name=='${VARIABLE_GROUP_NAME}'].id" -o tsv)" \
        --name RESOURCE_GROUP \
        --value "${RESOURCE_GROUP}" \
        --project "${PROJECT_NAME}" \
        --output none || true
    
    echo -e "${GREEN}✅ Grupo de variáveis atualizado!${NC}"
fi

# Adicionar variável protegida (senha)
GROUP_ID=$(az pipelines variable-group list --project "${PROJECT_NAME}" --query "[?name=='${VARIABLE_GROUP_NAME}'].id" -o tsv)
echo "Adicionando variável protegida DB_PASSWORD..."
az pipelines variable-group variable create \
    --group-id "$GROUP_ID" \
    --name DB_PASSWORD \
    --value "${DB_PASSWORD}" \
    --secret true \
    --project "${PROJECT_NAME}" \
    --output none 2>/dev/null || \
az pipelines variable-group variable update \
    --group-id "$GROUP_ID" \
    --name DB_PASSWORD \
    --value "${DB_PASSWORD}" \
    --secret true \
    --project "${PROJECT_NAME}" \
    --output none

echo -e "${GREEN}✅ Variável protegida DB_PASSWORD configurada!${NC}"

# Criar Service Connection para Azure Subscription
echo ""
echo "Criando Service Connection para Azure Subscription..."
SERVICE_CONNECTION_AZURE="Azure-ServiceConnection"

# Verificar se já existe
SC_AZURE_EXISTS=$(az devops service-endpoint list --project "${PROJECT_NAME}" --query "[?name=='${SERVICE_CONNECTION_AZURE}'].name" -o tsv 2>/dev/null || echo "")

if [ -z "$SC_AZURE_EXISTS" ]; then
    echo "⚠️  Service Connection para Azure precisa ser criada manualmente:"
    echo ""
    echo "1. Acesse: ${ORG_URL}/${PROJECT_NAME}/_settings/adminservices"
    echo "2. Clique em 'New service connection'"
    echo "3. Selecione 'Azure Resource Manager'"
    echo "4. Escolha 'Workload Identity federation (automatic)' ou 'Service Principal (automatic)'"
    echo "5. Nome: ${SERVICE_CONNECTION_AZURE}"
    echo "6. Subscription: ${SUBSCRIPTION_ID}"
    echo "7. Resource Group: ${RESOURCE_GROUP}"
    echo ""
    read -p "Pressione ENTER após criar a Service Connection..."
else
    echo -e "${GREEN}✅ Service Connection Azure já existe.${NC}"
fi

# Criar Service Connection para ACR
echo ""
echo "Criando Service Connection para ACR..."
SERVICE_CONNECTION_ACR="ACR-ServiceConnection"

SC_ACR_EXISTS=$(az devops service-endpoint list --project "${PROJECT_NAME}" --query "[?name=='${SERVICE_CONNECTION_ACR}'].name" -o tsv 2>/dev/null || echo "")

if [ -z "$SC_ACR_EXISTS" ]; then
    echo "⚠️  Service Connection para ACR precisa ser criada manualmente:"
    echo ""
    echo "1. Acesse: ${ORG_URL}/${PROJECT_NAME}/_settings/adminservices"
    echo "2. Clique em 'New service connection'"
    echo "3. Selecione 'Docker Registry'"
    echo "4. Registry Type: 'Azure Container Registry'"
    echo "5. Nome: ${SERVICE_CONNECTION_ACR}"
    echo "6. Subscription: ${SUBSCRIPTION_ID}"
    echo "7. Azure Container Registry: ${ACR_NAME}"
    echo ""
    read -p "Pressione ENTER após criar a Service Connection..."
else
    echo -e "${GREEN}✅ Service Connection ACR já existe.${NC}"
fi

# Conectar repositório GitHub (se necessário)
echo ""
echo "Para conectar o repositório GitHub:"
echo "1. Acesse: ${ORG_URL}/${PROJECT_NAME}/_git/${PROJECT_NAME}/_settings/repositories"
echo "2. Clique em 'Add repository'"
echo "3. Selecione 'GitHub'"
echo "4. Autorize e selecione seu repositório"
echo ""
read -p "Pressione ENTER após conectar o repositório..."

# Criar pipeline (se necessário)
echo ""
echo "Para criar o pipeline:"
echo "1. Acesse: ${ORG_URL}/${PROJECT_NAME}/_build"
echo "2. Clique em 'New pipeline'"
echo "3. Selecione seu repositório GitHub"
echo "4. Escolha 'Existing Azure Pipelines YAML file'"
echo "5. Selecione o branch master e o arquivo: azure-pipelines.yml"
echo "6. Execute o pipeline"
echo ""

# Resumo
echo ""
echo -e "${GREEN}=========================================="
echo "✅ Configuração concluída!"
echo "==========================================${NC}"
echo ""
echo "Resumo da configuração:"
echo "  Projeto: ${PROJECT_NAME}"
echo "  Resource Group: ${RESOURCE_GROUP}"
echo "  ACR: ${ACR_NAME}"
echo "  ACI DB: ${ACI_DB_NAME}"
echo "  ACI App: ${ACI_APP_NAME}"
echo ""
echo "Próximos passos:"
echo "  1. Criar Service Connections (se ainda não criou)"
echo "  2. Conectar repositório GitHub"
echo "  3. Criar pipeline YAML"
echo "  4. Fazer push para branch master para acionar CI"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE: Convide o professor para o projeto com nível 'Basic'!${NC}"
echo "  Acesse: ${ORG_URL}/${PROJECT_NAME}/_settings/teams"
echo ""

