import * as dotenv from "dotenv";
dotenv.config();

import { Pool } from "pg";

const conn = process.env.DATABASE_URL;

if (!conn) {
  console.error("❌ DATABASE_URL is missing in backend/.env");
}


const ssl =
  process.env.PGSSL === "false"
    ? undefined
    : { rejectUnauthorized: false };

export const pool = new Pool({
  connectionString: conn,
  ssl,
});


pool.on("error", (err) => {
  console.error("❌ PG Pool Error:", err);
});
