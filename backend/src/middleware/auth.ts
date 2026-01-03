import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

export type AuthRequest = Request & { user?: { id: string; email: string } };

export function requireAuth(req: AuthRequest, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    return res.status(401).json({ ok: false, error: "Missing token" });
  }

  const token = header.substring("Bearer ".length).trim();
  try {
    const secret = process.env.JWT_SECRET;
    if (!secret) return res.status(500).json({ ok: false, error: "JWT_SECRET missing" });

    const payload = jwt.verify(token, secret) as any;
    req.user = { id: payload.id, email: payload.email };
    next();
  } catch {
    return res.status(401).json({ ok: false, error: "Invalid token" });
  }
}
