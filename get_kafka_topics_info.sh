#!/bin/bash

# Указываем ID кластера Kafka
CLUSTER_ID="xxxxxxxxxxxxxxx"

# Указываем имя файла для сохранения информации
OUTPUT_FILE="kafka_topics_info.txt"

# Очищаем файл, если он уже существует
> "$OUTPUT_FILE"

# Получаем список всех топиков
TOPICS=$(yc managed-kafka topic list --cluster-id "$CLUSTER_ID" --format json | jq -r '.[].name')

# Для каждого топика получаем подробную информацию и записываем в файл
for TOPIC in $TOPICS; do
  echo "Getting info for topic: $TOPIC"
  yc managed-kafka topic get --cluster-id "$CLUSTER_ID" "$TOPIC" >> "$OUTPUT_FILE"
  echo -e "\n" >> "$OUTPUT_FILE"
done

echo "All topics information has been saved to $OUTPUT_FILE"
