# Mind Space - Architecture Documentation

## Обзор

Mind Space - это Flutter приложение для отслеживания настроения и мыслей с элементами ИИ, построенное на строгой Clean Architecture.

## Архитектура

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │     Pages       │  │    Widgets      │  │  Providers  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Entities      │  │   Use Cases     │  │ Repositories│ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │    Models       │  │ Data Sources    │  │Repositories │ │
│  │                 │  │                 │  │   Impl      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                      Core Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Constants     │  │     Utils       │  │   Services  │ │
│  │   Errors        │  │   Network       │  │   Database  │ │
│  │      DI         │                    │               │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Структура проекта

```
lib/
├── app/                          # Application Layer
│   ├── providers/               # Riverpod провайдеры
│   │   ├── app_providers.dart   # Основные провайдеры
│   │   └── localization_provider.dart
│   └── routing/                 # Навигация
│       └── app_router.dart      # Go Router конфигурация
│
├── core/                        # Core Layer
│   ├── constants/              # Константы приложения
│   ├── errors/                 # Обработка ошибок
│   ├── utils/                  # Утилиты
│   ├── services/               # Сервисы
│   ├── di/                     # Dependency Injection
│   ├── network/                # Сетевые запросы
│   └── database/               # База данных
│
├── features/                    # Feature Modules
│   ├── mood_tracking/          # Модуль отслеживания настроения
│   │   ├── data/              # Data Layer
│   │   ├── domain/            # Domain Layer
│   │   └── presentation/      # Presentation Layer
│   └── ai_insights/           # Модуль ИИ-инсайтов
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/                      # Shared Components
│   ├── data/                   # Общие модели данных
│   ├── domain/                 # Общие сущности
│   └── presentation/           # Общие UI компоненты
│       ├── pages/             # Общие страницы
│       ├── theme/             # Система тем
│       └── widgets/           # Переиспользуемые виджеты
│
├── generated/                   # Сгенерированный код
└── main.dart                   # Точка входа
```

## Технологический стек

### State Management
- **Riverpod 2.0** - Современное управление состоянием
- **flutter_riverpod** - Основной пакет
- **riverpod_annotation** - Генерация провайдеров
- **riverpod_generator** - Автоматическая генерация

### Dependency Injection
- **injectable** - Аннотации для DI
- **get_it** - Service Locator
- **injectable_generator** - Генерация DI кода

### Localization
- **easy_localization** - Простая локализация
- **flutter_localizations** - Flutter локализация

### Routing
- **go_router** - Декларативная навигация
- Защищенные маршруты
- Nested routing

### Database
- **drift** - Type-safe SQLite
- **drift_flutter** - Flutter интеграция
- **drift_dev** - Генерация кода

### Network
- **dio** - HTTP клиент
- **retrofit** - REST API клиент
- **retrofit_generator** - Генерация API клиентов

### Code Generation
- **freezed** - Immutable классы
- **json_serializable** - JSON сериализация
- **build_runner** - Запуск генерации

### UI/UX
- **google_fonts** - Шрифты
- **lottie** - Анимации
- **fl_chart** - Графики
- **glassmorphism** - Стеклянные эффекты

## Принципы архитектуры

### 1. Clean Architecture
- Четкое разделение на слои
- Зависимости направлены внутрь
- Каждый слой имеет четкие контракты

### 2. SOLID Principles
- **S** - Single Responsibility
- **O** - Open/Closed
- **L** - Liskov Substitution
- **I** - Interface Segregation
- **D** - Dependency Inversion

### 3. Dependency Injection
- Все зависимости инжектируются
- Никаких `new` в UI слое
- Легкое тестирование

### 4. Immutable State
- Freezed для immutable классов
- Predictable state changes
- Thread-safe операции

### 5. Type Safety
- Строгая типизация
- Генерация кода для безопасности
- Compile-time проверки

## Генерация кода

Для генерации всего необходимого кода запустите:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

Это сгенерирует:
- Freezed классы
- JSON сериализацию
- Injectable DI
- Riverpod провайдеры
- Drift таблицы
- Retrofit клиенты

## Запуск приложения

1. Установите зависимости:
```bash
flutter pub get
```

2. Сгенерируйте код:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

3. Запустите приложение:
```bash
flutter run
```

## Тестирование

Архитектура спроектирована для легкого тестирования:
- Моки для всех зависимостей
- Изолированные unit тесты
- Widget тесты для UI
- Integration тесты для E2E

## Расширение

Для добавления новой фичи:
1. Создайте папку в `features/`
2. Создайте слои: `data/`, `domain/`, `presentation/`
3. Добавьте роуты в `app_router.dart`
4. Создайте провайдеры в `app/providers/`
5. Добавьте переводы в `assets/translations/`

Эта архитектура обеспечивает:
- Масштабируемость
- Тестируемость
- Поддерживаемость
- Читаемость кода
- Производительность

