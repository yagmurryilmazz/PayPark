import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/api.dart';


class HomeLocation {
  static final ValueNotifier<LatLng?> location = ValueNotifier<LatLng?>(null);

  static final Distance _dist = const Distance();

  static void set(LatLng p) {
    final cur = location.value;
    if (cur == null) {
      location.value = p;
      return;
    }
    
    final moved = _dist.as(LengthUnit.Meter, cur, p);
    if (moved >= 20) location.value = p;
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapController = MapController();

  LatLng? _me;
  bool _loading = false;
  String? _error;

  List<_ParkPin> _parks = [];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await _getLocation();
    await _fetchParks();

    if (!mounted) return;
    if (_me != null) {
      _mapController.move(_me!, 14);
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Konum servisleri kapalı.');
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi.');
      }

      if (perm == LocationPermission.deniedForever) {
        throw Exception('Konum izni kalıcı olarak reddedildi. Ayarlardan açın.');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final me = LatLng(pos.latitude, pos.longitude);

      setState(() => _me = me);

     
      HomeLocation.set(me);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchParks() async {
    try {
      final res = await Api.dio.get('/parks');
      final items = (res.data is List)
          ? res.data as List
          : (res.data['items'] as List? ?? []);

      final pins = <_ParkPin>[];
      for (final it in items) {
        final m = Map<String, dynamic>.from(it);
        final lat = (m['lat'] as num?)?.toDouble();
        final lon = (m['lon'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;

        pins.add(
          _ParkPin(
            id: (m['id'] ?? '').toString(),
            title: (m['title'] ?? '').toString(),
            city: (m['city'] ?? '').toString(),
            hourlyPrice: (m['hourly_price'] as num?)?.toDouble(),
            point: LatLng(lat, lon),
          ),
        );
      }

      if (mounted) setState(() => _parks = pins);
    } catch (_) {
      // sessiz geç
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _me ?? const LatLng(41.0082, 28.9784);

    
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_me != null)
                        Marker(
                          point: _me!,
                          width: 46,
                          height: 46,
                          child: const Icon(Icons.my_location_rounded, size: 32),
                        ),
                      ..._parks.map(
                        (p) => Marker(
                          point: p.point,
                          width: 56,
                          height: 56,
                          child: GestureDetector(
                            onTap: () => _showParkBottomSheet(context, p),
                            child: const Icon(Icons.local_parking_rounded, size: 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            
            Positioned(
              left: 16,
              right: 16,
              top: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _TopBar(
                    loading: _loading,
                    error: _error,
                    onLocate: () async {
                      await _getLocation();
                      if (_me != null) _mapController.move(_me!, 15);
                    },
                    onInit: () async {
                      await _init();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showParkBottomSheet(BuildContext context, _ParkPin p) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(p.city),
            if (p.hourlyPrice != null) ...[
              const SizedBox(height: 6),
              Text('Saatlik: ₺${p.hourlyPrice!.toStringAsFixed(0)}'),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      Navigator.pop(context); // detay sheet kapansın
                      await _openCreateReservationSheet(p);
                    },
                    label: const Text('Rezervasyon oluştur'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateReservationSheet(_ParkPin p) async {
    final now = DateTime.now();
    DateTime start = now.add(const Duration(hours: 1));
    DateTime end = start.add(const Duration(hours: 2));

    bool saving = false;

    String fmt(DateTime dt) {
      String two(int n) => n.toString().padLeft(2, '0');
      final d = dt;
      return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
    }

    DateTime? combine(DateTime d, TimeOfDay t) =>
        DateTime(d.year, d.month, d.day, t.hour, t.minute);

    Future<DateTime?> pickDateTime(
      BuildContext context,
      DateTime initial,
    ) async {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(now.year + 2),
        initialDate: initial,
      );
      if (date == null) return null;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time == null) return null;

      return combine(date, time);
    }

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> save() async {
              if (saving) return;

              if (!end.isAfter(start)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bitiş saati başlangıçtan sonra olmalı.')),
                );
                return;
              }

              setLocal(() => saving = true);

              try {
                await Api.dio.post(
                  '/reservations',
                  data: {
                    'park_id': p.id,
                    'start_time': start.toUtc().toIso8601String(),
                    'end_time': end.toUtc().toIso8601String(),
                  },
                );

                if (!mounted) return;
                FocusScope.of(context).unfocus();
                Navigator.pop(sheetCtx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rezervasyon oluşturuldu ✅')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Başarısız: $e')),
                );
              } finally {
                if (ctx.mounted) setLocal(() => saving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rezervasyon oluştur',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Başlangıç'),
                    subtitle: Text(fmt(start)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: saving
                        ? null
                        : () async {
                            final picked = await pickDateTime(ctx, start);
                            if (picked == null) return;
                            setLocal(() {
                              start = picked;
                              if (!end.isAfter(start)) {
                                end = start.add(const Duration(hours: 1));
                              }
                            });
                          },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bitiş'),
                    subtitle: Text(fmt(end)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: saving
                        ? null
                        : () async {
                            final picked = await pickDateTime(ctx, end);
                            if (picked == null) return;
                            setLocal(() => end = picked);
                          },
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: saving ? null : save,
                      child: Text(saving ? 'Kaydediliyor...' : 'Rezerve et'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: saving ? null : () => Navigator.pop(sheetCtx),
                      child: const Text('Vazgeç'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ParkPin {
  final String id;
  final String title;
  final String city;
  final double? hourlyPrice;
  final LatLng point;

  _ParkPin({
    required this.id,
    required this.title,
    required this.city,
    required this.hourlyPrice,
    required this.point,
  });
}

class _TopBar extends StatelessWidget {
  final bool loading;
  final String? error;
  final VoidCallback onLocate;
  final VoidCallback onInit;

  const _TopBar({
    required this.loading,
    required this.error,
    required this.onLocate,
    required this.onInit,
  });

  @override
  Widget build(BuildContext context) {
    final label = loading
        ? 'Konum alınıyor...'
        : (error != null ? 'Konum hatası' : 'Harita hazır');

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.map_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: loading ? null : onInit,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Yenile',
            ),
            IconButton(
              onPressed: loading ? null : onLocate,
              icon: const Icon(Icons.my_location_rounded),
              tooltip: 'Konumum',
            ),
          ],
        ),
      ),
    );
  }
}
