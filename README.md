# Sprint 4 FIAP - DevOps Tools & Cloud Computing

**RM556152 - Daniel da Silva Barros**
**RM558253 - Luccas de Alencar Rufino**
**5550063  - Raul Clauson**

Sistema de gerenciamento de motos desenvolvido com **Spring Boot**, **MySQL** na nuvem e **Azure DevOps** com pipeline CI/CD completo, deployado em **Azure Container Instance (ACI)**.

## 🚀 Tecnologias Utilizadas

- **Spring Boot 3.5.6** - Framework principal
- **Thymeleaf** - Template engine para frontend
- **Spring Security** - Autenticação e autorização
- **MySQL 8.0** - Banco de dados na nuvem
- **Bootstrap 5** - Framework CSS
- **Maven** - Gerenciamento de dependências
- **Docker** - Containerização
- **Azure Container Registry (ACR)** - Armazenamento de imagens Docker
- **Azure Container Instances (ACI)** - Hospedagem da aplicação
- **MySQL 8.0** - Banco de dados em container ACI
- **Azure DevOps** - Pipeline CI/CD com YAML

## 🗄️ Estrutura do Banco de Dados

### Tabelas Principais
- `usuario` - Usuários do sistema com roles
- `moto` - Registro das motos
- `patio` - Pátios de armazenamento
- `zona` - Zonas dentro dos pátios
- `status` - Status das motos
- `status_grupo` - Grupos de status

### Relacionamentos
- Moto → Zona (ManyToOne)
- Moto → Pátio (ManyToOne)
- Moto → Status (ManyToOne)
- Status → StatusGrupo (ManyToOne)

## 🔐 Usuários de Teste

| Usuário | Senha | Role | Permissões |
|---------|-------|------|------------|
| admin | password | ADMIN | Todas as operações (CRUD completo) |
| operador | password | OPERADOR | Movimentar motos e alterar status |
| user | password | USER | Apenas visualização |

## 📋 Arquitetura da Solução

### Componentes
```
┌──────────────────────────────────────────────────────────────┐
│                      Azure DevOps                            │
│  ┌────────────┐   ┌────────────┐   ┌─────────────────┐       │
│  │   BUILD    │ → │   IMAGE    │ → │     DEPLOY      │       │
│  │  + Tests   │   │ Docker ACR │   │   Azure ACI     │       │
│  └────────────┘   └────────────┘   └─────────────────┘       │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│                      Azure Cloud                             │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │ Container Reg  │  │ Container Inst.  │  │  MySQL ACI   │  │
│  │     (ACR)      │  │  App Container   │  │  MySQL 8.0   │  │
│  │                │  │  - App:8080      │  │   Server     │  │
│  └────────────────┘  └──────────────────┘  └──────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

## 🚀 Opção 1: Deploy via Script Automatizado (Recomendado)

### Pré-requisitos
- **Azure CLI** instalado ([Download](https://docs.microsoft.com/cli/azure/install-azure-cli))
- **Docker** instalado ([Download](https://www.docker.com/products/docker-desktop))
- **Git Bash** (no Windows) ou terminal bash
- Conta Azure ativa

### Passo a Passo

#### 1. Login no Azure
```bash
az login
```

#### 2. Deploy Completo (1 comando)
```bash
# Dar permissão de execução
chmod +x deploy-sprint4.sh delete-sprint4.sh

# Executar deploy (cria TUDO automaticamente)
./deploy-sprint4.sh
```

**O script cria automaticamente:**
- ✅ Resource Group
- ✅ Azure Container Registry (ACR)
- ✅ MySQL Container (ACI com MySQL 8.0 oficial)
- ✅ Build e push da imagem Docker
- ✅ Execução do script SQL
- ✅ Application Container (ACI)
- ✅ Salva credenciais em `.mysql-credentials`

#### 3. Acesso à Aplicação

Após o deploy (5-10 minutos), você verá:

```
🌐 URL da Aplicação: http://sprint4-rm558253.westeurope.azurecontainer.io:8080
```

Acesse com:
- **admin** / **password** (acesso completo)
- **operador** / **password** (operações)
- **user** / **password** (visualização)

#### 4. Limpeza dos Recursos

Para deletar TUDO:
```bash
./delete-sprint4.sh
```

## 🔄 Opção 2: Deploy via Azure DevOps Pipeline

### 1. Configurar Azure DevOps

#### A) Criar Projeto
1. Acesse [dev.azure.com](https://dev.azure.com)
2. Crie novo projeto: **Sprint 4 - Azure DevOps**
3. Visibilidade: **Private**
4. Version control: **Git**
5. Work item process: **Scrum**

#### B) Configurar Service Connections

**Azure Resource Manager:**
1. Project Settings → Service connections
2. New service connection → Azure Resource Manager
3. Service principal (automatic)
4. Subscription: Selecione sua subscription
5. Resource Group: `rg-sprint4-rm558253`
6. Service connection name: `azure-service-connection`
7. Grant access permission to all pipelines: ✅

**Azure Container Registry:**
1. New service connection → Docker Registry
2. Registry type: Azure Container Registry
3. Subscription: Selecione sua subscription
4. Azure container registry: Selecione o ACR criado
5. Service connection name: `azure-container-registry`
6. Grant access permission to all pipelines: ✅

#### C) Configurar Variáveis do Pipeline

No arquivo `azure-pipelines.yml`, ajuste:
```yaml
variables:
  ACR_NAME: 'acrsprint4rm558253' 
  resourceGroup: 'rg-sprint4-rm558253'
  mysqlServerName: 'mysql-sprint4-rm558253'
```

#### D) Criar Pipeline

1. Pipelines → New pipeline
2. Selecione: **Azure Repos Git** (ou GitHub se preferir)
3. Selecione o repositório
4. Configure your pipeline: **Existing Azure Pipelines YAML file**
5. Path: `/azure-pipelines.yml`
6. Run

### 2. Trigger do Pipeline

O pipeline executa automaticamente em:
- Push na branch `main` ou `master`
- Pull request para `main` ou `master`

### 3. Stages do Pipeline

#### Stage 1: Build
- Compila código Java com Maven
- Executa testes unitários
- Publica artefatos

#### Stage 2: Image
- Build da imagem Docker
- Push para Azure Container Registry
- Tag com BuildId + latest

#### Stage 3: Deploy
- Deploy no Azure Container Instance
- Configuração de variáveis de ambiente
- Verificação de status e logs

## 📁 Estrutura do Projeto

```
src/
├── main/
│   ├── java/com/mottu/sprint3/
│   │   ├── config/          # Configurações (Security, Web)
│   │   ├── controller/      # Controladores REST/Web
│   │   ├── dto/             # Data Transfer Objects
│   │   ├── model/           # Entidades JPA
│   │   ├── repository/       # Repositórios JPA
│   │   ├── service/         # Serviços de negócio
│   │   └── util/            # Utilitários
│   └── resources/
│       ├── static/          # CSS, JS, imagens
│       └── templates/       # Templates Thymeleaf
└── test/                    # Testes unitários
```

## 🔧 Fluxos de Negócio Implementados

### 1. Movimentação de Motos
- **Endpoint**: `POST /moto/move`
- **Validações**:
  - Não pode mover para o mesmo local
  - Motos entregues não podem ser movidas
  - Motos em reparo têm restrições específicas
- **Interface**: Modal com seleção de pátio e zona

### 2. Alteração de Status
- **Endpoint**: `POST /moto/change-status`
- **Validações**:
  - Não pode alterar para o mesmo status
  - Motos entregues não podem ter status alterado
  - Motos em reparo só podem ir para status específicos
- **Interface**: Modal com seleção de novo status

## 🛡️ Segurança

### Roles e Permissões
- **ROLE_ADMIN**: Acesso completo ao sistema
- **ROLE_OPERADOR**: Acesso parcial ao sistema
- **ROLE_USER**: Apenas visualização

### Rotas Protegidas
```java
// Apenas ADMIN pode criar/editar/excluir
.requestMatchers("/moto/save", "/patio/save", "/zona/save", "/status/save", "/status-grupo/save").hasRole("ADMIN")
.requestMatchers("/moto/delete/**", "/patio/delete/**", "/zona/delete/**", "/status/delete/**", "/status-grupo/delete/**").hasRole("ADMIN")

// Fluxos de negócio apenas para ADMIN
.requestMatchers("/moto/move/**", "/moto/change-status/**").hasRole("ADMIN")

// Dashboard para todos os usuários autenticados
.requestMatchers("/", "/dashboard").hasAnyRole("ADMIN", "USER")
```

## 🧪 Validações Implementadas

### DTOs com Validações
- **MotoDto**: Pelo menos um campo de identificação (placa/chassi/QR)
- **PatioDto**: Nome obrigatório (2-100 caracteres)
- **ZonaDto**: Nome obrigatório + letra única maiúscula
- **StatusDto**: Nome obrigatório + grupo obrigatório
- **StatusGrupoDto**: Nome obrigatório (2-100 caracteres)

### Tratamento de Erros
- Validações são tratadas com `BindingResult`
- Mensagens de erro/sucesso via `RedirectAttributes`
- Feedback visual nos formulários

## 📊 Dados Iniciais

O sistema vem com dados pré-configurados:

### Grupos de Status
- Entrada, Processamento, Saída, Manutenção, Aguardando

### Status por Grupo
- **Entrada**: Recebida, Registrada
- **Processamento**: Em Inspeção, Em Avaliação, Documentação Pendente
- **Saída**: Pronta para Entrega, Entregue
- **Manutenção**: Necessita Reparo, Em Reparo
- **Aguardando**: Aguardando Cliente, Aguardando Documentos

### Zonas e Pátios
- 4 zonas (A, B, C, D) com nomes descritivos
- 4 pátios para diferentes finalidades

## 📋 Arquivos do Projeto

### Scripts de Deploy
- `deploy-sprint4.sh` - Deploy automatizado completo (cria todos recursos Azure)
- `delete-sprint4.sh` - Remove todos os recursos criados

### Configuração Azure DevOps
- `azure-pipelines.yml` - Pipeline CI/CD com 3 stages (Build, Image, Deploy)

### Docker
- `Dockerfile` - Build multi-stage da aplicação Java

### Banco de Dados
- `script_bd.sql` - DDL completo + dados iniciais

### Código Fonte
- `pom.xml` - Dependências Maven
- `src/` - Código fonte Java Spring Boot

## 🎯 Requisitos Sprint 4 Atendidos

### Obrigatórios (Todos ✅)

✅ **1. Descrição da solução** - Stack tecnológica documentada  
✅ **2. Diagrama de Arquitetura + Fluxo CI/CD** - Diagrama ASCII incluído  
✅ **3. Detalhamento dos componentes** - README completo  
✅ **4. Banco de Dados válido** - MySQL 8.0 em Container ACI (imagem oficial)  
✅ **5. Configuração do projeto no Azure DevOps** - Projeto privado, Git, Scrum  
✅ **6. Convite ao professor** - Acesso pode ser concedido no portal Azure DevOps  
✅ **7. Pipelines CI/CD funcionando** (30 pontos):
  - ✅ CI: Build + Testes automáticos com Maven
  - ✅ CD: Deploy automático após build
  - ✅ Branch master/main configurada
  - ✅ Artefatos publicados no Azure DevOps
  - ✅ Imagem Docker no ACR
  - ✅ Deploy em Azure Container Instance

### Pipeline CI/CD - 3 Stages

**Stage 1: BUILD** (CI)
- Maven build com compilação
- Testes unitários automáticos
- Publicação de artefatos

**Stage 2: IMAGE**
- Build da imagem Docker
- Push para Azure Container Registry
- Versionamento com BuildId + latest

**Stage 3: DEPLOY** (CD)
- Deploy no Azure Container Instance
- Configuração de variáveis de ambiente
- Conexão segura com MySQL
- Verificação de status e logs

### Tecnologia e Segurança

✅ **Docker multi-stage**: Build otimizado  
✅ **Container não-root**: Usuário `appuser` (UID 10001)  
✅ **Banco na nuvem**: MySQL 8.0 oficial em Container ACI  
✅ **Alta disponibilidade**: ACI com restart policy Always  
✅ **Automação completa**: Scripts .sh para deploy e limpeza

## 🔍 Comandos Úteis

### Ver logs do container
```bash
az container logs -g rg-sprint4-rm558253 -n aci-sprint4-rm558253
```

### Ver status da aplicação
```bash
az container show -g rg-sprint4-rm558253 -n aci-sprint4-rm558253
```

### Conectar ao MySQL
```bash
mysql -h mysql-sprint4-rm558253.mysql.database.azure.com -u adminuser -p sprint4
```

### Listar recursos criados
```bash
az resource list -g rg-sprint4-rm558253 -o table
```

## 🚀 Início Rápido

Para executar o projeto, consulte: **[COMO-EXECUTAR.md](COMO-EXECUTAR.md)**

```bash
# Login no Azure
az login

# Deploy completo
./deploy-sprint4.sh

# Deletar tudo
./delete-sprint4.sh
```

## 🎓 Informações para Entrega

### Links Obrigatórios no PDF:
1. **GitHub**: [URL do repositório]
2. **Azure DevOps**: [URL do projeto Azure DevOps]
3. **YouTube**: [URL do vídeo demonstrativo]

### Informações do Projeto Azure DevOps:
- **Nome**: Sprint 4 - Azure DevOps
- **Visibilidade**: Private
- **Version Control**: Git
- **Work Item Process**: Scrum

### Convidar Professor:
1. Azure DevOps → Project Settings → Teams
2. Add → Email do professor
3. Role: Contributor (ou superior)

---

**Desenvolvido com ☕ e dedicação para FIAP - DevOps Tools & Cloud Computing**  
**RM556152 - Daniel da Silva Barros**
**RM558253 - Luccas de Alencar Rufino**
**5550063  - Raul Clauson**
