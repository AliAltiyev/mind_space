# Quick Start Guide

## Локальная разработка

### 1. Установка зависимостей

```bash
cd backend
npm install
```

### 2. Настройка окружения

Скопируйте `.env.example` в `.env` и настройте переменные:

```bash
cp .env.example .env
```

Отредактируйте `.env` файл с вашими настройками.

### 3. Запуск инфраструктуры

```bash
# Запустить PostgreSQL, Redis, RabbitMQ
docker-compose up -d postgres redis rabbitmq
```

### 4. Настройка базы данных

```bash
# Применить миграции
npm run migrate:up

# Или вручную
psql -h localhost -U postgres -d mind_space -f database/migrations/001_initial_schema.sql
```

### 5. Запуск сервера

```bash
# Режим разработки (с hot reload)
npm run dev

# Production режим
npm run build
npm start

# С кластеризацией (использует все CPU ядра)
npm run start:cluster
```

### 6. Проверка работы

```bash
# Health check
curl http://localhost:3000/api/health

# Метрики Prometheus
curl http://localhost:3000/metrics
```

## API Endpoints

### Аутентификация

```bash
# Регистрация
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123","name":"John Doe"}'

# Вход
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Обновление токена
curl -X POST http://localhost:3000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"your-refresh-token"}'
```

### Пользователи

```bash
# Получить профиль
curl http://localhost:3000/api/user/profile \
  -H "Authorization: Bearer your-access-token"

# Обновить профиль
curl -X PUT http://localhost:3000/api/user/profile \
  -H "Authorization: Bearer your-access-token" \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","timezone":"America/New_York"}'

# Получить статистику
curl http://localhost:3000/api/user/stats \
  -H "Authorization: Bearer your-access-token"
```

### Медитации

```bash
# Начать сессию
curl -X POST http://localhost:3000/api/meditation/start \
  -H "Authorization: Bearer your-access-token" \
  -H "Content-Type: application/json" \
  -d '{"type":"guided","duration":10}'

# Завершить сессию
curl -X POST http://localhost:3000/api/meditation/end \
  -H "Authorization: Bearer your-access-token" \
  -H "Content-Type: application/json" \
  -d '{"sessionId":"session-id","actualDuration":10,"completed":true}'

# Получить историю
curl "http://localhost:3000/api/sessions?page=1&limit=20" \
  -H "Authorization: Bearer your-access-token"
```

### Аналитика

```bash
# Дневная аналитика
curl "http://localhost:3000/api/analytics/daily?date=2024-01-15" \
  -H "Authorization: Bearer your-access-token"

# Недельная аналитика
curl "http://localhost:3000/api/analytics/weekly?weekStart=2024-01-08" \
  -H "Authorization: Bearer your-access-token"

# Месячная аналитика
curl "http://localhost:3000/api/analytics/monthly?month=2024-01" \
  -H "Authorization: Bearer your-access-token"
```

## WebSocket

### Подключение

```javascript
const io = require('socket.io-client');

const socket = io('http://localhost:3000', {
  path: '/meditation/group',
  auth: {
    token: 'your-access-token'
  }
});

// Присоединиться к группе
socket.emit('join_group', 'group-id');

// Начать медитацию
socket.emit('start_meditation', {
  groupId: 'group-id',
  type: 'guided',
  duration: 10
});

// Завершить медитацию
socket.emit('end_meditation', {
  sessionId: 'session-id',
  actualDuration: 10,
  completed: true
});

// Слушать события
socket.on('member_joined', (data) => {
  console.log('Member joined:', data);
});

socket.on('meditation_started', (data) => {
  console.log('Meditation started:', data);
});
```

## Мониторинг

### Prometheus

```bash
# Запустить Prometheus
docker-compose --profile monitoring up -d prometheus

# Доступ: http://localhost:9090
```

### Grafana

```bash
# Запустить Grafana
docker-compose --profile monitoring up -d grafana

# Доступ: http://localhost:3001
# Логин: admin / Пароль: admin
```

## Production деплой

### AWS

```bash
# Создать инфраструктуру через CloudFormation
aws cloudformation create-stack \
  --stack-name mind-space-backend \
  --template-body file://deploy/aws/cloudformation-template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=production
```

### DigitalOcean

```bash
# Установить doctl
# https://docs.digitalocean.com/reference/doctl/how-to/install/

# Деплой
./deploy/digitalocean/deploy.sh production
```

## Troubleshooting

### Проблемы с подключением к БД

```bash
# Проверить подключение
psql -h localhost -U postgres -d mind_space

# Проверить логи
docker-compose logs postgres
```

### Проблемы с Redis

```bash
# Проверить подключение
redis-cli -h localhost ping

# Проверить логи
docker-compose logs redis
```

### Проблемы с портами

```bash
# Проверить занятые порты
netstat -an | grep LISTEN

# Изменить порты в .env файле
```

## Дополнительные ресурсы

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Детальная архитектура
- [README.md](./README.md) - Полная документация
- [API Documentation](./docs/api.md) - API документация (если создана)

