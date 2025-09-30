#!/bin/bash
RM="558253"
RESOURCE_GROUP="rg-cp4-rm${RM}"
ACR_NAME="acrcp4rm${RM}"
IMAGE_NAME="appcp4"
TAG="latest"
ACI_DB_NAME="aci-db-cp4-rm${RM}"
ACI_APP_NAME="aci-app-cp4-rm${RM}"

# Configurações do banco
DB_ROOT_PASSWORD="Admin123!"
DB_NAME="importacoesdb"
DB_USER="root"

set -euo pipefail

# Verificar se está logado no Azure
if ! az account show &> /dev/null; then
  echo "❌ Não está logado no Azure. Execute: az login"
  exit 1
fi

# Habilitar admin no ACR
echo "Habilitando admin no ACR e obtendo credenciais..."
az acr update --name $ACR_NAME --admin-enabled true
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

# Deploy do MySQL
echo "Fazendo deploy do MySQL (imagem do ACR)..."
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_DB_NAME \
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
  --registry-password $ACR_PASSWORD

if [ $? -eq 0 ]; then
  echo "✅ MySQL criado (ACI)."
else
  echo "❌ Falha ao criar MySQL no ACI. Saindo."
  exit 1
fi

# Aguardar container do banco obter IP
echo "Aguardando IP do container do banco..."
for i in {1..30}; do
  DB_IP=$(az container show --resource-group $RESOURCE_GROUP --name $ACI_DB_NAME --query ipAddress.ip -o tsv || echo "")
  if [[ -n "$DB_IP" && "$DB_IP" != "null" ]]; then
    echo "DB IP: $DB_IP"
    break
  fi
  echo "esperando... ($i)"
  sleep 5
done

if [ -z "$DB_IP" ] || [ "$DB_IP" = "null" ]; then
  echo "❌ Não foi possível obter o IP do banco. Verifique 'az container show' e os logs."
  exit 1
fi

# Deploy da aplicação
echo "Fazendo deploy da aplicação..."
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_APP_NAME \
  --image $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --ports 8080 \
  --dns-name-label "app-cp4-rm${RM}" \
  --environment-variables \
    DB_HOST=$DB_IP \
    DB_PORT=3306 \
    DB_NAME=$DB_NAME \
    DB_USER=$DB_USER \
    DB_PASSWORD=$DB_ROOT_PASSWORD \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD

if [ $? -eq 0 ]; then
  echo "✅ Aplicação deployada com sucesso!"
else
  echo "❌ Falha no deploy da aplicação!"
  exit 1
fi

# Informações de Acesso
APP_FQDN=$(az container show --resource-group $RESOURCE_GROUP --name $ACI_APP_NAME --query ipAddress.fqdn -o tsv)
APP_IP=$(az container show --resource-group $RESOURCE_GROUP --name $ACI_APP_NAME --query ipAddress.ip -o tsv)

echo ""
echo "=== INFORMAÇÕES DE ACESSO ==="
echo "Aplicação URL: http://${APP_FQDN}:8080"
echo "Aplicação IP: ${APP_IP}"
echo "Banco IP: ${DB_IP}"
echo ""
echo "✅ Deploy concluído com sucesso!"
