#!/bin/bash

# Carrega variáveis do .env 
if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

if [ -z "${RM:-}" ]; then
  echo "❌ Variável RM não definida. Crie um .env com RM=seu_rm"; exit 1
fi
RESOURCE_GROUP="rg-sprint3-rm${RM}"
ACR_NAME="acrsprint3rm${RM}"
IMAGE_NAME="sprint3-app"
TAG="latest"

set -euo pipefail

echo "=== Build e Push para o Azure Container Registry ==="

if ! az account show &> /dev/null; then
  echo "❌ Não está logado no Azure. Execute: az login"
  exit 1
fi

echo "Criando Resource Group..."
az group create --name "$RESOURCE_GROUP" --location "eastus" --output table

echo "Criando/atualizando ACR..."
az acr create --resource-group "$RESOURCE_GROUP" --name "$ACR_NAME" --sku Basic --output table || true
az acr update --name "$ACR_NAME" --admin-enabled true

echo "Login no ACR..."
az acr login --name "$ACR_NAME"

echo "Build da imagem..."
docker build -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG .

echo "Push da imagem..."
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG

echo "Importando MySQL 8.0 no ACR..."
az acr import --name "$ACR_NAME" --source docker.io/library/mysql:8.0 --image mysql:8.0 --force

echo "✅ Concluído. Próximo passo: ./deploy.sh"


