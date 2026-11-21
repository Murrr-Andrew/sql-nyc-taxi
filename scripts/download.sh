#!/usr/bin/env bash
# Downloads NYC TLC Yellow Taxi trips and the taxi zone lookup into data/raw/.
# Files that already exist are skipped, so the script is safe to run again.
set -euo pipefail

BASE_URL="https://d37ci6vzurychx.cloudfront.net"
MONTHS=("2026-07" "2026-08" "2026-09")

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_DIR="$ROOT_DIR/data/raw"
mkdir -p "$RAW_DIR"

download() {
  local url="$1"
  local target="$2"

  if [ -s "$target" ]; then
    echo "Skip: $(basename "$target") already exists"
    return
  fi

  echo "Download: $(basename "$target")"
  curl --fail --location --retry 3 --silent --show-error --output "$target.part" "$url"
  mv "$target.part" "$target"
}

for month in "${MONTHS[@]}"; do
  file="yellow_tripdata_${month}.parquet"
  download "$BASE_URL/trip-data/$file" "$RAW_DIR/$file"
done

download "$BASE_URL/misc/taxi_zone_lookup.csv" "$RAW_DIR/taxi_zone_lookup.csv"

echo "Done: $RAW_DIR"
