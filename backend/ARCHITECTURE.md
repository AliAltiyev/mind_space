# Mind Space Backend Architecture

## Обзор

Масштабируемый бэкенд для приложения медитации, рассчитанный на тысячи одновременных пользователей.

## Архитектура системы

### Микросервисная архитектура

```
┌─────────────────┐
│   Nginx LB      │
│  (Load Balancer)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   API Gateway   │
│   (Port 8080)   │
└────────┬────────┘
         │
    ┌────┴────┬──────────┬─────────────┐
    │         │          │             │
    ▼         ▼          ▼             ▼
┌────────┐ ┌────────┐ ┌──────────┐ ┌──────────┐
│  Auth  │ │  User  │ │Meditation│ │Analytics │
│Service │ │Service │ │ Service  │ │ Service  │
│ :3001  │ │ :3002  │ │  :3003   │ │  :3004   │
└────────┘ └────────┘ └──────────┘ └──────────┘
```

### Компоненты

#### 1. API Gateway
- Единая точка входа для всех запросов
- Роутинг между микросервисами
- Rate limiting
- Аутентификация
- Метрики и логирование

#### 2. Auth Service
- Регистрация и аутентификация пользователей
- JWT токены (access + refresh)
- Token rotation
- Rate limiting для auth endpoints

#### 3. User Service
- Управление профилями пользователей
- Статистика пользователей
- Кэширование данных пользователей

#### 4. Meditation Service
- Управление сессиями медитаций
- WebSocket для групповых медитаций
- История сессий с пагинацией

#### 5. Analytics Service
- Дневная, недельная, месячная аналитика
- Pre-aggregated данные
- Batch processing для оптимизации

## База данных

### PostgreSQL

**Основные таблицы:**
- `users` - пользователи
- `meditation_sessions` - сессии медитаций

**Оптимизации:**
- Индексы на часто используемых полях
- Composite индексы для аналитических запросов
- Materialized views для статистики
- Partitioning для больших таблиц (опционально)

**Репликация:**
- Primary для записи
- Read replicas для чтения (в production)

### Redis

**Использование:**
- Кэширование данных пользователей
- Сессии и refresh токены
- Rate limiting
- WebSocket connection tracking

**Конфигурация:**
- Single instance (development)
- Cluster mode (production)

## Масштабирование

### До 1K пользователей
- Single server
- PostgreSQL без репликации
- Redis single instance
- Базовое кэширование

### До 10K пользователей
- Multiple servers (2-3)
- PostgreSQL с read replicas
- Redis Cluster
- Nginx load balancer
- Горизонтальное масштабирование сервисов

### До 100K+ пользователей
- Full microservices
- Auto Scaling (AWS/DigitalOcean)
- Геораспределение
- CDN для статики
- Database sharding (при необходимости)

## Безопасность

1. **Аутентификация:**
   - JWT с коротким временем жизни (15 минут)
   - Refresh токены с ротацией (7 дней)
   - Token blacklisting при logout

2. **Rate Limiting:**
   - По IP адресу
   - По пользователю
   - Разные лимиты для разных endpoints

3. **Защита:**
   - Helmet.js для заголовков
   - CORS настройки
   - Валидация входных данных (Zod)
   - HTTPS в production

## Производительность

### Кэширование
- **Уровень 1:** In-memory (Node.js)
- **Уровень 2:** Redis
- **Уровень 3:** CDN (для статики)

### Оптимизации
- Connection pooling (PgBouncer)
- Сжатие ответов (gzip/brotli)
- Пагинация для больших списков
- Pre-aggregated аналитика
- Batch processing для тяжелых операций

### Мониторинг
- Prometheus для метрик
- Grafana для визуализации
- Centralized logging (Winston)
- Application Performance Monitoring

## WebSocket

### Групповые медитации
- Real-time синхронизация
- Отслеживание активных участников
- События: join, leave, start, end

### Масштабирование WebSocket
- Sticky sessions через load balancer
- Redis pub/sub для межсерверной коммуникации
- Connection pooling

## Message Queue

### RabbitMQ / Kafka
- Асинхронная обработка аналитики
- Batch processing
- Event-driven архитектура

## Деплой

### AWS
- EC2 Auto Scaling Groups
- Application Load Balancer
- RDS PostgreSQL
- ElastiCache Redis
- CloudFormation templates

### DigitalOcean
- Droplets с Auto Scaling
- Load Balancer
- Managed Databases
- Deployment scripts

## Мониторинг и алертинг

### Метрики
- HTTP request rate и duration
- Database connection pool
- Cache hit/miss ratio
- WebSocket connections
- Business metrics (sessions, users)

### Алерты
- High error rate
- High latency (p95, p99)
- Database connection exhaustion
- Cache miss rate spike
- High memory/CPU usage

## Логирование

- Structured logging (JSON)
- Log levels: error, warn, info, debug
- Daily rotation
- Centralized collection (ELK stack в production)

## Тестирование

- Unit tests для сервисов
- Integration tests для API
- Load testing для проверки масштабируемости
- E2E tests для критических путей

## CI/CD

1. **Build:** TypeScript compilation
2. **Test:** Run test suite
3. **Lint:** Code quality checks
4. **Build Docker:** Create images
5. **Deploy:** Rolling deployment
6. **Health Check:** Verify deployment

## Резервное копирование

- PostgreSQL: Daily backups (7 days retention)
- Redis: Snapshot каждые 6 часов
- Application logs: 30 days retention
- Disaster recovery plan


