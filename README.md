# Grupo

- Daniel da Silva Barros | RM 556152
- Luccas de Alencar Rufino | RM 558253
- Raul Clauson | RM 555006


# Sistema Mottu - Sprint 3

Sistema web completo para gerenciamento de motos desenvolvido com Spring Boot, Thymeleaf, Spring Security e Flyway.

## 🚀 Tecnologias Utilizadas

- **Spring Boot 3.5.6** - Framework principal
- **Thymeleaf** - Template engine para frontend
- **Spring Security** - Autenticação e autorização
- **Flyway** - Controle de versão do banco de dados
- **Oracle Database** - Banco de dados
- **Bootstrap 5** - Framework CSS
- **Maven** - Gerenciamento de dependências

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

## 🚀 Como Executar

### Pré-requisitos
- Java 17+
- Maven 3.6+
- Oracle Database (ou Docker com Oracle)

### 1. Configuração do Banco de Dados

Edite o arquivo `src/main/resources/application.properties`:

```properties
# Configuração do banco Oracle
spring.datasource.url=jdbc:oracle:thin:@localhost:1521:xe
spring.datasource.username=SeuUsuario
spring.datasource.password=SuaSenha
spring.datasource.driver-class-name=oracle.jdbc.driver.OracleDriver

# Configuração JPA
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.OracleDialect

# Configuração Flyway
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
spring.flyway.baseline-on-migrate=true
```

### 3. Execução

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd sprint-3-java

# Compile e execute
mvn clean install
mvn spring-boot:run
```

### 4. Acesso

- **URL**: http://localhost:8080
- **Login**: admin / password (para acesso completo)
- **Login**: operador / password (para mudanças de status e zonas)
- **Login**: user / password (para visualização)

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
│       ├── db/migration/    # Scripts Flyway
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

## 🐛 Troubleshooting

### Problemas Comuns

1. **Erro de conexão com Oracle**
   - Verifique se o Oracle está rodando
   - Confirme as credenciais no `application.properties`
   - Teste a conexão: `telnet localhost 1521`

2. **Erro de migração Flyway**
   - Verifique se o usuário tem permissões adequadas
   - Limpe o schema se necessário: `DROP USER mottu CASCADE;`

3. **Página não carrega**
   - Verifique se a porta 8080 está livre
   - Confirme se o Maven baixou todas as dependências

### Logs Úteis
```bash
# Ativar logs detalhados
logging.level.com.mottu.sprint3=DEBUG
logging.level.org.flywaydb=DEBUG
```


**Desenvolvido com muito ☕ para o curso Java Advanced - FIAP**
