import { Router, Request, Response } from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import { pool } from "../db";
import requireAuth, { AuthedRequest } from "../middleware/requireAuth";

const router = Router();

const JWT_SECRET =
  process.env.JWT_SECRET ||
  process.env.AUTH_SECRET ||
  "paypark_dev_secret_123";


// REGISTER
router.post("/register", async (req: Request, res: Response) => {
  const { email, password, fullName } = req.body;

  if (!email || !password) {
    return res.status(400).json({ ok: false, error: "E-posta ve şifre zorunludur." });
  }

  const passwordHash = await bcrypt.hash(String(password), 10);

  try {
    const { rows } = await pool.query(
      `
      insert into users (email, password_hash, full_name)
      values ($1, $2, $3)
      returning id, email
      `,
      [String(email).toLowerCase(), passwordHash, fullName ?? null]
    );

    const user = rows[0];

    const token = jwt.sign(
      { id: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({ ok: true, token });
  } catch (err: any) {
    if (err?.code === "23505") {
      return res.status(400).json({ ok: false, error: "Bu e-posta zaten kayıtlı." });
    }
    return res.status(500).json({ ok: false, error: "Kayıt sırasında hata oluştu." });
  }
});

// LOGIN
router.post("/login", async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ ok: false, error: "E-posta ve şifre zorunludur." });
  }

  try {
    const { rows } = await pool.query(
      `select id, email, password_hash from users where email = $1`,
      [String(email).toLowerCase()]
    );

    if (!rows.length) {
      return res.status(401).json({ ok: false, error: "E-posta veya şifre hatalı." });
    }

    const user = rows[0];
    const valid = await bcrypt.compare(String(password), user.password_hash);

    if (!valid) {
      return res.status(401).json({ ok: false, error: "E-posta veya şifre hatalı." });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    return res.json({ ok: true, token });
  } catch {
    return res.status(500).json({ ok: false, error: "Giriş sırasında hata oluştu." });
  }
});


// GET CURRENT USER
router.get("/me", requireAuth, async (req: AuthedRequest, res: Response) => {
  const userId = req.userId ?? req.user?.id;
  if (!userId) return res.status(401).json({ ok: false, error: "unauthorized" });

  try {
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

    if (!rows[0]) return res.status(404).json({ ok: false, error: "Kullanıcı bulunamadı." });

    return res.json({ ok: true, user: rows[0] });
  } catch {
    return res.status(500).json({ ok: false, error: "Hesap bilgileri alınamadı." });
  }
});

export default router;
