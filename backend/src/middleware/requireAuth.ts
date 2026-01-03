import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

export type AuthedRequest = Request & {
  userId?: string;
  user?: { id: string; email: string };
};

const JWT_SECRET =
  process.env.JWT_SECRET ||
  process.env.AUTH_SECRET ||
  "paypark_dev_secret_123";

export function requireAuth(req: AuthedRequest, res: Response, next: NextFunction) {
  const header = req.headers.authorization;

  if (!header?.startsWith("Bearer ")) {
    return res.status(401).json({ ok: false, error: "Token eksik." });
  }

  const token = header.replace("Bearer ", "").trim();
  if (!token) {
    return res.status(401).json({ ok: false, error: "Token eksik." });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET) as any;

    const id = payload?.id;
    const email = payload?.email;

    if (!id) {
      return res.status(401).json({ ok: false, error: "Geçersiz token." });
    }

    req.userId = String(id);
    if (email) req.user = { id: String(id), email: String(email) };

    return next();
  } catch {
    return res.status(401).json({ ok: false, error: "Geçersiz token." });
  }
}


export default requireAuth;
