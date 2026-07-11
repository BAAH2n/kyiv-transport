# parse_realtime.py — конвертує зібрані .pb (GTFS-Realtime) у один CSV
# Використання:
#   pip install gtfs-realtime-bindings pandas
#   python scripts/parse_realtime.py
# Результат: data/processed/realtime_positions.csv
# Перевірено на реальному фіді Києва 11.07.2026 (413 ТЗ у знімку).
# Код згенеровано з допомогою Claude (Anthropic), допрацьовано командою.

import glob, os
import pandas as pd
from google.transit import gtfs_realtime_pb2

RT_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "raw", "rt")
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "processed", "realtime_positions.csv")

rows = []
files = sorted(glob.glob(os.path.join(RT_DIR, "*.pb")))
print(f"Файлів для обробки: {len(files)}")

for path in files:
    feed = gtfs_realtime_pb2.FeedMessage()
    try:
        with open(path, "rb") as f:
            feed.ParseFromString(f.read())
    except Exception as e:
        print(f"  пропускаю {os.path.basename(path)}: {e}")
        continue
    for ent in feed.entity:
        v = ent.vehicle
        rows.append({
            "snapshot_file": os.path.basename(path),
            "route_id": v.trip.route_id,
            "trip_id": v.trip.trip_id,
            "vehicle_id": v.vehicle.id,
            "lat": v.position.latitude,
            "lon": v.position.longitude,
            "bearing": v.position.bearing,
            "speed": v.position.speed,
            "timestamp": v.timestamp,   # unix time, секунди
        })

df = pd.DataFrame(rows)
os.makedirs(os.path.dirname(OUT), exist_ok=True)
df.to_csv(OUT, index=False)
print(f"Записано {len(df)} рядків у {OUT}")
