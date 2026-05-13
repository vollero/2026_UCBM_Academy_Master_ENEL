const t = db.getSiblingDB("telemetry");

print("Conteggi collection");
printjson({
  devices: t.devices.countDocuments(),
  raw: t.readings_raw.countDocuments(),
  curated: t.readings_curated.countDocuments(),
  alerts: t.alerts.countDocuments()
});

print("Ultime tre letture curate");
printjson(t.readings_curated.find(
  {},
  { _id: 0, raw_id: 1, device_id: 1, device_type: 1, site: 1, region: 1, ts: 1, metrics: 1, status: 1 }
).sort({ ts: -1 }).limit(3).toArray());

print("Indici su readings_curated");
printjson(t.readings_curated.getIndexes());

print("Controllo raw-curated");
printjson({
  raw_events: t.readings_raw.countDocuments(),
  curated_readings: t.readings_curated.countDocuments(),
  raw_without_curated: t.readings_raw.aggregate([
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
