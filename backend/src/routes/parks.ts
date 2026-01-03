import { Router } from "express";
import { pool } from "../db"; 

const router = Router();

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function num(v: any): number | null {
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number) {
  const toRad = (v: number) => (v * Math.PI) / 180;
  const R = 6371; // km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

 
 
router.get("/nearby", async (req, res) => {
  try {
    const radiusKm =
      num(req.query.radius_km) ??
      num(req.query.radiusKm) ??
      num(req.query.radius) ??
      num(req.query.km) ??
      5;

    const userLat = num(req.query.lat);

    
    const userLon = num(req.query.lng) ?? num(req.query.lon);

    if (userLat == null || userLon == null) {
      return res.status(400).json({
        ok: false,
        message: "lat/lng (or lon) is required for nearby",
      });
    }

    const { rows } = await pool.query("select * from parks");

    const items = rows
      .map((p: any) => {
       
        const plat = num(p.lat) ?? num(p.latitude);
        const plon = num(p.lon) ?? num(p.lng) ?? num(p.longitude);

        
        if (plat == null || plon == null) return null;

        const d = haversineKm(userLat, userLon, plat, plon);
        return { ...p, distance_km: d };
      })
      .filter(Boolean)
      .filter((p: any) => p.distance_km <= radiusKm)
      .sort((a: any, b: any) => a.distance_km - b.distance_km);

    return res.json({
      ok: true,
      radius_km: radiusKm,
      request_lat: userLat,
      request_lon: userLon,
      items,
    });
  } catch (e: any) {
    console.error("GET /parks/nearby error:", e);
    return res.status(500).json({ ok: false, message: "Internal error" });
  }
});

router.get("/", async (_req, res) => {
  try {
    const { rows } = await pool.query("select * from parks");
    return res.json({ ok: true, items: rows });
  } catch (e) {
    console.error("GET /parks error:", e);
    return res.status(500).json({ ok: false, message: "Internal error" });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    if (!UUID_RE.test(id)) {
      return res.status(400).json({ ok: false, message: "Invalid park id" });
    }

    const { rows } = await pool.query("select * from parks where id = $1", [id]);
    const item = rows[0];
    if (!item) return res.status(404).json({ ok: false, message: "Not found" });

    return res.json({ ok: true, item });
  } catch (e) {
    console.error("GET /parks/:id error:", e);
    return res.status(500).json({ ok: false, message: "Internal error" });
  }
});

export default router;
