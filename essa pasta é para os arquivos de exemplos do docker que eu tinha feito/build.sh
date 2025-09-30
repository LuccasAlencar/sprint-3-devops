#!/bin/bash
RM="558253"
RESOURCE_GROUP="rg-cp4-rm${RM}"
ACR_NAME="acrcp4rm${RM}"
IMAGE_NAME="appcp4"
TAG="latest"

set -euo pipefail

echo "=== Build e Push da Aplicação para Azure Container Registry ==="
echo "RM: ${RM}"
echo "Resource Group: ${RESOURCE_GROUP}"
echo "ACR Name: ${ACR_NAME}"

# Verificar se está logado no azure
if ! az account show &> /dev/null; then
  echo "❌ Não está logado no Azure. Execute: az login"
  exit 1
fi

# Criar Resource Group
echo "Criando Resource Group..."
az group create --name $RESOURCE_GROUP --location "eastus" --output table

# Criar ACR
echo "Criando Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --output table || true

# Habilitar admin no ACR
echo "Habilitando admin no ACR..."
az acr update --name $ACR_NAME --admin-enabled true

# Fazer login no acr
echo "Fazendo login no ACR..."
az acr login --name $ACR_NAME

# Build da imagem docker
echo "Fazendo build da imagem Docker..."
docker build -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG .

# Push da imagem para o acr
echo "Enviando imagem para o ACR..."
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG

# Importar imagem do MySQL do Docker Hub para o ACR
echo "Importando imagem do MySQL para o ACR..."
az acr import --name $ACR_NAME --source docker.io/library/mysql:8.0 --image mysql:8.0 --force

echo "✅ Build, import e push concluídos com sucesso!"
echo "Imagem disponível em: $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG"

echo "Pronto. Agora rode ./deploy.sh para criar os containers no ACI."
