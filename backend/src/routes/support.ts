import { Router, Request, Response } from "express";
import requireAuth from "../middleware/requireAuth";

const router = Router();


const normalizeTR = (s: string) => {
  const t = (s ?? "").toLocaleLowerCase("tr-TR").trim();
  const map: Record<string, string> = {
    "ç": "c",
    "ğ": "g",
    "ı": "i",
    "ö": "o",
    "ş": "s",
    "ü": "u",
  };
  return t.replace(/[çğıöşü]/g, (m) => map[m] ?? m);
};

const isPayParkRelated = (q: string) => {
  const t = normalizeTR(q);
  const keywords = [
    "paypark",
    "park",
    "otopark",
    "rezervasyon",
    "yakin",
    "yakın",
    "harita",
    "konum",
    "odeme",
    "ödeme",
    "kart",
    "iade",
    "iptal",
    "hesap",
    "profil",
    "giris",
    "giriş",
    "kayit",
    "kayıt",
    "plaka",
    "tc",
    "fatura",
    "ucret",
    "ücret",
    "dakika",
    "saat",
  ];
  return keywords.some((k) => t.includes(normalizeTR(k)));
};

function makeCode(len = 8) {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let out = "";
  for (let i = 0; i < len; i++) out += chars[Math.floor(Math.random() * chars.length)];
  return out;
}


function offlineSupportAnswer(msgRaw: string) {
  const msg = normalizeTR(msgRaw);

  if (msg.includes("odeme") || msg.includes("ödeme") || msg.includes("kart")) {
    return (
      "Ödeme genelde rezervasyon onaylandığında çekilir. Bankaya yansıması 1–3 iş günü sürebilir.\n" +
      "• Ödeme başarısızsa: kart limitinizi/3D Secure’u kontrol edin ve tekrar deneyin.\n" +
      "• Çift çekim görünüyorsa: biri provizyon olabilir, 24 saat içinde düşmezse destek koduyla bize yazın."
    );
  }

  if (msg.includes("rezervasyon") || msg.includes("iptal") || msg.includes("iade")) {
    return (
      "Rezervasyon işlemleri:\n" +
      "• Oluşturma: Otoparkı seç → başlangıç/bitiş saatini seç → onayla.\n" +
      "• İptal: Rezervasyonlarım → rezervasyonu aç → İptal.\n" +
      "• İade: İptal sonrası bankaya göre 1–3 iş günü sürebilir."
    );
  }

  if (msg.includes("konum") || msg.includes("yakın") || msg.includes("harita")) {
    return (
      "Yakın otoparklar için konum izni gerekir.\n" +
      "• Telefon Ayarları → Uygulamalar → PayPark → İzinler → Konum: 'İzin ver'\n" +
      "• Emülatördeyseniz: Extended Controls → Location’dan konum seçip 'Set Location' yapın."
    );
  }

  if (msg.includes("giris") || msg.includes("giriş") || msg.includes("kayit") || msg.includes("kayıt")) {
    return (
      "Giriş/Kayıt sorunları:\n" +
      "• E-posta/şifreyi kontrol edin.\n" +
      "• Şifreyi unuttuysanız şifre sıfırlama akışını kullanın.\n" +
      "• Devam ederse ekran görüntüsü + e-posta adresinizle destek kodunu gönderin."
    );
  }

  return (
    "PayPark ile ilgili konularda yardımcı olabilirim (otoparklar, yakın otoparklar, rezervasyon, ödeme, hesap).\n" +
    "Hangi ekranda ne sorun yaşıyorsunuz? Kısaca yazın."
  );
}


async function handle(req: Request, res: Response) {
  const msg = String(req.body?.message ?? req.body?.text ?? req.body?.query ?? "").trim();
  if (!msg) return res.status(400).json({ ok: false, error: "message required" });

  if (!isPayParkRelated(msg)) {
    return res.json({
      ok: true,
      reply:
        "Sadece PayPark ile ilgili soruları yanıtlayabilirim (otoparklar, rezervasyon, ödeme, hesap). PayPark’ta neye ihtiyacınız var?",
      provider: "fallback",
    });
  }

  const code = makeCode(8);

  return res.json({
    ok: true,
    reply: offlineSupportAnswer(msg),
    provider: "fallback",
    supportCode: code,
  });
}


const faq = [
  {
    q: "Rezervasyon ödemem ne zaman gerçekleşir?",
    a: "Ödeme genelde rezervasyon onaylandığında çekilir. Bankaya yansıması 1–3 iş günü sürebilir.",
  },
  {
    q: "Ödeme başarısız oldu, ne yapmalıyım?",
    a: "Kart limitinizi, internet alışverişini ve 3D Secure onayını kontrol edin. Uygulamayı kapatıp açıp tekrar deneyin.",
  },
  {
    q: "Ücret iki kez çekilmiş görünüyor.",
    a: "Biri provizyon olabilir. 24 saat içinde düşmezse destek kodu ile bize yazın.",
  },
  {
    q: "Rezervasyonum görünmüyor / beklemede kaldı.",
    a: "Sayfayı yenileyin. 1–2 dakika içinde gelmezse Canlı Destek’e rezervasyon saatini ve otopark adını yazın.",
  },
  {
    q: "Yakınımdaki otoparklar yanlış çıkıyor.",
    a: "Konum iznini açın. Emülatörde Location’dan konum set ettiğinizden emin olun.",
  },
  {
    q: "Fiyat beklediğimden yüksek geldi.",
    a: "Ücret, saatlik ücret × toplam süreye göre hesaplanır. Bazı otoparklarda yuvarlama kuralı olabilir (park detayında yazar).",
  },
  {
    q: "Rezervasyonu nasıl iptal ederim?",
    a: "Rezervasyonlarım → rezervasyonu aç → İptal.",
  },
  {
    q: "İade ne zaman yansır?",
    a: "Bankaya göre 1–3 iş günü sürebilir.",
  },
];


router.get("/faq", (_req: Request, res: Response) => {
  return res.json({ ok: true, items: faq });
});


router.post("/ticket", requireAuth, (req: Request, res: Response) => {
  const message = typeof req.body?.message === "string" ? req.body.message.trim() : "";
  if (!message) return res.status(400).json({ ok: false, error: "Mesaj boş olamaz." });

  const code = makeCode(8);
  return res.json({
    ok: true,
    ticket: {
      code,
      message,
      status: "alındı",
      created_at: new Date().toISOString(),
    },
  });
});


router.post("/ask", requireAuth, handle);
router.post("/chat", requireAuth, handle);

export default router;
