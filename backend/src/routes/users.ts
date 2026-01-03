import { Router } from "express";
import { pool } from "../db";
import requireAuth, { AuthedRequest } from "../middleware/requireAuth";

export const usersRouter = Router();

// GET /users/me
usersRouter.get("/me", requireAuth, async (req: AuthedRequest, res) => {
  const userId = req.userId ?? req.user?.id;
  if (!userId) return res.status(401).json({ ok: false, error: "unauthorized" });

  const { rows } = await pool.query(
    `
    select
      id,
      email,
      full_name,
      phone,
      avatar_url,
      role
    from users
    where id = $1
    limit 1
    `,
    [userId]
  );

  if (!rows[0]) return res.status(404).json({ ok: false, error: "not_found" });
  return res.json({ ok: true, user: rows[0] });
});

export default usersRouter;
