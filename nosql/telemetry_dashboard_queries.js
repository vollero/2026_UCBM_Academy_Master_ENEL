// Aggregation queries for telemetry dashboard cards.
// Run with: mongosh --host localhost --port 27018 nosql/telemetry_dashboard_queries.js

const telemetryDb = db.getSiblingDB("telemetry");

print("1. KPI sintesi telemetria");
printjson(telemetryDb.readings_curated.aggregate([
  {
    $group: {
      _id: null,
      readings: { $sum: 1 },
      devices: { $addToSet: "$device_id" },
      warnings: {
        $sum: {
          $cond: [{ $eq: ["$status", "warning"] }, 1, 0]
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      readings: 1,
      device_count: { $size: "$devices" },
      warnings: 1
    }
  }
]).toArray());

print("2. Ultima lettura per dispositivo");
printjson(telemetryDb.readings_curated.aggregate([
  { $sort: { device_id: 1, ts: -1 } },
  {
    $group: {
      _id: "$device_id",
      device_type: { $first: "$device_type" },
      site: { $first: "$site" },
      region: { $first: "$region" },
      ts: { $first: "$ts" },
      status: { $first: "$status" },
      metrics: { $first: "$metrics" }
    }
  },
  { $sort: { _id: 1 } }
]).toArray());

print("3. Trend per intervallo di 5 minuti");
printjson(telemetryDb.readings_curated.aggregate([
  {
    $group: {
      _id: {
        bucket: {
          $dateTrunc: {
            date: "$ts",
            unit: "minute",
            binSize: 5
          }
        }
      },
      readings: { $sum: 1 },
      warnings: {
        $sum: {
          $cond: [{ $eq: ["$status", "warning"] }, 1, 0]
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      bucket: "$_id.bucket",
      readings: 1,
      warnings: 1
    }
  },
  { $sort: { bucket: 1 } }
]).toArray());

print("4. Metriche energia per sito");
printjson(telemetryDb.readings_curated.aggregate([
  {
    $match: {
      device_type: { $in: ["transformer", "solar_inverter", "smart_meter"] }
    }
  },
  {
    $group: {
      _id: { site: "$site", device_type: "$device_type" },
      readings: { $sum: 1 },
      avg_temperature_c: { $avg: "$metrics.temperature_c" },
      avg_power_kw: { $avg: "$metrics.power_kw" },
      avg_load_kw: { $avg: "$metrics.load_kw" },
      avg_consumption_kw: { $avg: "$metrics.consumption_kw" }
    }
  },
  { $sort: { "_id.site": 1, "_id.device_type": 1 } }
]).toArray());

print("5. Monitoraggio ambientale");
printjson(telemetryDb.readings_curated.aggregate([
  {
    $match: {
      device_type: { $in: ["air_quality_station", "weather_station"] }
    }
  },
  {
    $group: {
      _id: { site: "$site", region: "$region" },
      readings: { $sum: 1 },
      avg_temperature_c: { $avg: "$metrics.temperature_c" },
      avg_humidity_pct: { $avg: "$metrics.humidity_pct" },
      max_pm25_ugm3: { $max: "$metrics.pm25_ugm3" },
      max_wind_kmh: { $max: "$metrics.wind_kmh" }
    }
  },
  { $sort: { "_id.region": 1, "_id.site": 1 } }
]).toArray());

print("6. Controllo raw-curated");
printjson({
  raw_events: telemetryDb.readings_raw.countDocuments(),
  curated_readings: telemetryDb.readings_curated.countDocuments(),
  raw_without_curated: telemetryDb.readings_raw.aggregate([
    {
      $lookup: {
        from: "readings_curated",
        localField: "raw_id",
        foreignField: "raw_id",
        as: "curated"
      }
    },
    { $match: { curated: { $size: 0 } } },
    { $count: "missing" }
  ]).toArray()
});

print("7. Alert recenti");
printjson(telemetryDb.alerts.find(
  {},
  { _id: 0, alert_id: 1, device_id: 1, ts: 1, severity: 1, rule: 1, message: 1 }
).sort({ ts: -1 }).limit(10).toArray());
