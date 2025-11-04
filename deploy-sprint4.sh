#!/bin/bash

# O script cria todos os recursos necessários: Resource Group, ACR, MySQL e ACI

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║               Sprint 4 FIAP - Deploy Azure               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Configurações
RM="558253"
RESOURCE_GROUP="rg-sprint4-rm${RM}"
LOCATION="westeurope"  
ACR_NAME="acrsprint4rm${RM}"
MYSQL_SERVER="mysql-sprint4-rm${RM}"
MYSQL_DB="sprint4"
MYSQL_USER="adminuser"
ACI_NAME="aci-sprint4-rm${RM}"
IMAGE_NAME="sprint4-app"
DNS_LABEL="sprint4-rm${RM}"

# Gerar senha MySQL
MYSQL_PASSWORD="Sprint4@RM${RM}Fiap"

echo -e "${YELLOW}📋 Configurações:${NC}"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  ACR: $ACR_NAME"
echo "  MySQL Server: $MYSQL_SERVER"
echo "  Database: $MYSQL_DB"
echo "  ACI: $ACI_NAME"
echo ""

# Verificar se está logado no Azure
echo -e "${BLUE}🔐 Verificando login no Azure...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Você não está logado. Faça login:${NC}"
    az login
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo -e "${GREEN}✅ Logado na subscription: $SUBSCRIPTION_ID${NC}"
echo ""

# 1. Criar Resource Group
echo -e "${BLUE}📦 [1/6] Criando Resource Group...${NC}"
if az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo -e "${YELLOW}⚠️  Resource Group já existe${NC}"
else
    az group create --name $RESOURCE_GROUP --location $LOCATION
    echo -e "${GREEN}✅ Resource Group criado${NC}"
fi
echo ""

# 2. Criar Azure Container Registry
echo -e "${BLUE}🐳 [2/6] Criando Azure Container Registry...${NC}"
if az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo -e "${YELLOW}⚠️  ACR já existe${NC}"
else
    az acr create \
        --resource-group $RESOURCE_GROUP \
        --name $ACR_NAME \
        --sku Basic \
        --admin-enabled true
    echo -e "${GREEN}✅ ACR criado${NC}"
fi
echo ""

# Definir variáveis do ACR
ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"

# 3. Importar MySQL para ACR e Criar Container
echo -e "${BLUE}🗄️  [3/6] Importando MySQL para ACR...${NC}"
MYSQL_CONTAINER_NAME="mysql-sprint4-rm${RM}"

# Usar a imagem oficial do MySQL do Microsoft Container Registry (MCR)
MYSQL_IMAGE="mcr.microsoft.com/mysql/mysql-server:8.0"

echo "⬇️  Importando imagem MySQL do Microsoft Container Registry..."
if az acr import \
    --name $ACR_NAME \
    --source $MYSQL_IMAGE \
    --image mysql:8.0 \
    --resource-group $RESOURCE_GROUP; then
    echo -e "${GREEN}✅ Imagem MySQL importada para ACR${NC}"
    MYSQL_IMAGE="$ACR_LOGIN_SERVER/mysql:8.0"
else
    echo -e "${YELLOW}⚠️  Usando imagem MySQL diretamente do MCR${NC}"
    MYSQL_IMAGE="mcr.microsoft.com/mysql/mysql-server:8.0"
fi

# Deletar container MySQL existente se houver
echo -e "${BLUE}📦 Criando MySQL Container...${NC}"
az container delete \
    --resource-group $RESOURCE_GROUP \
    --name $MYSQL_CONTAINER_NAME \
    --yes 2>/dev/null || true

# Obter credenciais do ACR
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

# Criar container MySQL
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $MYSQL_CONTAINER_NAME \
    --image $MYSQL_IMAGE \
    --os-type Linux \
    --dns-name-label mysql-sprint4-rm${RM} \
    --ports 3306 \
    --cpu 1 \
    --memory 2 \
    --environment-variables \
        MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD \
        MYSQL_DATABASE=$MYSQL_DB \
        MYSQL_ROOT_HOST='%' \
    --location $LOCATION

MYSQL_HOST=$(az container show \
    --resource-group $RESOURCE_GROUP \
    --name $MYSQL_CONTAINER_NAME \
    --query "ipAddress.fqdn" -o tsv)

echo -e "${GREEN}✅ MySQL Container criado${NC}"
echo -e "${YELLOW}   Host: $MYSQL_HOST${NC}"
echo ""

# 4. Build e Push da imagem Docker
echo -e "${BLUE}🏗️  [4/6] Build da imagem Docker...${NC}"

# Login no ACR
az acr login --name $ACR_NAME
echo -e "${GREEN}✅ Login no ACR realizado${NC}"

# Build da imagem
docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:latest .
echo -e "${GREEN}✅ Imagem construída${NC}"

# Push da imagem
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:latest
echo -e "${GREEN}✅ Imagem enviada para ACR${NC}"
echo ""

# 5. Executar script SQL no MySQL
echo -e "${BLUE}💾 [5/6] Executando script SQL...${NC}"

echo "Aguardando MySQL estar pronto (60 segundos)..."
sleep 60

# Executar script SQL via docker
docker run --rm -i mysql:8.0 mysql \
    -h $MYSQL_HOST \
    -u root \
    -p"$MYSQL_PASSWORD" \
    < script_bd.sql 2>/dev/null && {
    echo -e "${GREEN}✅ Script SQL executado${NC}"
} || {
    echo -e "${YELLOW}⚠️  Aguarde mais 30 segundos para o MySQL iniciar...${NC}"
    sleep 30
    docker run --rm -i mysql:8.0 mysql \
        -h $MYSQL_HOST \
        -u root \
        -p"$MYSQL_PASSWORD" \
        < script_bd.sql && echo -e "${GREEN}✅ Script SQL executado${NC}" || {
        echo -e "${YELLOW}⚠️  Execute manualmente depois:${NC}"
        echo "   docker run --rm -i mysql:8.0 mysql -h $MYSQL_HOST -u root -p'$MYSQL_PASSWORD' < script_bd.sql"
    }
}
echo ""

# 6. Deploy no Azure Container Instance
echo -e "${BLUE}🚀 [6/6] Deploy no Azure Container Instance...${NC}"

# Obter credenciais do ACR
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

# Deletar container existente se houver
az container delete \
    --resource-group $RESOURCE_GROUP \
    --name $ACI_NAME \
    --yes 2>/dev/null || true

# Criar container
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $ACI_NAME \
    --image $ACR_LOGIN_SERVER/$IMAGE_NAME:latest \
    --os-type Linux \
    --registry-login-server $ACR_LOGIN_SERVER \
    --registry-username $ACR_USERNAME \
    --registry-password $ACR_PASSWORD \
    --dns-name-label $DNS_LABEL \
    --ports 8080 \
    --cpu 1 \
    --memory 2 \
    --environment-variables \
        DB_HOST=$MYSQL_HOST \
        DB_PORT=3306 \
        DB_NAME=$MYSQL_DB \
        DB_USER=root \
        DB_PASSWORD=$MYSQL_PASSWORD \
    --restart-policy Always \
    --location $LOCATION

echo -e "${GREEN}✅ Container criado${NC}"
echo ""

# Informações finais
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🎉 DEPLOY CONCLUÍDO COM SUCESSO!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 INFORMAÇÕES DO DEPLOY:${NC}"
echo ""
echo -e "${YELLOW}🌐 URL da Aplicação:${NC}"
FQDN=$(az container show --resource-group $RESOURCE_GROUP --name $ACI_NAME --query "ipAddress.fqdn" -o tsv)
echo "   http://${FQDN}:8080"
echo ""
echo -e "${YELLOW}🔐 Credenciais MySQL:${NC}"
echo "   Host: $MYSQL_HOST"
echo "   Database: $MYSQL_DB"
echo "   User: $MYSQL_USER"
echo "   Password: $MYSQL_PASSWORD"
echo ""
echo -e "${YELLOW}🐳 Container Registry:${NC}"
echo "   Server: $ACR_LOGIN_SERVER"
echo "   Image: $IMAGE_NAME:latest"
echo ""
echo -e "${YELLOW}📊 Status do Container:${NC}"
az container show \
    --resource-group $RESOURCE_GROUP \
    --name $ACI_NAME \
    --query "{Status:instanceView.state, FQDN:ipAddress.fqdn, IP:ipAddress.ip}" \
    -o table
echo ""
echo -e "${BLUE}💡 COMANDOS ÚTEIS:${NC}"
echo "   Ver logs: az container logs -g $RESOURCE_GROUP -n $ACI_NAME"
echo "   Ver status: az container show -g $RESOURCE_GROUP -n $ACI_NAME"
echo "   Deletar tudo: ./delete-sprint4.sh"
echo ""
echo -e "${YELLOW}💾 Credenciais salvas em: .mysql-credentials${NC}"
echo "DB_HOST=$MYSQL_HOST" > .mysql-credentials
echo "DB_USER=$MYSQL_USER" >> .mysql-credentials
echo "DB_PASSWORD=$MYSQL_PASSWORD" >> .mysql-credentials
echo "DB_NAME=$MYSQL_DB" >> .mysql-credentials
echo ""
echo -e "${GREEN}✨ Deploy finalizado! Acesse a aplicação pela URL acima.${NC}"
