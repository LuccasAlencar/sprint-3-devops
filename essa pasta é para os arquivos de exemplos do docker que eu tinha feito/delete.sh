#!/bin/bash

RM="558253"
RESOURCE_GROUP="rg-cp4-rm${RM}"

set -euo pipefail

echo "=== Limpeza dos Recursos Azure ==="
echo "Resource Group: ${RESOURCE_GROUP}"

if ! az account show &> /dev/null; then
  echo "❌ Não está logado no Azure. Execute: az login"
  exit 1
fi

az resource list --resource-group $RESOURCE_GROUP --output table

read -p "Tem certeza que deseja excluir o resource group e tudo que há dentro? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
  echo "Operação cancelada pelo usuário."
  exit 1
fi

az group delete --name $RESOURCE_GROUP --yes --no-wait

echo "Comando de exclusão enviado. Use 'az group show --name $RESOURCE_GROUP' para checar o status."
