import 'dart:math';
import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  
  static const Color _brandBlue = Color(0xFF3B82F6);

  // FAQ
  final _faqScrollCtrl = ScrollController();
  final _faqAnswerScrollCtrl = ScrollController();
  int? _selectedFaqIndex;

  // Chat
  final _chatCtrl = TextEditingController();
  final _chatScrollCtrl = ScrollController();

  final List<_ChatMsg> _messages = [
    _ChatMsg(
      fromAgent: true,
      text:
          "Merhaba! Ben PayPark Canlı Destek.\n\nOtoparklar, rezervasyonlar, ödemeler veya hesabınızla ilgili konularda buradan bize ulaşabilirsiniz.",
      ts: DateTime.now(),
    ),
  ];

  late final List<_FaqItem> _faqs = [
    _FaqItem(
      q: "Rezervasyon ödemem ne zaman çekilir?",
      a: "Ödeme genellikle rezervasyon oluşturulurken provizyon/çekim olarak alınır. Bankanıza göre yansıması birkaç dakika sürebilir (bazı durumlarda daha uzun sürebilir).",
    ),
    _FaqItem(
      q: "Ödeme çekildi ama rezervasyon oluşmadı, ne yapmalıyım?",
      a: "Uygulamayı yenileyin ve Rezervasyonlar sayfasını kontrol edin. Görünmüyorsa 5–10 dakika bekleyin. Hâlâ yoksa Canlı Destek’e tutar + saat + park adı bilgilerini yazın.",
    ),
    _FaqItem(
      q: "Rezervasyonu iptal edersem param ne zaman iade olur?",
      a: "İade süresi bankaya göre değişir (genelde 1–7 iş günü). Uygulamada iptal onayı görüyorsanız süreç başlamıştır.",
    ),
    _FaqItem(
      q: "Rezervasyon saatini uzatabilir miyim?",
      a: "Şu an uzatma yoksa: mevcut rezervasyonu iptal edin ve yeni saatlerle tekrar rezervasyon oluşturun.",
    ),
    _FaqItem(
      q: "Yanlış tarih/saat seçtim, düzeltebilir miyim?",
      a: "Düzenleme özelliği yoksa iptal edip doğru tarih/saatle yeniden rezervasyon oluşturun.",
    ),
    _FaqItem(
      q: "Rezervasyon başlangıç saatim geçti, ne olur?",
      a: "Park kurallarına göre gecikme toleransı olabilir. Gidemeyecekseniz iptal edip yeni saatle rezervasyon oluşturun.",
    ),
    _FaqItem(
      q: "“Ödeme başarısız” hatası alıyorum",
      a: "Kart limitini kontrol edin, 3D Secure açık olsun. İnterneti değiştirin (Wi-Fi/Mobil). Mümkünse farklı kartla deneyin.",
    ),
    _FaqItem(
      q: "Rezervasyon “onaylandı” değil / “beklemede” görünüyor",
      a: "Sayfayı yenileyin. 2–3 dakika sonra hâlâ beklemedeyse iptal edip tekrar deneyin. Devam ederse Canlı Destek’e rezervasyon numarasını gönderin.",
    ),
    _FaqItem(
      q: "Park dolu çıktı ama rezervasyonum var",
      a: "Canlı Destek’e park adı + rezervasyon saati bilgisi yazın. Ekibimiz kontrol eder.",
    ),
    _FaqItem(
      q: "Konumum yanlış, yakın parklar yanlış geliyor",
      a: "Telefon konum iznini açın, GPS’i açın. Emülatörde “Konum Ayarla” yapın. Yakınlar yarıçapını artırmayı deneyin (10–20 km).",
    ),
    _FaqItem(
      q: "Yakın park listesinde hiç sonuç yok",
      a: "Yarıçapı artırın (ör. 15–20 km). Konum izni/GPS açık mı kontrol edin. İnternet bağlantınızı kontrol edin.",
    ),
    _FaqItem(
      q: "Fiyat beklediğimden yüksek geldi",
      a: "Başlangıç/Bitiş saatlerini ve toplam süreyi kontrol edin. Hesaplama saatlik ücret × toplam süre üzerinden yapılır. Yuvarlama kuralı varsa park detayında belirtilir.",
    ),
    _FaqItem(
      q: "Ücret iki kere çekilmiş gibi görünüyor",
      a: "Önce bankanızda provizyon hareketlerini kontrol edin. İki ayrı çekimse Canlı Destek’e tutar + saat + (varsa) kart son 4 hane bilgisini yazın.",
    ),
    _FaqItem(
      q: "İptal ettiğim halde iade görünmüyor",
      a: "İade bankaya bağlı olarak 1–7 iş günü sürebilir. 7 iş gününü aşarsa Canlı Destek’e rezervasyon numarası ile yazın.",
    ),
    _FaqItem(
      q: "Rezervasyonum görünmüyor / kayboldu",
      a: "Uygulamayı kapat-aç yapın, Rezervasyonlar sayfasını yenileyin. Doğru hesapla giriş yaptığınızdan emin olun.",
    ),
    _FaqItem(
      q: "Giriş yapamıyorum / şifremi unuttum",
      a: "Şifre sıfırlamayı deneyin. E-posta doğrulamasını kontrol edin. Sorun sürerse Canlı Destek’e e-posta adresinizi yazın.",
    ),
    _FaqItem(
      q: "Ödeme yöntemi ekleyemiyorum",
      a: "Kart bilgilerinizin doğru olduğundan emin olun. İnternet bağlantınızı kontrol edin. Farklı kart deneyin.",
    ),
    _FaqItem(
      q: "Fatura / ödeme dekontu nasıl alırım?",
      a: "Şu an otomatik dekont ekranı yoksa Canlı Destek’ten talep edebilirsiniz. Rezervasyon numarasını iletmeniz yeterli.",
    ),
    _FaqItem(
      q: "Uygulama hata veriyor / ekran donuyor",
      a: "Uygulamayı kapatıp açın. İnternet bağlantınızı kontrol edin. Devam ederse ekran görüntüsü ile Canlı Destek’e yazın.",
    ),
  ];

  @override
  void dispose() {
    _faqScrollCtrl.dispose();
    _faqAnswerScrollCtrl.dispose();
    _chatCtrl.dispose();
    _chatScrollCtrl.dispose();
    super.dispose();
  }

  void _selectFaq(int i) {
    setState(() => _selectedFaqIndex = i);
    if (_faqAnswerScrollCtrl.hasClients) _faqAnswerScrollCtrl.jumpTo(0);
  }

  void _send() {
    final t = _chatCtrl.text.trim();
    if (t.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(fromAgent: false, text: t, ts: DateTime.now()));
      final ticket = _fakeTicketId();
      _messages.add(_ChatMsg(
        fromAgent: true,
        text:
            "Teşekkürler! Mesajınızı aldık.\nDestek Kodu: $ticket\nBir temsilci kısa süre içinde yanıt verecek.",
        ts: DateTime.now(),
      ));
    });

    _chatCtrl.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollCtrl.hasClients) {
        _chatScrollCtrl.animateTo(
          _chatScrollCtrl.position.maxScrollExtent + 240,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _fakeTicketId() {
    final rnd = Random();
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    return List.generate(8, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final selected = (_selectedFaqIndex == null) ? null : _faqs[_selectedFaqIndex!];

    
    final appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? _brandBlue;
    final accent = appBarColor;
    final miniHeader = appBarColor.withOpacity(0.92);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
        title: const Text("PayPark", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: _Box(
                  title: "Sık Sorulan Sorular",
                  icon: Icons.help_outline,
                  headerColor: miniHeader,
                  headerTextColor: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Scrollbar(
                          controller: _faqScrollCtrl,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: _faqScrollCtrl,
                            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                            itemCount: _faqs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, i) {
                              final it = _faqs[i];
                              final selectedNow = _selectedFaqIndex == i;

                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _selectFaq(i),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: selectedNow
                                        ? accent.withOpacity(0.14)
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    border: Border.all(
                                      color: selectedNow
                                          ? accent.withOpacity(0.45)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          it.q,
                                          style: TextStyle(
                                            fontWeight: selectedNow ? FontWeight.w800 : FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Çözüm",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Scrollbar(
                                    controller: _faqAnswerScrollCtrl,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      controller: _faqAnswerScrollCtrl,
                                      child: Text(
                                        selected == null
                                            ? "Bir soru seçin. Sağda çözüm burada görünecek."
                                            : "• ${selected.a}",
                                        style: const TextStyle(height: 1.35),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                flex: 5,
                child: _Box(
                  title: "Canlı Destek",
                  icon: Icons.support_agent,
                  headerColor: miniHeader,
                  headerTextColor: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Scrollbar(
                          controller: _chatScrollCtrl,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _chatScrollCtrl,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            itemCount: _messages.length,
                            itemBuilder: (context, i) => _ChatBubble(
                              msg: _messages[i],
                              accent: accent,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatCtrl,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _send(),
                                  decoration: InputDecoration(
                                    hintText: "PayPark ile ilgili sorununu yaz...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: accent),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _RoundSendButton(color: accent, onTap: _send),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundSendButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _RoundSendButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 48,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Center(
            child: Icon(Icons.send_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color headerColor;
  final Color headerTextColor;
  final Widget child;

  const _Box({
    required this.title,
    required this.icon,
    required this.headerColor,
    required this.headerTextColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      headerColor,
                      headerColor.withOpacity(0.92),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: headerTextColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: headerTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  _FaqItem({required this.q, required this.a});
}

class _ChatMsg {
  final bool fromAgent;
  final String text;
  final DateTime ts;
  _ChatMsg({required this.fromAgent, required this.text, required this.ts});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  final Color accent;

  const _ChatBubble({required this.msg, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isAgent = msg.fromAgent;
    final bg = isAgent
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : accent.withOpacity(0.16);

    final align = isAgent ? Alignment.centerLeft : Alignment.centerRight;

    return Align(
      alignment: align,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAgent ? Colors.transparent : accent.withOpacity(0.35),
          ),
        ),
        child: Text(msg.text, style: const TextStyle(height: 1.25)),
      ),
    );
  }
}
