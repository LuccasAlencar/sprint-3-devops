#!/bin/bash

# Script para verificar o status dos containers ACI e obter informações de acesso

set -euo pipefail

# Carrega variáveis do .env
if [ -f .env ]; then
    set -a
    . ./.env
    set +a
fi

if [ -z "${RM:-}" ]; then
    echo "❌ Variável RM não definida. Crie um .env com RM=seu_rm"
    exit 1
fi

RESOURCE_GROUP="rg-sprint3-rm${RM}"
ACI_DB_NAME="aci-db-sprint3-rm${RM}"
ACI_APP_NAME="aci-app-sprint3-rm${RM}"

echo "=== Status dos Containers ACI ==="

if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute: az login"
    exit 1
fi

# Verificar MySQL
echo ""
echo "📊 MySQL Container (${ACI_DB_NAME}):"
DB_STATUS=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_DB_NAME" --query "containers[0].instanceView.currentState.state" -o tsv 2>/dev/null || echo "Not Found")
DB_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_DB_NAME" --query "ipAddress.ip" -o tsv 2>/dev/null || echo "N/A")

if [ "$DB_STATUS" == "Not Found" ]; then
    echo "  Status: ❌ Container não encontrado"
else
    echo "  Status: $DB_STATUS"
    echo "  IP: $DB_IP"
fi

# Verificar Aplicação
echo ""
echo "📊 Aplicação Container (${ACI_APP_NAME}):"
APP_STATUS=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_APP_NAME" --query "containers[0].instanceView.currentState.state" -o tsv 2>/dev/null || echo "Not Found")
APP_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_APP_NAME" --query "ipAddress.ip" -o tsv 2>/dev/null || echo "N/A")
APP_FQDN=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_APP_NAME" --query "ipAddress.fqdn" -o tsv 2>/dev/null || echo "N/A")

if [ "$APP_STATUS" == "Not Found" ]; then
    echo "  Status: ❌ Container não encontrado"
else
    echo "  Status: $APP_STATUS"
    echo "  IP: $APP_IP"
    echo "  FQDN: $APP_FQDN"
    echo ""
    echo "🌐 Acesso à aplicação:"
    echo "  URL: http://${APP_FQDN}:8080"
    echo "  IP Direto: http://${APP_IP}:8080"
fi

# Logs (últimas 10 linhas)
echo ""
echo "📋 Logs da Aplicação (últimas 10 linhas):"
az container logs --resource-group "$RESOURCE_GROUP" --name "$ACI_APP_NAME" --tail 10 2>/dev/null || echo "  Não foi possível obter logs"

echo ""
echo "✅ Verificação concluída!"

