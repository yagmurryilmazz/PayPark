import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
import '../core/payments/fake_payment_service.dart';
import '../core/widgets/paypark_app_bar.dart';
import '../core/widgets/reservation_create_sheet.dart';

class MyReservationsPage extends StatefulWidget {
  final bool embedded;

  const MyReservationsPage({
    super.key,
    this.embedded = true,
  });

  @override
  State<MyReservationsPage> createState() => MyReservationsPageState();
}

class MyReservationsPageState extends State<MyReservationsPage> {
  int _tabIndex = 0;
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];

  String _query = '';
  Timer? _bannerTimer;

  
  final Map<String, Timer> _endWarnTimers = {};

  final _fmt = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    for (final t in _endWarnTimers.values) {
      t.cancel();
    }
    _endWarnTimers.clear();
    super.dispose();
  }

  // -------------------- TOP BANNER --------------------

  void _showTopBanner({
    required String text,
    IconData icon = Icons.info_outline,
    Color? iconColor,
    Duration autoHide = const Duration(seconds: 3),
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.clearMaterialBanners();
    _bannerTimer?.cancel();

    messenger.showMaterialBanner(
      MaterialBanner(
        leading: Icon(icon, color: iconColor),
        content: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => messenger.clearMaterialBanners(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );

    _bannerTimer = Timer(autoHide, () {
      if (!mounted) return;
      messenger.clearMaterialBanners();
    });
  }

  // -------------------- HELPERS --------------------

  String _statusOf(Map<String, dynamic> r) {
    final s = (r['status'] ?? r['durum'] ?? '').toString();
    return s.isEmpty ? 'pending' : s;
  }

  String _statusKeyOf(Map<String, dynamic> r) {
    final raw = _statusOf(r).trim().toLowerCase();

    switch (raw) {
      case 'confirmed':
      case 'onaylandi':
      case 'onaylandı':
      case 'onayli':
      case 'onaylı':
        return 'confirmed';
      case 'pending':
      case 'beklemede':
        return 'pending';
      case 'cancelled':
      case 'canceled':
      case 'iptal':
      case 'iptal edildi':
      case 'iptal_edildi':
        return 'cancelled';
      case 'completed':
      case 'tamamlandi':
      case 'tamamlandı':
      case 'bitti':
        return 'completed';
      default:
        return raw.isEmpty ? 'pending' : raw;
    }
  }

  String _statusLabelTr(String statusKey) {
    switch (statusKey) {
      case 'confirmed':
        return 'Onaylandı';
      case 'pending':
        return 'Beklemede';
      case 'cancelled':
        return 'İptal edildi';
      case 'completed':
        return 'Tamamlandı';
      default:
        return 'Bilinmiyor';
    }
  }

  String _plateOf(Map<String, dynamic> r) {
    final v = (r['plate'] ?? r['car_plate'] ?? r['plaka'] ?? '').toString().trim();
    return v.isEmpty ? '-' : v;
  }

  DateTime? _parseDate(dynamic v) {
    final s = (v ?? '').toString();
    return DateTime.tryParse(s);
  }

  double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    final s = v.toString().replaceAll(',', '.').trim();
    return double.tryParse(s) ?? 0;
  }

  void _scheduleEndWarnings() {
    
    for (final t in _endWarnTimers.values) {
      t.cancel();
    }
    _endWarnTimers.clear();

    final now = DateTime.now();

    for (final r in _items) {
      final id = (r['id'] ?? '').toString();
      if (id.isEmpty) continue;

      final statusKey = _statusKeyOf(r);
      if (statusKey != 'confirmed' && statusKey != 'pending') continue;

      final end = _parseDate(r['end_time']);
      if (end == null) continue;

      final warnAt = end.subtract(const Duration(minutes: 30));
      if (warnAt.isBefore(now)) continue;

      final delay = warnAt.difference(now);
      _endWarnTimers[id] = Timer(delay, () {
        if (!mounted) return;
        _showTopBanner(
          text: 'Rezervasyon bitimine 30 dk kaldı. Uzatmak ister misin?',
          icon: Icons.notifications_active_outlined,
          iconColor: Colors.orange,
          autoHide: const Duration(seconds: 5),
        );
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final r = await Api.dio.get('/reservations/me');
      final items = (r.data?['items'] as List?) ?? const [];
      if (!mounted) return;
      setState(() => _items = items.map((e) => Map<String, dynamic>.from(e)).toList());

      _scheduleEndWarnings();
    } catch (_) {
      // sessiz
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // -------------------- SEARCH --------------------

  Future<void> openSearch() async {
    final q = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final ctrl = TextEditingController(text: _query);

        return StatefulBuilder(
          builder: (ctx2, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rezervasyonlarda ara', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Park, şehir, durum, plaka…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: ctrl.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                ctrl.clear();
                                setModalState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onChanged: (_) => setModalState(() {}),
                    onSubmitted: (v) => Navigator.pop(ctx2, v.trim()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx2, ''),
                          child: const Text('Temizle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(ctx2, ctrl.text.trim()),
                          child: const Text('Ara'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    if (q == null) return;
    setState(() => _query = q);
  }

  List<Map<String, dynamic>> _filteredItems() {
    final now = DateTime.now();

    bool isPast(Map<String, dynamic> r) {
      final end = _parseDate(r['end_time']);
      if (end == null) return false;
      return end.isBefore(now);
    }

    final base = _items.where((r) {
      final statusKey = _statusKeyOf(r);

      switch (_tabIndex) {
        case 1:
          return statusKey == 'confirmed' || statusKey == 'pending';
        case 2:
          return isPast(r) || statusKey == 'completed';
        case 3:
          return statusKey == 'cancelled';
        default:
          return true;
      }
    }).toList();

    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return base;

    bool contains(Map<String, dynamic> r, String key) {
      final v = (r[key] ?? '').toString().toLowerCase();
      return v.contains(q);
    }

    return base.where((r) {
      return contains(r, 'park_title') ||
          contains(r, 'park_city') ||
          contains(r, 'status') ||
          contains(r, 'durum') ||
          contains(r, 'plate') ||
          contains(r, 'car_plate') ||
          contains(r, 'tc_no') ||
          contains(r, 'user_note');
    }).toList();
  }

  // -------------------- CANCEL --------------------

  Future<void> _cancel(Map<String, dynamic> r) async {
    final id = (r['id'] ?? '').toString();
    if (id.isEmpty) return;

    final oldItems = List<Map<String, dynamic>>.from(_items);

    
    setState(() {
      _items = _items.map((x) {
        if ((x['id'] ?? '').toString() == id) {
          final n = Map<String, dynamic>.from(x);
          n['status'] = 'cancelled';
          n['durum'] = 'cancelled';
          return n;
        }
        return x;
      }).toList();
    });

    try {
      await Api.dio.patch('/reservations/$id/cancel');

      if (!mounted) return;
      await _refresh();

      _showTopBanner(
        text: 'Rezervasyon iptal edildi.',
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      );
    } catch (_) {
      
      if (!mounted) return;
      setState(() => _items = oldItems);

      _showTopBanner(
        text: 'İptal isteği gönderildi (demo).',
        icon: Icons.info_outline,
        iconColor: Colors.orange,
      );
    }
  }

  Future<void> _confirmCancel(Map<String, dynamic> r, BuildContext sheetCtx) async {
    final parkTitle = (r['park_title'] ?? '').toString();
    final start = _parseDate(r['start_time']);
    final startStr = start == null ? '' : _fmt.format(start);

    final v = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rezervasyon iptal edilsin mi?'),
        content: Text('$parkTitle • $startStr'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet, iptal et')),
        ],
      ),
    );

    if (v == true) {
      if (Navigator.of(sheetCtx).canPop()) Navigator.pop(sheetCtx);
      await _cancel(r);
    }
  }

  // -------------------- EXIT / PAYMENT (BACKEND) --------------------

  Future<void> _carExit(Map<String, dynamic> r, BuildContext sheetCtx) async {
    if (Navigator.of(sheetCtx).canPop()) Navigator.pop(sheetCtx);

    final id = (r['id'] ?? '').toString();
    if (id.isEmpty) return;

    
    final pm = FakePaymentService.I.methodOfReservation(id);

    try {
      final resp = await Api.dio.post(
        '/reservations/$id/exit',
        data: pm == null
            ? null
            : {
                'method': {
                  'brand': pm.brand,
                  'last4': pm.last4,
                  'holder': pm.holder,
                }
              },
      );

      
      double amount = 0;
      if (resp.data is Map) {
        final m = Map<String, dynamic>.from(resp.data);
        if (m['payment'] is Map) {
          final p = Map<String, dynamic>.from(m['payment']);
          amount = _parseAmount(p['amount']);
        }
      }
      if (amount <= 0) {
        
        amount = _parseAmount(r['total_price']);
      }

      if (!mounted) return;

      _showTopBanner(
        text: 'Ödeme alındı: ₺${amount.toStringAsFixed(2)}',
        icon: Icons.credit_card,
        iconColor: Colors.green,
        autoHide: const Duration(seconds: 4),
      );

      await _refresh();
    } catch (_) {
      if (!mounted) return;

      _showTopBanner(
        text: 'Ödeme/çıkış işlemi başarısız. (Backend endpoint kontrol et)',
        icon: Icons.error_outline,
        iconColor: Colors.red,
        autoHide: const Duration(seconds: 5),
      );
    }
  }

  // -------------------- DETAILS SHEET --------------------

  void _openDetails(Map<String, dynamic> r) {
    final parkTitle = (r['park_title'] ?? '').toString();
    final city = (r['park_city'] ?? '').toString();
    final plate = _plateOf(r);

    final statusKey = _statusKeyOf(r);
    final statusLabel = _statusLabelTr(statusKey);

    final start = _parseDate(r['start_time']);
    final end = _parseDate(r['end_time']);
    final total = (r['total_price'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parkTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(city),
            const SizedBox(height: 10),
            Text('Plaka: $plate'),
            const SizedBox(height: 6),
            Text('Durum: $statusLabel'),
            const SizedBox(height: 8),
            Text('Başlangıç: ${start == null ? '-' : _fmt.format(start)}'),
            Text('Bitiş: ${end == null ? '-' : _fmt.format(end)}'),
            const SizedBox(height: 8),
            Text('Toplam: $total'),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: statusKey == 'completed' || statusKey == 'cancelled' ? null : () => _carExit(r, sheetCtx),
                icon: const Icon(Icons.credit_card),
                label: const Text('Araç çıkış yaptı'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: statusKey == 'cancelled' || statusKey == 'completed' ? null : () => _confirmCancel(r, sheetCtx),
                icon: const Icon(Icons.close),
                label: const Text('İptal et'),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // -------------------- CREATE --------------------

  Future<void> _createReservation() async {
    if (_loading) return;
    final created = await showReservationCreateSheet(context);
    if (created) _refresh();
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems();
    final reserveBtnHeight = 48.0;

    final list = _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refresh,
            child: items.isEmpty
                ? ListView(
                    padding: EdgeInsets.only(bottom: _tabIndex == 0 ? (reserveBtnHeight + 20) : 16),
                    children: const [
                      SizedBox(height: 160),
                      Center(child: Text('Henüz rezervasyon yok.')),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: _tabIndex == 0 ? (reserveBtnHeight + 20) : 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final r = items[i];
                      final title = (r['park_title'] ?? '').toString();
                      final city = (r['park_city'] ?? '').toString();

                      final statusKey = _statusKeyOf(r);
                      final statusLabel = _statusLabelTr(statusKey);

                      final start = _parseDate(r['start_time']);
                      final end = _parseDate(r['end_time']);

                      return Card(
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(
                            '$city\n${start == null ? '-' : _fmt.format(start)}  →  ${end == null ? '-' : _fmt.format(end)}',
                          ),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.black12,
                            ),
                            child: Text(statusLabel),
                          ),
                          onTap: () => _openDetails(r),
                        ),
                      );
                    },
                  ),
          );

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Tümü')),
                  ButtonSegment(value: 1, label: Text('Aktif')),
                  ButtonSegment(value: 2, label: Text('Geçmiş')),
                  ButtonSegment(value: 3, label: Text('İptal')),
                ],
                selected: {_tabIndex},
                onSelectionChanged: (s) => setState(() => _tabIndex = s.first),
              ),
              const SizedBox(height: 12),
              Expanded(child: list),
            ],
          ),
          if (_tabIndex == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: reserveBtnHeight,
                  child: FilledButton.icon(
                    onPressed: _createReservation,
                    icon: const Icon(Icons.add),
                    label: const Text('Rezervasyon oluştur'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      appBar: const PayParkAppBar(
        title: 'PayPark',
        showBack: false,
      ),
      body: content,
    );
  }
}
