# FixIt - Sistema de Ordem de Serviço

## 🐳 Executando com Docker

### Pré-requisitos
- Docker
- Docker Compose v2 (plugin do Docker)

### Como rodar o sistema completo

1. **A dependência do Actuator já foi adicionada ao pom.xml** ✅

2. **Iniciar todos os serviços**:

```bash
docker compose up -d
```

Este comando irá:
- Criar e iniciar o banco de dados PostgreSQL
- Compilar e iniciar o backend Java/Spring Boot
- Iniciar o n8n para automações

3. **Verificar o status dos serviços**:

```bash
docker compose ps
```

4. **Ver os logs**:

```bash
# Todos os serviços
docker compose logs -f

# Apenas o backend
docker compose logs -f backend

# Apenas o banco de dados
docker compose logs -f postgres
```

### Acessando os serviços

- **Backend API**: http://localhost:8080
- **Health Check**: http://localhost:8080/actuator/health
- **PostgreSQL**: localhost:5432
  - Database: `fixit_db`
  - User: `fixit_user`
  - Password: `fixit_password`
- **n8n**: http://localhost:5678

### Comandos úteis

```bash
# Parar todos os serviços
docker compose down

# Parar e remover volumes (limpa o banco de dados)
docker compose down -v

# Rebuild do backend após mudanças no código
docker compose up -d --build backend

# Reiniciar apenas o backend
docker compose restart backend

# Ver logs em tempo real
docker compose logs -f backend
```

### Desenvolvimento

Para desenvolvimento local sem Docker:

1. Certifique-se de que o PostgreSQL está rodando (pode usar apenas o serviço do postgres):
```bash
docker compose up -d postgres
```

2. Execute o backend localmente:
```bash
cd backend
./mvnw spring-boot:run
```

### Configuração de Ambiente

As variáveis de ambiente do backend estão configuradas no `docker-compose.yml`:

- `SPRING_PROFILES_ACTIVE=docker` - Usa o profile Docker
- `SPRING_DATASOURCE_URL` - URL do banco de dados
- `JWT_SECRET` - **⚠️ IMPORTANTE**: Altere em produção!
- `JWT_EXPIRATION` - Tempo de expiração do token (24h)

### Troubleshooting

**Backend não inicia:**
- Verifique se o PostgreSQL está healthy: `docker compose ps`
- Veja os logs: `docker compose logs backend`

**Erro de conexão com o banco:**
- O backend aguarda o PostgreSQL ficar healthy antes de iniciar
- Verifique as credenciais no `docker-compose.yml`

**Rebuild completo:**
```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

## 📱 Frontend Flutter

O frontend Flutter deve ser executado separadamente:

```bash
cd frontend
flutter pub get
flutter run
```

Configure a URL da API no frontend para apontar para `http://localhost:8080` (ou o IP da sua máquina se estiver testando em dispositivo físico).

## 🔒 Segurança

**⚠️ IMPORTANTE para Produção:**

1. Altere o `JWT_SECRET` no `docker-compose.yml` para um valor seguro
2. Use secrets do Docker ou variáveis de ambiente externas
3. Altere as credenciais do PostgreSQL
4. Configure HTTPS/SSL
5. Revise as configurações de CORS no backend
