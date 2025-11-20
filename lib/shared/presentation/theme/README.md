# Универсальная система дизайна для Android и iOS

## Обзор

Эта система дизайна обеспечивает единообразный внешний вид приложения на обеих платформах, используя Material 3 с адаптацией для iOS.

## Основные принципы

1. **Material 3 как основа** - Используем Material Design 3 для создания современного интерфейса
2. **Адаптация для iOS** - Автоматическая адаптация стилей для iOS (скругления, отступы, elevation)
3. **Theme.of(context)** - Все цвета берутся из темы, а не жестко заданы
4. **Платформо-зависимые компоненты** - Используем платформо-специфичные виджеты где необходимо

## Использование

### Базовое использование темы

```dart
// Получение темы
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final isDark = theme.brightness == Brightness.dark;

// Использование цветов из темы
Container(
  color: colorScheme.surface,
  child: Text(
    'Hello',
    style: TextStyle(color: colorScheme.onSurface),
  ),
)
```

### Адаптивные компоненты

```dart
// Использование адаптивных утилит
import 'package:mind_space/shared/presentation/theme/platform_utils.dart';

Container(
  padding: EdgeInsets.all(PlatformUtils.getAdaptivePadding(context)),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(context.adaptiveRadius),
    color: context.adaptiveSurfaceColor,
  ),
)
```

### Платформо-зависимые виджеты

```dart
// Использование платформо-зависимых виджетов
import 'package:mind_space/shared/presentation/theme/platform_utils.dart';

if (PlatformUtils.isIOS) {
  // iOS-специфичный код
  return CupertinoButton(...);
} else {
  // Android-специфичный код
  return ElevatedButton(...);
}
```

## Цветовая схема

Все цвета берутся из `ColorScheme`, который автоматически генерируется на основе seed color:

- `colorScheme.primary` - Основной цвет
- `colorScheme.secondary` - Вторичный цвет
- `colorScheme.surface` - Цвет поверхности
- `colorScheme.onSurface` - Цвет текста на поверхности
- `colorScheme.surfaceContainerHighest` - Высокий уровень поверхности
- `colorScheme.outline` - Цвет границ

## Адаптация для iOS

Система автоматически адаптирует следующие параметры для iOS:

- **Скругления**: 12px вместо 16px
- **Elevation**: 0 вместо 2
- **Letter spacing**: -0.41 вместо 0
- **Отступы**: Немного уменьшены
- **Размеры шрифтов**: Немного уменьшены

## Темная тема

Темная тема полностью поддерживается и автоматически адаптируется для обеих платформ.

## Примеры компонентов

### Карточка

```dart
Card(
  child: ListTile(
    title: Text('Title'),
    subtitle: Text('Subtitle'),
  ),
)
```

### Кнопка

```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Button'),
)
```

### Поле ввода

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Hint',
  ),
)
```

## Миграция существующих экранов

При миграции существующих экранов:

1. Замените `AppColors.xxx` на `colorScheme.xxx`
2. Используйте `Theme.of(context)` вместо прямого доступа к цветам
3. Используйте адаптивные утилиты для отступов и скруглений
4. Удалите жестко заданные цвета для темной темы

## Лучшие практики

1. **Всегда используйте Theme.of(context)** - Не используйте жестко заданные цвета
2. **Используйте адаптивные утилиты** - Для отступов, скруглений и других параметров
3. **Тестируйте на обеих платформах** - Убедитесь, что дизайн выглядит хорошо на iOS и Android
4. **Используйте Material 3 компоненты** - Они автоматически адаптируются для обеих платформ

