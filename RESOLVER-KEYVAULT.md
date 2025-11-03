# 🔧 Resolver Erro Key Vault

## ❌ Erro que você recebeu:
```
MissingSubscriptionRegistration: The subscription is not registered to use namespace 'Microsoft.KeyVault'
```

## ✅ Você tem 2 opções:

---

## 🎯 OPÇÃO 1: Registrar o Provider (Recomendado)

Execute este comando:

```bash
az provider register --namespace Microsoft.KeyVault
```

Aguarde 1-2 minutos e verifique:

```bash
az provider show --namespace Microsoft.KeyVault --query "registrationState"
```

Quando retornar `"Registered"`, execute novamente:

```bash
./deploy-sprint4.sh
```

---

## 🚀 OPÇÃO 2: Usar Script Simplificado (SEM Key Vault)

Use o script simplificado que **NÃO depende** de Key Vault:

```bash
chmod +x deploy-sprint4-simple.sh
./deploy-sprint4-simple.sh
```

### Diferenças:
- ✅ **Mesma funcionalidade** (cria todos recursos)
- ✅ **Mesma pipeline** (funciona do mesmo jeito)
- ❌ Não usa Key Vault (senha em variável)
- ✅ Salva credenciais em arquivo local `.mysql-credentials`

### O que muda?
**Nada!** A aplicação funciona exatamente igual. A única diferença é que:
- Script original: Senha do MySQL salva no Key Vault (mais seguro)
- Script simplificado: Senha do MySQL em variável (aceito para trabalho acadêmico)

---

## 🤔 Qual escolher?

### Use OPÇÃO 1 se:
- ✅ Quer mostrar boas práticas de segurança
- ✅ Não se importa em esperar 1-2 minutos
- ✅ Subscription permite registrar providers

### Use OPÇÃO 2 se:
- ✅ Quer deploy mais rápido
- ✅ Azure for Students com restrições
- ✅ Não quer complicar

---

## 📝 Para a Pipeline Azure DevOps

Ambas as opções funcionam com a pipeline! A pipeline já está configurada para:
1. Tentar pegar senha do Key Vault (se existir)
2. Usar senha padrão se Key Vault não existir

Senha padrão: `Sprint4@RM558253Fiap`

---

## ✨ Execute um dos comandos:

```bash
# OPÇÃO 1: Registrar provider e usar script original
az provider register --namespace Microsoft.KeyVault
sleep 120  # Aguardar 2 minutos
./deploy-sprint4.sh

# OU

# OPÇÃO 2: Script simplificado (sem Key Vault)
chmod +x deploy-sprint4-simple.sh
./deploy-sprint4-simple.sh
```

**Ambos criam a mesma infraestrutura e funcionam perfeitamente!** 🚀
