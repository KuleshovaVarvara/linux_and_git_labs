# Лабораторная работа №1. Регулярные выражения и Bash-скрипты

## Задание 1. Регулярные выражения

**Условие:** используя файл `dictionary_2026.txt`, выполнить поиск слов по заданным шаблонам.

<details>
<summary><b>Показать решение</b></summary>

### 1) Подсчитать количество всех слов в словаре

```bash
wc -w < dictionary_2026.txt
```

### 2) Слова, содержащие ровно 2 буквы «с» (без учёта регистра)

```bash
tr -s ' \t' '\n' < dictionary_2026.txt | grep -ic '^[^c]*c[^c]*c[^c]*$'
```

### 3) Слова, содержащие ровно 2 буквы «t», отделённые друг от друга хотя бы одним символом

```bash
tr -s ' \t' '\n' < dictionary_2026.txt | tr 'A-Z' 'a-z' | grep -cE '^[^t]*t[^t]+t[^t]*$'
```

### 4) Наборы из 3-х первых букв, не содержащие смежных «o»

Пример слова «room» — содержит «oo», такие наборы исключаются.

```bash
tr -s ' \t' '\n' < dictionary_2026.txt \
  | grep -ioE '^[a-z]{3}' \
  | grep -v 'oo' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 4 \
  | grep -ioE '[a-z]{3}$'
```

</details>

---

## Задание 2. Bash-скрипт обработки CSV

**Условие:** обработать файл `faculty_2.csv` (список преподавателей и их научных направлений) и сформировать набор отчётов в директории `data_analysis`.

<details>
<summary><b>Показать решение (полный скрипт)</b></summary>

Полный текст скрипта находится в файле [`script.sh`](./script.sh).

```bash
#!/usr/bin/env bash

# Функция: получить список направлений из CSV
# (убирает пробелы, удаляет первые 2 колонки, разбивает по +)
get_themes () {
    sed 's/^ *//; s/ *$//' "$1" \
      | sed 's/^[^,]*,[^,]*,//' \
      | sed 's/ *+ */+/g' \
      | tr '+' '\n' \
      | sed 's/^ *//; s/ *$//'
}

# 0) Создание директории data_analysis
if [ ! -d data_analysis ]
then
    mkdir data_analysis
fi

# 1) research_themes — уникальные темы + их число
get_themes faculty_2.csv | sort | uniq | grep -v '^$' > data_analysis/research_themes
get_themes faculty_2.csv | sort | uniq | wc -l >> data_analysis/research_themes

# 2) medium_groups.txt — направления с числом людей > 6 и < 10
get_themes faculty_2.csv | sort | uniq -c | sed 's/^ *//' > data_analysis/tmp_counts.txt
while read count theme
do
    if [ $count -gt 6 ]
    then
        if [ $count -lt 10 ]
        then
            echo "$theme" >> data_analysis/medium_groups.txt
            cat data_analysis/medium_groups.txt
        fi
    fi
done < data_analysis/tmp_counts.txt
rm data_analysis/tmp_counts.txt

# 3) joined.csv — люди с тремя направлениями одновременно
grep 'Computer Security' faculty_2.csv \
  | grep 'Philosophy' \
  | grep 'Biomed' > data_analysis/joined.csv

# 4) sorted_names.txt — сортировка по фамилии
sed 's/^ *//; s/ *$//; s/,.*//' faculty_2.csv \
  | sed 's/^\(.*\) \([^ ]*\)$/\2 \1/' \
  | sort \
  | sed 's/^\([^ ]*\) \(.*\)$/\2 \1/' > data_analysis/sorted_names.txt
```

### Запуск

```bash
chmod +x script.sh
./script.sh
```

### Результат

После выполнения в директории `data_analysis/` появятся файлы:

- `research_themes` — список уникальных научных направлений и их общее количество;
- `medium_groups.txt` — направления, которые выбрали от 7 до 9 человек;
- `joined.csv` — преподаватели, работающие одновременно по трём направлениям (Computer Security, Philosophy, Biomed);
- `sorted_names.txt` — список имён, отсортированный по фамилии.

</details>
