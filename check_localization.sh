#!/bin/bash

# Скрипт проверки локализации для Mind Space
# Автор: Сеньор разработчик
# Дата: 10.10.2025

echo "🔍 Проверка локализации в проекте Mind Space..."
echo "================================================"
echo ""

# Счетчики
russian_hardcoded=0
english_hardcoded=0
const_text_russian=0
total_issues=0

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Проверка русских хардкодных строк
echo "1️⃣  Поиск хардкодных строк на русском языке..."
russian_results=$(grep -r "Text('[А-Яа-я]" lib/ 2>/dev/null | wc -l)
if [ "$russian_results" -gt 0 ]; then
    echo -e "${RED}❌ Найдено $russian_results хардкодных строк на русском${NC}"
    echo "   Примеры:"
    grep -r "Text('[А-Яа-я]" lib/ 2>/dev/null | head -5
    echo ""
    russian_hardcoded=$russian_results
    total_issues=$((total_issues + russian_results))
else
    echo -e "${GREEN}✅ Хардкодных строк на русском не найдено${NC}"
fi
echo ""

# 2. Проверка английских хардкодных строк без .tr()
echo "2️⃣  Поиск хардкодных строк на английском без .tr()..."
english_results=$(grep -r "Text('[A-Za-z]" lib/ 2>/dev/null | grep -v "\.tr()" | grep -v "// " | wc -l)
if [ "$english_results" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Найдено $english_results возможных хардкодных строк на английском${NC}"
    echo "   (Требуется ручная проверка, могут быть ложные срабатывания)"
    echo "   Примеры:"
    grep -r "Text('[A-Za-z]" lib/ 2>/dev/null | grep -v "\.tr()" | grep -v "// " | head -5
    echo ""
    english_hardcoded=$english_results
    # Не добавляем в total_issues, так как нужна ручная проверка
else
    echo -e "${GREEN}✅ Подозрительных строк на английском не найдено${NC}"
fi
echo ""

# 3. Проверка const Text с русскими символами
echo "3️⃣  Поиск const Text с русскими символами..."
const_results=$(grep -r "const Text('[А-Яа-я]" lib/ 2>/dev/null | wc -l)
if [ "$const_results" -gt 0 ]; then
    echo -e "${RED}❌ Найдено $const_results const Text с русскими символами${NC}"
    echo "   (const Text нельзя использовать с .tr())"
    echo "   Примеры:"
    grep -r "const Text('[А-Яа-я]" lib/ 2>/dev/null | head -5
    echo ""
    const_text_russian=$const_results
    total_issues=$((total_issues + const_results))
else
    echo -e "${GREEN}✅ const Text с русскими символами не найдено${NC}"
fi
echo ""

# 4. Проверка label: const Text
echo "4️⃣  Поиск label: const Text с русскими символами..."
label_results=$(grep -r "label: const Text('[А-Яа-я]" lib/ 2>/dev/null | wc -l)
if [ "$label_results" -gt 0 ]; then
    echo -e "${RED}❌ Найдено $label_results label: const Text с русскими символами${NC}"
    echo "   Примеры:"
    grep -r "label: const Text('[А-Яа-я]" lib/ 2>/dev/null | head -3
    echo ""
    total_issues=$((total_issues + label_results))
else
    echo -e "${GREEN}✅ label: const Text с русскими символами не найдено${NC}"
fi
echo ""

# 5. Проверка child: const Text
echo "5️⃣  Поиск child: const Text с русскими символами..."
child_results=$(grep -r "child: const Text('[А-Яа-я]" lib/ 2>/dev/null | wc -l)
if [ "$child_results" -gt 0 ]; then
    echo -e "${RED}❌ Найдено $child_results child: const Text с русскими символами${NC}"
    echo "   Примеры:"
    grep -r "child: const Text('[А-Яа-я]" lib/ 2>/dev/null | head -3
    echo ""
    total_issues=$((total_issues + child_results))
else
    echo -e "${GREEN}✅ child: const Text с русскими символами не найдено${NC}"
fi
echo ""

# 6. Проверка title: const Text
echo "6️⃣  Поиск title: const Text с русскими символами..."
title_results=$(grep -r "title: const Text('[А-Яа-я]" lib/ 2>/dev/null | wc -l)
if [ "$title_results" -gt 0 ]; then
    echo -e "${RED}❌ Найдено $title_results title: const Text с русскими символами${NC}"
    echo "   Примеры:"
    grep -r "title: const Text('[А-Яа-я]" lib/ 2>/dev/null | head -3
    echo ""
    total_issues=$((total_issues + title_results))
else
    echo -e "${GREEN}✅ title: const Text с русскими символами не найдено${NC}"
fi
echo ""

# 7. Проверка showSnackBar с хардкодом
echo "7️⃣  Поиск showSnackBar с хардкодными строками..."
snackbar_results=$(grep -r "showSnackBar.*Text('[А-Яа-я]" lib/ 2>/dev/null | wc -l)
if [ "$snackbar_results" -gt 0 ]; then
    echo -e "${RED}❌ Найдено $snackbar_results showSnackBar с хардкодными строками${NC}"
    echo "   Примеры:"
    grep -r "showSnackBar.*Text('[А-Яа-я]" lib/ 2>/dev/null | head -3
    echo ""
    total_issues=$((total_issues + snackbar_results))
else
    echo -e "${GREEN}✅ showSnackBar с хардкодом не найдено${NC}"
fi
echo ""

# Итоговый отчет
echo "================================================"
echo "📊 ИТОГОВЫЙ ОТЧЕТ:"
echo "================================================"
echo ""
echo "Критические проблемы (требуют исправления):"
echo "  - Хардкодные строки на русском:     $russian_hardcoded"
echo "  - const Text с русскими символами:  $const_text_russian"
echo ""
echo "Предупреждения (требуют проверки):"
echo "  - Возможные хардкодные строки (eng): $english_hardcoded"
echo ""
echo "Всего критических проблем:            $total_issues"
echo ""

# Финальная оценка
if [ "$total_issues" -eq 0 ]; then
    echo -e "${GREEN}✅✅✅ ОТЛИЧНО! Критических проблем локализации не найдено!${NC}"
    echo ""
    exit 0
elif [ "$total_issues" -lt 10 ]; then
    echo -e "${YELLOW}⚠️  ХОРОШО, но есть $total_issues проблем. Рекомендуется исправить.${NC}"
    echo ""
    exit 1
elif [ "$total_issues" -lt 50 ]; then
    echo -e "${RED}❌ ПЛОХО! Найдено $total_issues проблем локализации. Требуется исправление!${NC}"
    echo ""
    exit 1
else
    echo -e "${RED}❌❌❌ КРИТИЧНО! Найдено $total_issues проблем локализации! СРОЧНО исправить!${NC}"
    echo ""
    exit 1
fi

