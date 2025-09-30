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

set -euo pipefail

echo "=== Limpeza dos recursos do Resource Group ==="

if ! az account show &> /dev/null; then
  echo "❌ Não está logado no Azure. Execute: az login"
  exit 1
fi

az resource list --resource-group "$RESOURCE_GROUP" --output table | cat

read -p "Tem certeza que deseja EXCLUIR o resource group inteiro? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
  echo "Operação cancelada."
  exit 1
fi

az group delete --name "$RESOURCE_GROUP" --yes --no-wait
echo "Comando enviado. Use 'az group show --name $RESOURCE_GROUP' para ver o status."


