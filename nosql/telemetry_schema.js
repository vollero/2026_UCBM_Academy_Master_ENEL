// Relational Databases & SQL - NoSQL telemetry case study
// Run with: mongosh --host localhost --port 27018 nosql/telemetry_schema.js

const telemetryDb = db.getSiblingDB("telemetry");
telemetryDb.dropDatabase();

telemetryDb.createCollection("devices", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["device_id", "device_type", "site", "region", "active"],
      properties: {
        device_id: { bsonType: "string" },
        device_type: { bsonType: "string" },
        site: { bsonType: "string" },
        region: { bsonType: "string" },
        active: { bsonType: "bool" },
        tags: { bsonType: "array" }
      }
    }
  }
});

telemetryDb.createCollection("readings_raw");
telemetryDb.createCollection("readings_curated");
telemetryDb.createCollection("alerts");
telemetryDb.createCollection("collector_runs");

telemetryDb.devices.insertMany([
  {
    device_id: "TR-roma-001",
    device_type: "transformer",
    site: "Roma Nord",
    region: "center",
    active: true,
    sampling_seconds: 60,
    tags: ["energy", "substation", "critical"]
  },
  {
    device_id: "INV-bari-002",
    device_type: "solar_inverter",
    site: "Bari Solar",
    region: "south",
    active: true,
    sampling_seconds: 60,
    tags: ["energy", "renewable"]
  },
  {
    device_id: "MTR-milano-003",
    device_type: "smart_meter",
    site: "Milano Urban",
    region: "north",
    active: true,
    sampling_seconds: 300,
    tags: ["energy", "metering"]
  },
  {
    device_id: "ENV-torino-004",
    device_type: "air_quality_station",
    site: "Torino Park",
    region: "north",
    active: true,
    sampling_seconds: 120,
    tags: ["environment", "air_quality"]
  },
  {
    device_id: "WTH-catania-005",
    device_type: "weather_station",
    site: "Catania Coast",
    region: "islands",
    active: true,
    sampling_seconds: 180,
    tags: ["environment", "weather"]
  }
]);

const seedReadings = [
  ["TR-roma-001", "2026-05-13T08:00:00Z", { temperature_c: 64.2, load_kw: 820, voltage_v: 20100 }, "ok"],
  ["TR-roma-001", "2026-05-13T08:05:00Z", { temperature_c: 65.1, load_kw: 845, voltage_v: 20080 }, "ok"],
  ["TR-roma-001", "2026-05-13T08:10:00Z", { temperature_c: 71.4, load_kw: 910, voltage_v: 19950 }, "warning"],
  ["TR-roma-001", "2026-05-13T08:15:00Z", { temperature_c: 73.8, load_kw: 935, voltage_v: 19890 }, "warning"],
  ["INV-bari-002", "2026-05-13T08:00:00Z", { power_kw: 120, panel_temp_c: 36.5, irradiance_wm2: 510 }, "ok"],
  ["INV-bari-002", "2026-05-13T08:05:00Z", { power_kw: 132, panel_temp_c: 38.0, irradiance_wm2: 560 }, "ok"],
  ["INV-bari-002", "2026-05-13T08:10:00Z", { power_kw: 148, panel_temp_c: 41.2, irradiance_wm2: 620 }, "ok"],
  ["MTR-milano-003", "2026-05-13T08:00:00Z", { consumption_kw: 3.2, voltage_v: 229, current_a: 14.1 }, "ok"],
  ["MTR-milano-003", "2026-05-13T08:05:00Z", { consumption_kw: 3.4, voltage_v: 228, current_a: 14.8 }, "ok"],
  ["MTR-milano-003", "2026-05-13T08:10:00Z", { consumption_kw: 6.8, voltage_v: 224, current_a: 30.3 }, "warning"],
  ["ENV-torino-004", "2026-05-13T08:00:00Z", { temperature_c: 19.4, humidity_pct: 62, pm25_ugm3: 14 }, "ok"],
  ["ENV-torino-004", "2026-05-13T08:05:00Z", { temperature_c: 19.8, humidity_pct: 61, pm25_ugm3: 18 }, "ok"],
  ["ENV-torino-004", "2026-05-13T08:10:00Z", { temperature_c: 20.1, humidity_pct: 60, pm25_ugm3: 37 }, "warning"],
  ["WTH-catania-005", "2026-05-13T08:00:00Z", { temperature_c: 24.1, wind_kmh: 16, humidity_pct: 55 }, "ok"],
  ["WTH-catania-005", "2026-05-13T08:05:00Z", { temperature_c: 24.4, wind_kmh: 18, humidity_pct: 54 }, "ok"],
  ["WTH-catania-005", "2026-05-13T08:10:00Z", { temperature_c: 25.0, wind_kmh: 31, humidity_pct: 52 }, "warning"]
];

const deviceById = Object.fromEntries(
  telemetryDb.devices.find().toArray().map((device) => [device.device_id, device])
);

const rawDocs = seedReadings.map(([deviceId, ts, metrics, status], index) => ({
  raw_id: `seed-${index + 1}`,
  received_at: new Date(new Date(ts).getTime() + 2000),
  source: "seed_loader",
  payload: {
    device_id: deviceId,
    ts: new Date(ts),
    metrics,
    status,
    firmware: index % 3 === 0 ? "1.9.0" : "1.8.4"
  }
}));

telemetryDb.readings_raw.insertMany(rawDocs);

telemetryDb.readings_curated.insertMany(rawDocs.map((raw) => {
  const device = deviceById[raw.payload.device_id];
  return {
    raw_id: raw.raw_id,
    device_id: raw.payload.device_id,
    device_type: device.device_type,
    site: device.site,
    region: device.region,
    ts: raw.payload.ts,
    metrics: raw.payload.metrics,
    status: raw.payload.status,
    quality: {
      valid: true,
      reason: "seeded"
    },
    ingestion: {
      source: raw.source,
      received_at: raw.received_at
    }
  };
}));

telemetryDb.alerts.insertMany([
  {
    alert_id: "AL-001",
    device_id: "TR-roma-001",
    ts: new Date("2026-05-13T08:10:00Z"),
    severity: "warning",
    rule: "transformer_temperature_high",
    message: "Transformer temperature above 70 C"
  },
  {
    alert_id: "AL-002",
    device_id: "ENV-torino-004",
    ts: new Date("2026-05-13T08:10:00Z"),
    severity: "warning",
    rule: "pm25_high",
    message: "PM2.5 above monitoring threshold"
  },
  {
    alert_id: "AL-003",
    device_id: "MTR-milano-003",
    ts: new Date("2026-05-13T08:10:00Z"),
    severity: "warning",
    rule: "consumption_spike",
    message: "Smart meter consumption spike"
  }
]);

telemetryDb.collector_runs.insertOne({
  run_id: "seed-load",
  started_at: new Date("2026-05-13T08:00:00Z"),
  completed_at: new Date("2026-05-13T08:00:03Z"),
  inserted_raw: rawDocs.length,
  inserted_curated: rawDocs.length,
  status: "completed"
});

telemetryDb.devices.createIndex({ device_id: 1 }, { unique: true });
telemetryDb.readings_raw.createIndex({ "payload.device_id": 1, "payload.ts": -1 });
telemetryDb.readings_curated.createIndex({ device_id: 1, ts: -1 });
telemetryDb.readings_curated.createIndex({ device_type: 1, ts: -1 });
telemetryDb.readings_curated.createIndex({ region: 1, ts: -1 });
telemetryDb.alerts.createIndex({ device_id: 1, ts: -1 });
telemetryDb.alerts.createIndex({ severity: 1, ts: -1 });

print("Telemetry database initialized");
printjson({
  devices: telemetryDb.devices.countDocuments(),
  raw: telemetryDb.readings_raw.countDocuments(),
  curated: telemetryDb.readings_curated.countDocuments(),
  alerts: telemetryDb.alerts.countDocuments()
});
