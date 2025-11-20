# Mind Space Backend - Scalable Meditation App Backend

Высокопроизводительный бэкенд для приложения медитации, рассчитанный на тысячи одновременных пользователей.

## Архитектура

### Микросервисы
- **API Gateway** (порт 8080) - единая точка входа, роутинг, балансировка
- **Auth Service** (порт 3001) - аутентификация и авторизация
- **User Service** (порт 3002) - управление пользователями
- **Meditation Service** (порт 3003) - сессии медитаций, WebSocket
- **Analytics Service** (порт 3004) - аналитика и статистика

### Технологический стек
- **Backend**: Node.js + Express с кластеризацией
- **База данных**: PostgreSQL с репликацией + PgBouncer
- **Кэширование**: Redis Cluster
- **Message Queue**: RabbitMQ / Kafka
- **Балансировщик**: Nginx
- **Мониторинг**: Prometheus + Grafana

## Быстрый старт

### Локальная разработка

1. Установите зависимости:
```bash
npm install
```

2. Настройте переменные окружения:
```bash
cp .env.example .env
# Отредактируйте .env файл
```

3. Запустите инфраструктуру (PostgreSQL, Redis, RabbitMQ):
```bash
docker-compose up -d postgres redis rabbitmq
```

4. Запустите миграции:
```bash
npm run migrate:up
```

5. Запустите сервисы в режиме разработки:
```bash
# API Gateway
npm run dev

# Или отдельные сервисы
cd services/auth-service && npm run dev
cd services/user-service && npm run dev
cd services/meditation-service && npm run dev
cd services/analytics-service && npm run dev
```

### Production

1. Соберите проект:
```bash
npm run build
```

2. Запустите с кластеризацией:
```bash
npm run start:cluster
```

3. Или используйте Docker:
```bash
docker-compose --profile production up -d
```

## Конфигурация масштабирования

### До 1K пользователей
- Single server + PostgreSQL
- Базовое кэширование Redis
- Один экземпляр каждого сервиса

### До 10K пользователей
- Multiple servers + Read replicas
- Redis Cluster
- Горизонтальное масштабирование сервисов
- Nginx load balancer

### До 100K+ пользователей
- Full microservices + Auto Scaling
- Геораспределение
- CDN для статики
- Автоматическое масштабирование на AWS/DigitalOcean

## API Endpoints

### Аутентификация
- `POST /api/auth/register` - Регистрация
- `POST /api/auth/login` - Вход
- `POST /api/auth/refresh` - Обновление токена
- `POST /api/auth/logout` - Выход

### Пользователи
- `GET /api/user/profile` - Профиль пользователя
- `PUT /api/user/profile` - Обновление профиля
- `GET /api/user/stats` - Статистика пользователя (кэшируется)

### Медитации
- `POST /api/meditation/start` - Начать сессию
- `POST /api/meditation/end` - Завершить сессию
- `GET /api/sessions` - История сессий (с пагинацией)
- `WS /meditation/group` - WebSocket для групповых медитаций

### Аналитика
- `GET /api/analytics/daily` - Дневная аналитика
- `GET /api/analytics/weekly` - Недельная аналитика
- `GET /api/analytics/monthly` - Месячная аналитика

## Мониторинг

### Prometheus
- Метрики доступны на `http://localhost:9090`
- Endpoint для метрик: `/metrics`

### Grafana
- Доступ: `http://localhost:3001`
- Логин: `admin` / Пароль: `admin`

## Безопасность

- JWT с коротким временем жизни access токенов (15 минут)
- Refresh токены с ротацией (7 дней)
- Rate limiting по IP и пользователю
- HTTPS с современными шифрами
- Helmet.js для защиты заголовков
- Валидация входных данных через Zod

## Производительность

- Connection pooling (PgBouncer)
- Многоуровневое кэширование (Redis, in-memory)
- Сжатие ответов (gzip/brotli)
- Пагинация для больших списков
- Batch processing для аналитики
- Оптимизированные индексы БД

## Логирование

Логи сохраняются в `./logs/`:
- `combined.log` - все логи
- `error.log` - только ошибки
- Ротация логов по дням

## Тестирование

```bash
npm test
```

## Миграции БД

```bash
# Создать новую миграцию
npm run migrate create migration_name

# Применить миграции
npm run migrate:up

# Откатить миграцию
npm run migrate:down
```

## Деплой

### AWS EC2
См. `deploy/aws/` для конфигурации Auto Scaling Groups и Load Balancers.

### DigitalOcean
См. `deploy/digitalocean/` для конфигурации Droplets и Load Balancers.

## Лицензия

MIT

