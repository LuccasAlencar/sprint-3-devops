# Grupo

- Daniel da Silva Barros | RM 556152
- Luccas de Alencar Rufino | RM 558253
- Raul Clauson | RM 555006


# Sistema Mottu - Sprint 3 DevOps

Sistema web completo para gerenciamento de motos desenvolvido com Spring Boot, Thymeleaf, Spring Security e MySQL, deployado na nuvem Azure usando ACR + ACI.

## 🚀 Tecnologias Utilizadas

- **Spring Boot 3.5.6** - Framework principal
- **Thymeleaf** - Template engine para frontend
- **Spring Security** - Autenticação e autorização
- **MySQL 8.0** - Banco de dados na nuvem
- **Bootstrap 5** - Framework CSS
- **Maven** - Gerenciamento de dependências
- **Docker** - Containerização
- **Azure Container Registry (ACR)** - Armazenamento de imagens
- **Azure Container Instances (ACI)** - Execução na nuvem

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

## 🚀 Deploy na Nuvem Azure (ACR + ACI)

### Pré-requisitos
- Azure CLI instalado e configurado
- Docker instalado
- Arquivo `.env` configurado com seu RM

### 1. Configuração do Ambiente

Crie um arquivo `.env` na raiz do projeto:

```bash
# Identificador (usado para nomear RG/ACR/ACI)
RM=

# MySQL (usado para testes locais)
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=sprint3
DB_USER=root
DB_PASSWORD=Admin123!
```

### 2. Deploy Completo

Execute os comandos na sequência:

```bash
# 1. Dar permissão de execução aos scripts
chmod +x *.sh

# 2. Build e push da imagem para o ACR
./build.sh

# 3. Deploy dos containers no ACI (MySQL + App)
./deploy.sh

# 4. Testar conexão com o MySQL na nuvem
docker run --rm -e MYSQL_PWD=Admin123! mysql:8.0 \
  mysql -h <DB_IP> -u root -e "SELECT 1;"

# 5. Popular o banco com dados iniciais
docker run --rm -i -e MYSQL_PWD=Admin123! mysql:8.0 \
  mysql -h <DB_IP> -u root < script_bd.sql

# 6. Verificar se as tabelas foram criadas
docker run --rm -e MYSQL_PWD=Admin123! mysql:8.0 \
  mysql -h <DB_IP> -u root -e "USE sprint3; SHOW TABLES;"
```

**Nota:** Substitua `<DB_IP>` pelo IP do MySQL que será exibido no final do comando `./deploy.sh`.

### 3. Acesso à Aplicação

Após o deploy, acesse a aplicação usando o IP direto (mais confiável):

- **URL**: http://<APP_IP>:8080/login
- **Login**: admin / password (para acesso completo)
- **Login**: operador / password (para mudanças de status e zonas)
- **Login**: user / password (para visualização)

**Nota:** O `<APP_IP>` será exibido no final do comando `./deploy.sh`.

### 4. Limpeza dos Recursos

Para remover todos os recursos criados na Azure:

```bash
./delete.sh
```

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

## 📋 Arquivos de Deploy

- `Dockerfile` - Imagem da aplicação (multi-stage build)
- `build.sh` - Script para build e push no ACR
- `deploy.sh` - Script para deploy no ACI
- `delete.sh` - Script para limpeza dos recursos
- `script_bd.sql` - DDL e dados iniciais do MySQL
- `.env` - Configurações de ambiente (criar localmente)

## 🎯 Requisitos da Sprint Atendidos

✅ **ACR + ACI**: Azure Container Registry + Azure Container Instances  
✅ **Banco na Nuvem**: MySQL 8.0 rodando no ACI  
✅ **Imagem Oficial**: MySQL oficial do Docker Hub  
✅ **Container não-root**: Dockerfile configurado com usuário appuser  
✅ **Scripts de Build/Deploy**: build.sh, deploy.sh, delete.sh  
✅ **DDL Separado**: script_bd.sql com estrutura e dados  
✅ **CRUD Completo**: Sistema de gerenciamento de motos  
✅ **2+ Registros**: Dados iniciais pré-carregados  

**Desenvolvido com muito ☕ para o curso DevOps Tools & Cloud Computing - FIAP**
