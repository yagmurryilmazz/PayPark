import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api.dart';
import '../payments/fake_payment_page.dart';
import '../payments/fake_payment_service.dart';

class ParkLite {
  final String id;
  final String title;
  final String city;

  const ParkLite({
    required this.id,
    required this.title,
    required this.city,
  });
}

Future<bool> showReservationCreateSheet(
  BuildContext context, {
  ParkLite? initialPark,
}) async {
  final res = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _ReservationCreateSheet(initialPark: initialPark),
  );
  return res ?? false;
}

class _ReservationCreateSheet extends StatefulWidget {
  final ParkLite? initialPark;
  const _ReservationCreateSheet({this.initialPark});

  @override
  State<_ReservationCreateSheet> createState() => _ReservationCreateSheetState();
}

class _ReservationCreateSheetState extends State<_ReservationCreateSheet> {
  bool _loading = false;
  bool _creating = false;
  String? _error;

  final _searchCtrl = TextEditingController();
  final _tcCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();

  List<ParkLite> _parks = [];
  ParkLite? _selected;

  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();

    _selected = widget.initialPark;

    final now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 5) * 5);
    _end = _start.add(const Duration(hours: 2));

    _fetchParks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tcCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  List<ParkLite> _mockParks() {
    return const [
      ParkLite(id: 'mock-uskudar', title: 'Üsküdar Park', city: 'İstanbul'),
      ParkLite(id: 'mock-kadikoy', title: 'Kadıköy Otopark', city: 'İstanbul'),
      ParkLite(id: 'mock-cankaya', title: 'Çankaya Park', city: 'Ankara'),
      ParkLite(id: 'mock-karsiyaka', title: 'Karşıyaka Park', city: 'İzmir'),
    ];
  }

  Future<void> _fetchParks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await Api.dio.get('/parks');

      final items = (res.data is List)
          ? (res.data as List)
          : ((res.data is Map) ? ((res.data['items'] as List?) ?? const []) : const []);

      final list = <ParkLite>[];
      for (final it in items) {
        if (it is! Map) continue;
        final m = Map<String, dynamic>.from(it);
        list.add(
          ParkLite(
            id: (m['id'] ?? '').toString(),
            title: (m['title'] ?? '').toString(),
            city: (m['city'] ?? '').toString(),
          ),
        );
      }

      if (!mounted) return;

      if (list.isEmpty) {
        setState(() {
          _parks = _mockParks();
          _error = 'Parklar yüklenemedi. (Test için örnek parklar gösteriliyor.)';
        });
      } else {
        setState(() => _parks = list);
      }

      if (_selected != null) {
        final match = _parks.where((p) => p.id == _selected!.id).toList();
        if (match.isNotEmpty) setState(() => _selected = match.first);
      }
    } on DioException catch (_) {
      if (!mounted) return;
      setState(() {
        _parks = _mockParks();
        _error = 'Parklar yüklenemedi. (Test için örnek parklar gösteriliyor.)';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _parks = _mockParks();
        _error = 'Parklar yüklenemedi. (Test için örnek parklar gösteriliyor.)';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (t == null) return;

    final newStart = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() {
      _start = newStart;
      if (!_end.isAfter(_start.add(const Duration(minutes: 30)))) {
        _end = _start.add(const Duration(hours: 2));
      }
    });
  }

  Future<void> _pickEnd() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (t == null) return;

    final newEnd = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() => _end = newEnd);
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  bool _isTcValid(String s) => RegExp(r'^\d{11}$').hasMatch(s);

  String _normalizePlate(String s) => s.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  bool _isPlateValid(String s) {
    if (s.length < 5 || s.length > 16) return false;
    return RegExp(r'^[A-Z0-9 ]+$').hasMatch(s);
  }

  String _prettyDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Sunucuya bağlanılamadı (zaman aşımı). İnterneti kontrol edip tekrar dene.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return 'Sunucu hata döndü${code == null ? '' : ' ($code)'}: ${e.response?.data ?? ''}';
      case DioExceptionType.connectionError:
        return 'Bağlantı hatası. Backend ayakta mı kontrol et.';
      default:
        return 'İstek başarısız: ${e.message ?? 'Bilinmeyen hata'}';
    }
  }

  Future<void> _continueToPaymentAndCreate() async {
    final park = _selected;
    final tc = _tcCtrl.text.trim();
    final plate = _normalizePlate(_plateCtrl.text);

    if (park == null) {
      setState(() => _error = 'Lütfen bir park seçin.');
      return;
    }
    if (!_end.isAfter(_start.add(const Duration(minutes: 30)))) {
      setState(() => _error = 'Bitiş saati başlangıçtan en az 30 dk sonra olmalı.');
      return;
    }
    if (!_isTcValid(tc)) {
      setState(() => _error = 'TC Kimlik No 11 haneli olmalı.');
      return;
    }
    if (!_isPlateValid(plate)) {
      setState(() => _error = 'Plaka formatı geçersiz.');
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      // 1) Fake ödeme ekranına git
      final method = await Navigator.of(context).push<FakePaymentMethod>(
        MaterialPageRoute(builder: (_) => const FakePaymentPage()),
      );

      if (!mounted) return;

      // kullanıcı geri döndüyse
      if (method == null) {
        setState(() => _creating = false);
        return;
      }

      // 2) Rezervasyonu oluştur
      final resp = await Api.dio.post(
        '/reservations',
        data: {
          'park_id': park.id,
          'start_time': _start.toUtc().toIso8601String(),
          'end_time': _end.toUtc().toIso8601String(),
          'tc_no': tc,
          'plate': plate,
        },
      );

      // 3) reservation id yakala
      String reservationId = '';
      final data = resp.data;

      if (data is Map) {
        reservationId = (data['id'] ?? data['reservation_id'] ?? data['reservationId'] ?? '').toString();
        if (reservationId.isEmpty && data['reservation'] is Map) {
          final r = Map<String, dynamic>.from(data['reservation']);
          reservationId = (r['id'] ?? r['reservation_id'] ?? r['reservationId'] ?? '').toString();
        }
      }

      if (reservationId.isEmpty) {
        reservationId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      }

      // 4) kartı rezervasyona bağla 
      FakePaymentService.I.attachToReservation(reservationId, method);

      if (!mounted) return;
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Rezervasyon oluşturulamadı: ${_prettyDioError(e)}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Rezervasyon oluşturulamadı: $e');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? _parks
        : _parks.where((p) => p.title.toLowerCase().contains(q) || p.city.toLowerCase().contains(q)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
          child: ListView(
            controller: scrollController,
            children: [
              const Text('Rezervasyon Oluştur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),

              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Park ara',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (final p in filtered.take(20))
                        ListTile(
                          title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(p.city),
                          trailing: _selected?.id == p.id ? const Icon(Icons.check) : null,
                          onTap: _creating ? null : () => setState(() => _selected = p),
                        ),
                      if (filtered.length > 20)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Daha fazla sonuç için aramayı daraltın...',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _creating ? null : _pickStart,
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text(_fmt(_start)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _creating ? null : _pickEnd,
                      icon: const Icon(Icons.timelapse_rounded),
                      label: Text(_fmt(_end)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _tcCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(
                  labelText: 'TC Kimlik No',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _plateCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z ]')),
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  labelText: 'Plaka',
                  hintText: '34ABC75',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  final up = _normalizePlate(v);
                  if (up != v) {
                    _plateCtrl.value = _plateCtrl.value.copyWith(
                      text: up,
                      selection: TextSelection.collapsed(offset: up.length),
                    );
                  }
                },
              ),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: _creating ? null : _continueToPaymentAndCreate,
                  icon: const Icon(Icons.check),
                  label: Text(_creating ? 'İşleniyor...' : 'Ödeme ekranı'),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
