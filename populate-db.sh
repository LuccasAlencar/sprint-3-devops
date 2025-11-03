#!/bin/bash

# Script para popular o banco de dados após o deploy no ACI
# Este script executa o script_bd.sql no MySQL container

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
DB_PASSWORD="${DB_PASSWORD:-Admin123!}"
DB_NAME="${DB_NAME:-sprint3}"

echo "=== Popular Banco de Dados no ACI ==="

if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute: az login"
    exit 1
fi

# Obter IP do MySQL
echo "Obtendo IP do MySQL..."
DB_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_DB_NAME" --query ipAddress.ip -o tsv)

if [[ -z "$DB_IP" || "$DB_IP" == "null" ]]; then
    echo "❌ Não foi possível obter IP do banco."
    exit 1
fi

echo "DB IP: $DB_IP"

# Verificar se o script existe
if [ ! -f "script_bd.sql" ]; then
    echo "❌ Arquivo script_bd.sql não encontrado!"
    exit 1
fi

# Popular banco usando docker local (se disponível)
if command -v docker &> /dev/null; then
    echo "Populando banco usando Docker local..."
    docker run --rm -i \
        -e MYSQL_PWD="$DB_PASSWORD" \
        mysql:8.0 \
        mysql -h "$DB_IP" -u root -p"$DB_PASSWORD" "$DB_NAME" < script_bd.sql
    
    if [ $? -eq 0 ]; then
        echo "✅ Banco populado com sucesso!"
        
        # Verificar tabelas
        echo ""
        echo "Verificando tabelas criadas..."
        docker run --rm \
            -e MYSQL_PWD="$DB_PASSWORD" \
            mysql:8.0 \
            mysql -h "$DB_IP" -u root -p"$DB_PASSWORD" -e "USE $DB_NAME; SHOW TABLES;"
        
        exit 0
    fi
fi

# Alternativa: usar Azure Container Instance temporária
echo "Usando Azure Container Instance para popular banco..."
az container create \
    --resource-group "$RESOURCE_GROUP" \
    --name "mysql-populate-$(date +%s)" \
    --image mysql:8.0 \
    --restart-policy Never \
    --command-line "mysql -h $DB_IP -u root -p$DB_PASSWORD $DB_NAME -e 'SELECT 1;'" \
    --output none || true

echo "⚠️  Para popular o banco, execute manualmente:"
echo "docker run --rm -i -e MYSQL_PWD=$DB_PASSWORD mysql:8.0 mysql -h $DB_IP -u root -p$DB_PASSWORD $DB_NAME < script_bd.sql"

