// Simulated telemetry collector.
// Run with: mongosh --host localhost --port 27018 nosql/telemetry_collector_tick.js

const telemetryDb = db.getSiblingDB("telemetry");
const devices = telemetryDb.devices.find({ active: true }).toArray();

if (devices.length === 0) {
  throw new Error("No active devices found. Run telemetry_schema.js first.");
}

const device = devices[Math.floor(Math.random() * devices.length)];
const now = new Date();
const rawId = `sim-${now.toISOString().replace(/[-:.TZ]/g, "")}-${Math.floor(Math.random() * 10000)}`;

function round(value, decimals) {
  const factor = Math.pow(10, decimals);
  return Math.round(value * factor) / factor;
}

function metricsFor(deviceType) {
  if (deviceType === "transformer") {
    const temperature = round(58 + Math.random() * 20, 1);
    return {
      metrics: {
        temperature_c: temperature,
        load_kw: round(760 + Math.random() * 240, 1),
        voltage_v: Math.round(19800 + Math.random() * 500)
      },
      status: temperature >= 70 ? "warning" : "ok",
      alertRule: temperature >= 70 ? "transformer_temperature_high" : null
    };
  }

  if (deviceType === "solar_inverter") {
    return {
      metrics: {
        power_kw: round(90 + Math.random() * 90, 1),
        panel_temp_c: round(32 + Math.random() * 18, 1),
        irradiance_wm2: Math.round(420 + Math.random() * 360)
      },
      status: "ok",
      alertRule: null
    };
  }

  if (deviceType === "smart_meter") {
    const consumption = round(2.5 + Math.random() * 5.5, 1);
    return {
      metrics: {
        consumption_kw: consumption,
        voltage_v: Math.round(220 + Math.random() * 14),
        current_a: round(consumption * 4.4, 1)
      },
      status: consumption >= 6.5 ? "warning" : "ok",
      alertRule: consumption >= 6.5 ? "consumption_spike" : null
    };
  }

  if (deviceType === "air_quality_station") {
    const pm25 = Math.round(12 + Math.random() * 35);
    return {
      metrics: {
        temperature_c: round(18 + Math.random() * 8, 1),
        humidity_pct: Math.round(48 + Math.random() * 24),
        pm25_ugm3: pm25
      },
      status: pm25 >= 35 ? "warning" : "ok",
      alertRule: pm25 >= 35 ? "pm25_high" : null
    };
  }

  return {
    metrics: {
      temperature_c: round(21 + Math.random() * 10, 1),
      wind_kmh: Math.round(5 + Math.random() * 35),
      humidity_pct: Math.round(45 + Math.random() * 35)
    },
    status: "ok",
    alertRule: null
  };
}

const generated = metricsFor(device.device_type);
const rawDoc = {
  raw_id: rawId,
  received_at: now,
  source: "simulated_collector",
  payload: {
    device_id: device.device_id,
    ts: now,
    metrics: generated.metrics,
    status: generated.status,
    firmware: "2.0.0"
  }
};

telemetryDb.readings_raw.insertOne(rawDoc);
telemetryDb.readings_curated.insertOne({
  raw_id: rawDoc.raw_id,
  device_id: device.device_id,
  device_type: device.device_type,
  site: device.site,
  region: device.region,
  ts: now,
  metrics: generated.metrics,
  status: generated.status,
  quality: {
    valid: true,
    reason: "simulated"
  },
  ingestion: {
    source: rawDoc.source,
    received_at: rawDoc.received_at
  }
});

let insertedAlert = false;
if (generated.alertRule !== null) {
  telemetryDb.alerts.insertOne({
    alert_id: `AL-${rawId}`,
    device_id: device.device_id,
    ts: now,
    severity: "warning",
    rule: generated.alertRule,
    message: `Simulated alert for ${device.device_id}`
  });
  insertedAlert = true;
}

telemetryDb.collector_runs.insertOne({
  run_id: rawId,
  started_at: now,
  completed_at: new Date(),
  inserted_raw: 1,
  inserted_curated: 1,
  inserted_alerts: insertedAlert ? 1 : 0,
  status: "completed"
});

printjson({
  inserted_raw: rawId,
  device_id: device.device_id,
  status: generated.status,
  alert: insertedAlert
});
