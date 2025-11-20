# Скрипт проверки локализации для Mind Space (PowerShell)
# Автор: Сеньор разработчик
# Дата: 10.10.2025

Write-Host "🔍 Проверка локализации в проекте Mind Space..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Счетчики
$russian_hardcoded = 0
$english_hardcoded = 0
$const_text_russian = 0
$total_issues = 0

# 1. Проверка русских хардкодных строк
Write-Host "1️⃣  Поиск хардкодных строк на русском языке..." -ForegroundColor Yellow
$russian_results = Select-String -Path "lib\**\*.dart" -Pattern "Text\([""'][А-Яа-я]" -ErrorAction SilentlyContinue
if ($russian_results) {
    $russian_hardcoded = $russian_results.Count
    Write-Host "❌ Найдено $russian_hardcoded хардкодных строк на русском" -ForegroundColor Red
    Write-Host "   Примеры:" -ForegroundColor Red
    $russian_results | Select-Object -First 5 | ForEach-Object {
        Write-Host "   $($_.Path):$($_.LineNumber) - $($_.Line.Trim())" -ForegroundColor Gray
    }
    Write-Host ""
    $total_issues += $russian_hardcoded
} else {
    Write-Host "✅ Хардкодных строк на русском не найдено" -ForegroundColor Green
}
Write-Host ""

# 2. Проверка английских хардкодных строк без .tr()
Write-Host "2️⃣  Поиск хардкодных строк на английском без .tr()..." -ForegroundColor Yellow
$english_results = Select-String -Path "lib\**\*.dart" -Pattern "Text\([""'][A-Za-z]" -ErrorAction SilentlyContinue | Where-Object { $_.Line -notmatch "\.tr\(\)" -and $_.Line -notmatch "// " }
if ($english_results) {
    $english_hardcoded = $english_results.Count
    Write-Host "⚠️  Найдено $english_hardcoded возможных хардкодных строк на английском" -ForegroundColor Yellow
    Write-Host "   (Требуется ручная проверка, могут быть ложные срабатывания)" -ForegroundColor Yellow
    Write-Host "   Примеры:" -ForegroundColor Yellow
    $english_results | Select-Object -First 5 | ForEach-Object {
        Write-Host "   $($_.Path):$($_.LineNumber) - $($_.Line.Trim())" -ForegroundColor Gray
    }
    Write-Host ""
} else {
    Write-Host "✅ Подозрительных строк на английском не найдено" -ForegroundColor Green
}
Write-Host ""

# 3. Проверка const Text с русскими символами
Write-Host "3️⃣  Поиск const Text с русскими символами..." -ForegroundColor Yellow
$const_results = Select-String -Path "lib\**\*.dart" -Pattern "const Text\([""'][А-Яа-я]" -ErrorAction SilentlyContinue
if ($const_results) {
    $const_text_russian = $const_results.Count
    Write-Host "❌ Найдено $const_text_russian const Text с русскими символами" -ForegroundColor Red
    Write-Host "   (const Text нельзя использовать с .tr())" -ForegroundColor Red
    Write-Host "   Примеры:" -ForegroundColor Red
    $const_results | Select-Object -First 5 | ForEach-Object {
        Write-Host "   $($_.Path):$($_.LineNumber) - $($_.Line.Trim())" -ForegroundColor Gray
    }
    Write-Host ""
    $total_issues += $const_text_russian
} else {
    Write-Host "✅ const Text с русскими символами не найдено" -ForegroundColor Green
}
Write-Host ""

# 4. Проверка label: const Text
Write-Host "4️⃣  Поиск label: const Text с русскими символами..." -ForegroundColor Yellow
$label_results = Select-String -Path "lib\**\*.dart" -Pattern "label: const Text\([""'][А-Яа-я]" -ErrorAction SilentlyContinue
if ($label_results) {
    $label_count = $label_results.Count
    Write-Host "❌ Найдено $label_count label: const Text с русскими символами" -ForegroundColor Red
    Write-Host "   Примеры:" -ForegroundColor Red
    $label_results | Select-Object -First 3 | ForEach-Object {
        Write-Host "   $($_.Path):$($_.LineNumber) - $($_.Line.Trim())" -ForegroundColor Gray
    }
    Write-Host ""
    $total_issues += $label_count
} else {
    Write-Host "✅ label: const Text с русскими символами не найдено" -ForegroundColor Green
}
Write-Host ""

# 5. Проверка child: const Text
Write-Host "5️⃣  Поиск child: const Text с русскими символами..." -ForegroundColor Yellow
$child_results = Select-String -Path "lib\**\*.dart" -Pattern "child: const Text\([""'][А-Яа-я]" -ErrorAction SilentlyContinue
if ($child_results) {
    $child_count = $child_results.Count
    Write-Host "❌ Найдено $child_count child: const Text с русскими символами" -ForegroundColor Red
    Write-Host "   Примеры:" -ForegroundColor Red
    $child_results | Select-Object -First 3 | ForEach-Object {
        Write-Host "   $($_.Path):$($_.LineNumber) - $($_.Line.Trim())" -ForegroundColor Gray
    }
    Write-Host ""
    $total_issues += $child_count
} else {
    Write-Host "✅ child: const Text с русскими символами не найдено" -ForegroundColor Green
}
Write-Host ""

# 6. Проверка title: const Text
Write-Host "6️⃣  Поиск title: const Text с русскими символами..." -ForegroundColor Yellow
$title_results = Select-String -Path "lib\**\*.dart" -Pattern "title: const Text\([""'][А-Яа-я]" -ErrorAction SilentlyContinue
if ($title_results) {
    $title_count = $title_results.Count
    Write-Host "❌ Найдено $title_count title: const Text с русскими символами" -ForegroundColor Red
    Write-Host "   Примеры:" -ForegroundColor Red
    $title_results | Select-Object -First 3 | ForEach-Object {
        Write-Host "   $($_.Path):$($_.LineNumber) - $($_.Line.Trim())" -ForegroundColor Gray
    }
    Write-Host ""
    $total_issues += $title_count
} else {
    Write-Host "✅ title: const Text с русскими символами не найдено" -ForegroundColor Green
}
Write-Host ""

# Итоговый отчет
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📊 ИТОГОВЫЙ ОТЧЕТ:" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Критические проблемы (требуют исправления):"
Write-Host "  - Хардкодные строки на русском:     $russian_hardcoded"
Write-Host "  - const Text с русскими символами:  $const_text_russian"
Write-Host ""
Write-Host "Предупреждения (требуют проверки):"
Write-Host "  - Возможные хардкодные строки (eng): $english_hardcoded"
Write-Host ""
Write-Host "Всего критических проблем:            $total_issues"
Write-Host ""

# Финальная оценка
if ($total_issues -eq 0) {
    Write-Host "✅✅✅ ОТЛИЧНО! Критических проблем локализации не найдено!" -ForegroundColor Green
    Write-Host ""
    exit 0
} elseif ($total_issues -lt 10) {
    Write-Host "⚠️  ХОРОШО, но есть $total_issues проблем. Рекомендуется исправить." -ForegroundColor Yellow
    Write-Host ""
    exit 1
} elseif ($total_issues -lt 50) {
    Write-Host "❌ ПЛОХО! Найдено $total_issues проблем локализации. Требуется исправление!" -ForegroundColor Red
    Write-Host ""
    exit 1
} else {
    Write-Host "❌❌❌ КРИТИЧНО! Найдено $total_issues проблем локализации! СРОЧНО исправить!" -ForegroundColor Red
    Write-Host ""
    exit 1
}


