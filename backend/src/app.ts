import "dotenv/config";

import express from "express";
import cors from "cors";
import { usersRouter } from "./routes/users";
import authRoutes from "./routes/auth";
import parksRoutes from "./routes/parks";
import reservationsRoutes from "./routes/reservations";
import supportRoutes from "./routes/support";
import { pool } from "./db";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (_req, res) => res.json({ ok: true, name: "PayPark API" }));

app.get("/health/db", async (_req, res) => {
  try {
    const r = await pool.query("select now() as now");
    res.json({ ok: true, now: r.rows[0].now });
  } catch (e: any) {
    console.error("DB ERROR:", e);
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

app.use("/auth", authRoutes);
app.use("/parks", parksRoutes);
app.use("/reservations", reservationsRoutes);
app.use("/support", supportRoutes);
app.use("/users", usersRouter);
const port = Number(process.env.PORT) || 3000;
app.listen(port, "0.0.0.0", () => console.log(`API running on http://0.0.0.0:${port}`));
