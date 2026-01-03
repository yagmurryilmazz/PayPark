import { Router, Request, Response } from "express";
import requireAuth from "../middleware/requireAuth";
import pool from "../db";
import { randomUUID } from "crypto";

const router = Router();

router.get("/me", requireAuth, async (req: Request, res: Response) => {
  const userId = (req as any).user?.id;
  if (!userId) return res.status(401).json({ ok: false, error: "unauthorized" });

  const q = `
    select
      r.id,
      r.user_id,
      r.park_id,
      r.start_time,
      r.end_time,
      r.total_price,
      r.status,
      r.created_at,
      r.tc_no,
      r.plate,
      p.title as park_title,
      p.city as park_city
    from reservations r
    join parks p on p.id = r.park_id
    where r.user_id = $1
    order by r.created_at desc
  `;

  const { rows } = await pool.query(q, [userId]);
  return res.json({ ok: true, items: rows });
});


router.post("/", requireAuth, async (req: Request, res: Response) => {
  const userId = (req as any).user?.id;
  if (!userId) return res.status(401).json({ ok: false, error: "unauthorized" });

  const { park_id, start_time, end_time, tc_no, plate } = req.body ?? {};
  if (!park_id || !start_time || !end_time) {
    return res.status(400).json({ ok: false, error: "park_id,start_time,end_time required" });
  }


  const totalPrice = 80;

  const id = randomUUID();

  const q = `
    insert into reservations
      (id, user_id, park_id, start_time, end_time, total_price, status, tc_no, plate, created_at)
    values
      ($1, $2, $3, $4, $5, $6, 'confirmed', $7, $8, now())
    returning *
  `;

  const { rows } = await pool.query(q, [
    id,
    userId,
    park_id,
    start_time,
    end_time,
    totalPrice,
    tc_no ?? null,
    plate ?? null,
  ]);

  return res.json({ ok: true, reservation: rows[0] });
});


router.patch("/:id/cancel", requireAuth, async (req: Request, res: Response) => {
  const userId = (req as any).user?.id;
  if (!userId) return res.status(401).json({ ok: false, error: "unauthorized" });

  const id = String(req.params.id || "").trim();
  if (!id) return res.status(400).json({ ok: false, error: "id required" });

  const q = `
    update reservations
    set status = 'cancelled'
    where id = $1 and user_id = $2
    returning id, status
  `;

  const { rows } = await pool.query(q, [id, userId]);
  if (!rows.length) return res.status(404).json({ ok: false, error: "reservation not found" });

  return res.json({ ok: true, reservation: rows[0] });
});



router.post("/:id/exit", requireAuth, async (req: Request, res: Response) => {
  const userId = (req as any).user?.id;
  if (!userId) return res.status(401).json({ ok: false, error: "unauthorized" });

  const id = String(req.params.id || "").trim();
  if (!id) return res.status(400).json({ ok: false, error: "id required" });


  const method = req.body?.method ?? null; 

  const client = await pool.connect();
  try {
    await client.query("begin");

   
    const r0 = await client.query(
      `select id, user_id, status, total_price from reservations where id=$1 and user_id=$2 for update`,
      [id, userId]
    );
    if (!r0.rows.length) {
      await client.query("rollback");
      return res.status(404).json({ ok: false, error: "reservation not found" });
    }

    const reservation = r0.rows[0];
    const status = String(reservation.status || "");
    if (status === "cancelled") {
      await client.query("rollback");
      return res.status(400).json({ ok: false, error: "reservation cancelled" });
    }

    const amount = Number(reservation.total_price ?? 0);
    const paymentId = randomUUID();

    
    await client.query(
      `
      insert into payments (id, reservation_id, user_id, amount, currency, status, brand, last4, holder, created_at)
      values ($1, $2, $3, $4, 'TRY', 'succeeded', $5, $6, $7, now())
      `,
      [
        paymentId,
        id,
        userId,
        amount,
        method?.brand ?? null,
        method?.last4 ?? null,
        method?.holder ?? null,
      ]
    );

    
    await client.query(
      `
      update reservations
      set status='completed',
          exited_at = now(),
          paid_at = now(),
          paid_amount = $2,
          payment_id = $3
      where id=$1 and user_id=$4
      `,
      [id, amount, paymentId, userId]
    );

    await client.query("commit");

    return res.json({
      ok: true,
      payment: { id: paymentId, amount, currency: "TRY" },
      reservation: { id, status: "completed" },
    });
  } catch (e: any) {
    await client.query("rollback");
    return res.status(500).json({ ok: false, error: String(e?.message ?? e) });
  } finally {
    client.release();
  }
});

export default router;
