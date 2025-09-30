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
ACI_DB_NAME="aci-db-sprint3-rm${RM}"
ACI_APP_NAME="aci-app-sprint3-rm${RM}"

DB_ROOT_PASSWORD="${DB_PASSWORD:-Admin123!}"
DB_NAME="${DB_NAME:-sprint3}"
DB_USER="${DB_USER:-root}"

set -euo pipefail

if ! az account show &> /dev/null; then
  echo "❌ Não está logado no Azure. Execute: az login"
  exit 1
fi

echo "Habilitando admin e capturando credenciais do ACR..."
az acr update --name "$ACR_NAME" --admin-enabled true 1> /dev/null
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query passwords[0].value -o tsv)

echo "Criando container MySQL (ACI)..."
az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_DB_NAME" \
  --image $ACR_NAME.azurecr.io/mysql:8.0 \
  --os-type Linux \
  --cpu 1 \
  --memory 2 \
  --ports 3306 \
  --ip-address Public \
  --environment-variables \
    MYSQL_ROOT_PASSWORD=$DB_ROOT_PASSWORD \
    MYSQL_DATABASE=$DB_NAME \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD 1> /dev/null || true

echo "Aguardando IP do MySQL..."
for i in {1..40}; do
  DB_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_DB_NAME" --query ipAddress.ip -o tsv || echo "")
  if [[ -n "$DB_IP" && "$DB_IP" != "null" ]]; then
    echo "DB IP: $DB_IP"; break
  fi
  sleep 5
done
if [[ -z "${DB_IP:-}" || "$DB_IP" == "null" ]]; then
  echo "❌ Não foi possível obter IP do banco."; exit 1
fi

echo "Criando container da aplicação (ACI)..."
az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_APP_NAME" \
  --image $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --ports 8080 \
  --dns-name-label "sprint3-rm${RM}" \
  --environment-variables \
    DB_HOST=$DB_IP \
    DB_PORT=3306 \
    DB_NAME=$DB_NAME \
    DB_USER=$DB_USER \
    DB_PASSWORD=$DB_ROOT_PASSWORD \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD 1> /dev/null || true

APP_FQDN=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_APP_NAME" --query ipAddress.fqdn -o tsv)
APP_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_APP_NAME" --query ipAddress.ip -o tsv)

echo ""
echo "=== Acesso ==="
echo "URL: http://${APP_FQDN}:8080"
echo "APP IP: ${APP_IP}"
echo "DB IP: ${DB_IP}"


