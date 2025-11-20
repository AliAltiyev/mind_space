# 🔧 ПРИМЕРЫ ИСПРАВЛЕНИЙ ЛОКАЛИЗАЦИИ

Этот файл содержит конкретные примеры того, как исправить хардкодные строки в коде.

---

## 📋 ОБЩИЕ ПРАВИЛА

### 1. Простой текст без параметров

```dart
// ❌ БЫЛО:
Text('Удалить все данные?')

// ✅ СТАЛО:
Text('settings.delete_all_data_dialog'.tr())
```

### 2. Текст с параметрами

```dart
// ❌ БЫЛО:
'Время напоминания изменено на ${_formatTime(time)}'

// ✅ СТАЛО:
'settings.reminder_time_changed'.tr(namedArgs: {'time': _formatTime(time)})

// В файле локализации:
"reminder_time_changed": "Reminder time changed to {time}"
```

### 3. Кнопки с const

```dart
// ❌ БЫЛО:
child: const Text('Отмена')

// ✅ СТАЛО:
child: Text('common.cancel'.tr())
// Убираем const, так как .tr() не константа!
```

---

## 🔧 КОНКРЕТНЫЕ ИСПРАВЛЕНИЯ

### 1. ❗ settings_screen_modern.dart

#### Диалог удаления данных (строки 650-672):

```dart
// ❌ БЫЛО:
void _showDeleteDataDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удалить все данные?'),
      content: const Text('Это действие нельзя отменить. Все ваши записи настроения и настройки будут удалены.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _deleteAllData();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
}

// ✅ СТАЛО:
void _showDeleteDataDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('settings.delete_all_data_dialog'.tr()),
      content: Text('settings.delete_all_data_warning'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _deleteAllData();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text('common.delete'.tr()),
        ),
      ],
    ),
  );
}
```

#### Диалог помощи (строки 684-698):

```dart
// ❌ БЫЛО:
void _showHelpDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Помощь и поддержка'),
      content: const Text('Здесь будет раздел помощи с часто задаваемыми вопросами и инструкциями по использованию приложения.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    ),
  );
}

// ✅ СТАЛО:
void _showHelpDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('settings.help_support'.tr()),
      content: Text('settings.help_support_desc'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.close'.tr()),
        ),
      ],
    ),
  );
}
```

#### Диалог обратной связи (строки 700-714):

```dart
// ❌ БЫЛО:
void _showFeedbackDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Обратная связь'),
      content: const Text('Спасибо за использование Mind Space! Ваше мнение очень важно для нас. Вы можете отправить отзыв через App Store или Google Play.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    ),
  );
}

// ✅ СТАЛО:
void _showFeedbackDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('settings.feedback_dialog'.tr()),
      content: Text('settings.feedback_message'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.close'.tr()),
        ),
      ],
    ),
  );
}
```

#### Политика конфиденциальности (строки 721-735):

```dart
// ❌ БЫЛО:
void _showPrivacyPolicy() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Политика конфиденциальности'),
      content: const Text('Здесь будет текст политики конфиденциальности, описывающий как мы собираем, используем и защищаем ваши данные.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    ),
  );
}

// ✅ СТАЛО:
void _showPrivacyPolicy() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('settings.privacy_policy'.tr()),
      content: Text('settings.privacy_policy_content'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.close'.tr()),
        ),
      ],
    ),
  );
}
```

#### Условия использования (строки 737-751):

```dart
// ❌ БЫЛО:
void _showTermsOfService() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Условия использования'),
      content: const Text('Здесь будут условия использования приложения, правила и ограничения.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    ),
  );
}

// ✅ СТАЛО:
void _showTermsOfService() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('settings.terms_of_service'.tr()),
      content: Text('settings.terms_of_service_content'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.close'.tr()),
        ),
      ],
    ),
  );
}
```

#### Диалог сброса настроек (строки 753-770):

```dart
// ❌ БЫЛО:
void _showResetSettingsDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Сбросить настройки?'),
      content: const Text('Все настройки будут возвращены к значениям по умолчанию. Ваши данные настроения не будут затронуты.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _resetSettings();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.warning),
          child: const Text('Сбросить'),
        ),
      ],
    ),
  );
}

// ✅ СТАЛО:
void _showResetSettingsDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('settings.reset_settings_dialog_title'.tr()),
      content: Text('settings.reset_settings_warning'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _resetSettings();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.warning),
          child: Text('common.reset'.tr()),
        ),
      ],
    ),
  );
}
```

#### SnackBar сообщения:

```dart
// ❌ БЫЛО (строка 542):
_showErrorSnackBar('Ошибка обновления настройки');

// ✅ СТАЛО:
_showErrorSnackBar('settings.settings_update_error'.tr());

// ❌ БЫЛО (строка 640):
_showSuccessSnackBar('Время напоминания изменено на ${_formatTime(time)}');

// ✅ СТАЛО:
_showSuccessSnackBar('settings.reminder_time_updated'.tr(namedArgs: {'time': _formatTime(time)}));

// ❌ БЫЛО (строка 647):
_showSuccessSnackBar('Экспорт данных будет реализован в следующей версии');

// ✅ СТАЛО:
_showSuccessSnackBar('settings.export_data_message'.tr());

// ❌ БЫЛО (строка 678):
_showSuccessSnackBar('Все данные удалены');

// ✅ СТАЛО:
_showSuccessSnackBar('settings.all_data_deleted'.tr());

// ❌ БЫЛО (строка 680):
_showErrorSnackBar('Ошибка удаления данных');

// ✅ СТАЛО:
_showErrorSnackBar('settings.delete_data_error'.tr());

// ❌ БЫЛО (строка 718):
_showSuccessSnackBar('Спасибо за оценку!');

// ✅ СТАЛО:
_showSuccessSnackBar('settings.thank_you_rating'.tr());

// ❌ БЫЛО (строка 781):
_showSuccessSnackBar('Настройки сброшены');

// ✅ СТАЛО:
_showSuccessSnackBar('settings.settings_reset_success'.tr());

// ❌ БЫЛО (строка 783):
_showErrorSnackBar('Ошибка сброса настроек');

// ✅ СТАЛО:
_showErrorSnackBar('settings.settings_reset_error'.tr());
```

---

### 2. ❗ edit_profile_page.dart

```dart
// ❌ БЫЛО (строка 14):
appBar: AppBar(
  title: const Text('Редактировать профиль'),
  backgroundColor: Colors.transparent,
  elevation: 0,
),

// ✅ СТАЛО:
appBar: AppBar(
  title: Text('profile.edit'.tr()),
  backgroundColor: Colors.transparent,
  elevation: 0,
),

// ❌ БЫЛО (строка 51):
return const Center(child: Text('Профиль обновлен!'));

// ✅ СТАЛО:
return Center(child: Text('profile.updated_successfully'.tr()));

// ❌ БЫЛО (строка 60):
Text(
  'Ошибка загрузки профиля',
  style: Theme.of(context).textTheme.titleLarge,
),

// ✅ СТАЛО:
Text(
  'profile.loading_error_full'.tr(),
  style: Theme.of(context).textTheme.titleLarge,
),

// ❌ БЫЛО (строка 72):
child: const Text('Назад'),

// ✅ СТАЛО:
child: Text('common.back'.tr()),

// ❌ БЫЛО (строка 79):
return const Center(child: Text('Неизвестное состояние'));

// ✅ СТАЛО:
return Center(child: Text('common.unknown_state'.tr()));
```

---

### 3. ❗ edit_profile_form_widget.dart

```dart
// ❌ БЫЛО (строки 186-202):
Row(
  children: [
    Expanded(
      child: OutlinedButton(
        onPressed: widget.onCancel ?? () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: ElevatedButton(
        onPressed: _saveProfile,
        child: const Text('Сохранить'),
      ),
    ),
  ],
)

// ✅ СТАЛО:
Row(
  children: [
    Expanded(
      child: OutlinedButton(
        onPressed: widget.onCancel ?? () => Navigator.pop(context),
        child: Text('common.cancel'.tr()),
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: ElevatedButton(
        onPressed: _saveProfile,
        child: Text('common.save'.tr()),
      ),
    ),
  ],
)
```

---

### 4. ❗ statistics_page.dart

```dart
// ❌ БЫЛО (строка 14):
appBar: AppBar(
  title: const Text('Статистика'),
  backgroundColor: Colors.transparent,
  elevation: 0,
),

// ✅ СТАЛО:
appBar: AppBar(
  title: Text('stats.title'.tr()),
  backgroundColor: Colors.transparent,
  elevation: 0,
),

// ❌ БЫЛО (строки 53-68):
Text(
  'Ошибка загрузки статистики',
  style: Theme.of(context).textTheme.titleLarge,
),
const SizedBox(height: 8),
Text(
  state.message,
  style: Theme.of(context).textTheme.bodyMedium,
  textAlign: TextAlign.center,
),
const SizedBox(height: 16),
ElevatedButton(
  onPressed: () {
    context.read<StatsBloc>().add(LoadStats());
  },
  child: const Text('Повторить'),
),

// ✅ СТАЛО:
Text(
  'stats.loading_error_full'.tr(),
  style: Theme.of(context).textTheme.titleLarge,
),
const SizedBox(height: 8),
Text(
  state.message,
  style: Theme.of(context).textTheme.bodyMedium,
  textAlign: TextAlign.center,
),
const SizedBox(height: 16),
ElevatedButton(
  onPressed: () {
    context.read<StatsBloc>().add(LoadStats());
  },
  child: Text('common.retry'.tr()),
),

// ❌ БЫЛО (строка 75):
return const Center(child: Text('Неизвестное состояние'));

// ✅ СТАЛО:
return Center(child: Text('common.unknown_state'.tr()));
```

---

### 5. ❗ achievements_page.dart

```dart
// ❌ БЫЛО (строка 14):
appBar: AppBar(
  title: const Text('Достижения'),
  backgroundColor: Colors.transparent,
  elevation: 0,
),

// ✅ СТАЛО:
appBar: AppBar(
  title: Text('achievements.title'.tr()),
  backgroundColor: Colors.transparent,
  elevation: 0,
),

// ❌ БЫЛО (строка 193):
child: const Text('Повторить'),

// ✅ СТАЛО:
child: Text('common.retry'.tr()),

// ❌ БЫЛО (строка 200):
return const Center(child: Text('Неизвестное состояние'));

// ✅ СТАЛО:
return Center(child: Text('common.unknown_state'.tr()));
```

---

### 6. ❗ profile_header_widget.dart

```dart
// ❌ БЫЛО (строки 128-131):
if (onEditTap != null)
  ElevatedButton.icon(
    onPressed: onEditTap,
    icon: const Icon(Icons.edit),
    label: const Text('Редактировать профиль'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      foregroundColor: Colors.white,
      side: BorderSide(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
    ),
  ),

// ✅ СТАЛО:
if (onEditTap != null)
  ElevatedButton.icon(
    onPressed: onEditTap,
    icon: const Icon(Icons.edit),
    label: Text('profile.edit'.tr()),
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      foregroundColor: Colors.white,
      side: BorderSide(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
    ),
  ),
```

---

### 7. ❗ AI виджеты (общий паттерн)

#### ai_insight_card.dart, pattern_analysis_card.dart, gratitude_suggestion_card.dart, meditation_suggestion_card.dart:

```dart
// ❌ БЫЛО:
label: const Text('Попробовать снова'),

// ✅ СТАЛО:
label: Text('common.try_again'.tr()),
```

#### gratitude_journal_page.dart и patterns_page.dart:

```dart
// ❌ БЫЛО (страницы ошибок):
Text(
  'Ошибка загрузки', // или 'Ошибка анализа'
  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
),
const SizedBox(height: 8),
Text(
  message,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
  textAlign: TextAlign.center,
),
const SizedBox(height: 16),
ElevatedButton(onPressed: onRetry, child: const Text('Повторить')),

// ✅ СТАЛО:
Text(
  'ai.error_loading'.tr(), // или 'ai.error_analysis'.tr()
  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
),
const SizedBox(height: 8),
Text(
  message,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
  textAlign: TextAlign.center,
),
const SizedBox(height: 16),
ElevatedButton(onPressed: onRetry, child: Text('common.retry'.tr())),
```

#### meditation_suggestion_card.dart (специальный случай):

```dart
// ❌ БЫЛО (строка 260):
label: Text('Начать медитацию (${meditation.duration} мин)'),

// ✅ СТАЛО:
label: Text('ai.meditation.start_with_duration'.tr(
  namedArgs: {'duration': meditation.duration.toString()}
)),
```

---

### 8. ❗ perfected_demo_screen.dart

```dart
// ❌ БЫЛО (строки 299-310):
Text(
  '• Кэширование Paint объектов\n'
  '• Оптимизированные CustomPainter\n'
  '• RepaintBoundary для изоляции\n'
  '• Timer-based cleanup для ripple эффектов\n'
  '• Единая дизайн-система с константами',
  style: TextStyle(
    fontSize: 14,
    color: Colors.white70,
    height: 1.5,
  ),
),

// ✅ СТАЛО:
Text(
  'demo.performance_list'.tr(),
  style: TextStyle(
    fontSize: 14,
    color: Colors.white70,
    height: 1.5,
  ),
),
```

---

## 🚀 БЫСТРЫЙ ПОИСК И ЗАМЕНА

Для быстрого исправления многих случаев можно использовать поиск и замену в IDE:

### Паттерн 1: Отмена
```
Найти:    child: const Text('Отмена')
Заменить: child: Text('common.cancel'.tr())
```

### Паттерн 2: Сохранить
```
Найти:    child: const Text('Сохранить')
Заменить: child: Text('common.save'.tr())
```

### Паттерн 3: Повторить
```
Найти:    child: const Text('Повторить')
Заменить: child: Text('common.retry'.tr())
```

### Паттерн 4: Попробовать снова
```
Найти:    label: const Text('Попробовать снова')
Заменить: label: Text('common.try_again'.tr())
```

### Паттерн 5: Закрыть
```
Найти:    child: const Text('Закрыть')
Заменить: child: Text('common.close'.tr())
```

### Паттерн 6: Назад
```
Найти:    child: const Text('Назад')
Заменить: child: Text('common.back'.tr())
```

---

## ✅ ПРОВЕРКА ПОСЛЕ ИСПРАВЛЕНИЯ

После исправлений запустите эти команды для проверки:

```bash
# Проверка русских хардкодных строк
grep -r "Text('[А-Яа-я]" lib/

# Проверка английских хардкодных строк (без .tr())
grep -r "Text('[A-Za-z].*')" lib/ | grep -v "\.tr()" | grep -v "// "

# Проверка const Text с русскими символами
grep -r "const Text('[А-Яа-я]" lib/
```

Если команды ничего не находят - отлично! Все исправлено.

---

## 📱 ТЕСТИРОВАНИЕ

После исправлений обязательно протестируйте:

1. Запустите приложение
2. Смените язык в настройках
3. Проверьте все диалоги
4. Проверьте все экраны с ошибками
5. Проверьте все кнопки
6. Убедитесь, что все тексты переводятся

---

**Автор:** Сеньор разработчик  
**Дата:** 10.10.2025

