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
