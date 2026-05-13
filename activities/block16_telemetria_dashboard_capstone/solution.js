const t = db.getSiblingDB("telemetry");

print("KPI generale");
printjson(t.readings_curated.aggregate([
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

print("Ultima lettura per dispositivo");
printjson(t.readings_curated.aggregate([
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

print("Trend a bucket di 5 minuti");
printjson(t.readings_curated.aggregate([
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
