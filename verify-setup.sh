#!/bin/bash

# Script para verificar se tudo está configurado corretamente para Sprint 4

set -euo pipefail

echo "=== Verificação de Configuração Sprint 4 ==="
echo ""

ERRORS=0

# Verificar arquivos necessários
echo "📁 Verificando arquivos necessários..."

REQUIRED_FILES=(
    "azure-pipelines.yml"
    "setup-azure-devops.sh"
    "populate-db.sh"
    "check-status.sh"
    "Dockerfile"
    "pom.xml"
    "script_bd.sql"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (NÃO ENCONTRADO)"
        ((ERRORS++))
    fi
done

echo ""

# Verificar .env
echo "🔐 Verificando configuração .env..."
if [ -f .env ]; then
    echo "  ✅ Arquivo .env existe"
    if grep -q "RM=" .env; then
        RM_VALUE=$(grep "RM=" .env | cut -d'=' -f2 | tr -d ' ')
        if [ -n "$RM_VALUE" ]; then
            echo "  ✅ RM configurado: $RM_VALUE"
        else
            echo "  ❌ RM está vazio no .env"
            ((ERRORS++))
        fi
    else
        echo "  ❌ RM não encontrado no .env"
        ((ERRORS++))
    fi
else
    echo "  ⚠️  Arquivo .env não encontrado (crie um com RM=seu_rm)"
    ((ERRORS++))
fi

echo ""

# Verificar Azure CLI
echo "☁️  Verificando Azure CLI..."
if command -v az &> /dev/null; then
    echo "  ✅ Azure CLI instalado"
    if az account show &> /dev/null; then
        SUBSCRIPTION=$(az account show --query name -o tsv)
        echo "  ✅ Logado no Azure: $SUBSCRIPTION"
    else
        echo "  ❌ Não está logado. Execute: az login"
        ((ERRORS++))
    fi
else
    echo "  ❌ Azure CLI não instalado"
    ((ERRORS++))
fi

echo ""

# Verificar Azure DevOps CLI
echo "🔧 Verificando Azure DevOps CLI..."
if command -v az &> /dev/null && az extension list --query "[?name=='azure-devops'].name" -o tsv 2>/dev/null | grep -q "azure-devops"; then
    echo "  ✅ Azure DevOps CLI extension instalada"
else
    echo "  ⚠️  Azure DevOps CLI extension não instalada"
    echo "     Execute: az extension add --name azure-devops"
fi

echo ""

# Verificar Docker (opcional)
echo "🐳 Verificando Docker..."
if command -v docker &> /dev/null; then
    echo "  ✅ Docker instalado"
    if docker ps &> /dev/null; then
        echo "  ✅ Docker rodando"
    else
        echo "  ⚠️  Docker não está rodando (necessário apenas para testes locais)"
    fi
else
    echo "  ⚠️  Docker não instalado (opcional, mas recomendado para testes)"
fi

echo ""

# Verificar permissões de execução
echo "🔑 Verificando permissões de execução..."
SCRIPTS=("setup-azure-devops.sh" "populate-db.sh" "check-status.sh" "build.sh" "deploy.sh" "delete.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "  ✅ $script (executável)"
        else
            echo "  ⚠️  $script (sem permissão de execução)"
            echo "     Execute: chmod +x $script"
        fi
    fi
done

echo ""

# Resumo
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo "✅ Tudo configurado corretamente!"
    echo ""
    echo "Próximos passos:"
    echo "  1. Execute: ./setup-azure-devops.sh"
    echo "  2. Configure Service Connections no Azure DevOps"
    echo "  3. Conecte o repositório GitHub"
    echo "  4. Crie o pipeline usando azure-pipelines.yml"
    echo "  5. Faça push para branch master para acionar CI"
else
    echo "❌ Encontrados $ERRORS problema(s)"
    echo ""
    echo "Corrija os problemas acima antes de continuar."
fi
echo "=========================================="

