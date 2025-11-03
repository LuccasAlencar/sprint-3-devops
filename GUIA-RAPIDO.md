# 🚀 GUIA RÁPIDO - Sprint 4 (RM558253)

## ⚡ Deploy em 3 Passos

### 1️⃣ Login no Azure
```bash
az login
```

### 2️⃣ Executar Deploy
```bash
chmod +x deploy-sprint4.sh
./deploy-sprint4.sh
```

### 3️⃣ Acessar Aplicação
Após 5-10 minutos:
```
http://sprint4-rm558253.eastus.azurecontainer.io:8080
```

**Login:** admin / password

---

## 🗑️ Deletar Tudo
```bash
chmod +x delete-sprint4.sh
./delete-sprint4.sh
```

---

## 📋 Checklist Azure DevOps

### Configuração Inicial
- [ ] Criar projeto no [Azure DevOps](https://dev.azure.com)
  - Nome: **Sprint 4 - Azure DevOps**
  - Private, Git, Scrum
- [ ] Fazer push do código para Azure Repos ou GitHub
- [ ] Executar `deploy-sprint4.sh` para criar recursos

### Service Connections
- [ ] **Azure Resource Manager**
  - Nome: `azure-service-connection`
  - Resource Group: `rg-sprint4-rm558253`
- [ ] **Azure Container Registry**
  - Nome: `azure-container-registry`
  - ACR: `acrsprint4rm558253`

### Pipeline
- [ ] Criar pipeline a partir de `azure-pipelines.yml`
- [ ] Ajustar variáveis se necessário
- [ ] Executar pipeline
- [ ] Verificar 3 stages: Build → Image → Deploy

### Convite Professor
- [ ] Project Settings → Teams → Add member
- [ ] Role: Contributor

---

## 📊 Recursos Criados

| Recurso | Nome | Descrição |
|---------|------|-----------|
| Resource Group | rg-sprint4-rm558253 | Grupo de recursos |
| ACR | acrsprint4rm558253 | Registry de imagens |
| MySQL | mysql-sprint4-rm558253 | Banco de dados |
| Key Vault | kv-sprint4-rm558253 | Credenciais |
| ACI | aci-sprint4-rm558253 | Container da app |

---

## 🔧 Comandos Úteis

### Ver logs
```bash
az container logs -g rg-sprint4-rm558253 -n aci-sprint4-rm558253 --tail 100
```

### Status do container
```bash
az container show -g rg-sprint4-rm558253 -n aci-sprint4-rm558253 \
  --query "{Status:instanceView.state, IP:ipAddress.ip}" -o table
```

### Restart do container
```bash
az container restart -g rg-sprint4-rm558253 -n aci-sprint4-rm558253
```

### Listar todos recursos
```bash
az resource list -g rg-sprint4-rm558253 -o table
```

---

## ✅ Entrega

### Itens Necessários
1. ✅ PDF com links (GitHub, Azure DevOps, YouTube)
2. ✅ Diagramas (Arquitetura + CI/CD)
3. ✅ Descrição da stack
4. ✅ Pipeline funcionando
5. ✅ Banco de dados válido
6. ✅ Professor convidado no Azure DevOps

### Pontuação
- Descrição: 5 pts
- Diagrama: 10 pts
- Detalhamento: 10 pts
- **Pipeline CI/CD: 30 pts** ⭐
- Banco dados: Obrigatório
- Azure DevOps config: Obrigatório
- Convite professor: Obrigatório

**Total: 55 pontos + obrigatórios**

---

## 🎯 Troubleshooting

### Container não inicia?
```bash
# Ver logs completos
az container logs -g rg-sprint4-rm558253 -n aci-sprint4-rm558253

# Verificar eventos
az container show -g rg-sprint4-rm558253 -n aci-sprint4-rm558253 \
  --query "instanceView.events" -o table
```

### MySQL não conecta?
```bash
# Testar conectividade
mysql -h mysql-sprint4-rm558253.mysql.database.azure.com -u adminuser -p
```

### Pipeline falha?
1. Verificar service connections configuradas
2. Verificar variáveis no `azure-pipelines.yml`
3. Verificar logs do pipeline no Azure DevOps

---

**Qualquer dúvida, consulte o README.md completo!**
