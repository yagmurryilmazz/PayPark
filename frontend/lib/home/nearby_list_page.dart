import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../core/api.dart';
import 'map_page.dart';

class NearbyListPage extends StatefulWidget {
  final bool embedded;

  const NearbyListPage({super.key, this.embedded = false});

  @override
  State<NearbyListPage> createState() => _NearbyListPageState();
}

class _NearbyListPageState extends State<NearbyListPage> {
  bool _loading = false;
  String? _errorTitle;
  String? _errorDetail;

  double _radiusKm = 8;

  double? _pendingRadiusKm;
  Timer? _debounce;

  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();

    HomeLocation.location.addListener(_onLocationChanged);

    final loc = HomeLocation.location.value;
    if (loc != null) _load(radiusKm: _radiusKm, loc: loc);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    HomeLocation.location.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onLocationChanged() {
    final loc = HomeLocation.location.value;
    if (loc == null) return;
    _load(radiusKm: _radiusKm, loc: loc);
  }

  double? _tryParseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  double? _extractDistanceKm(Map<String, dynamic> it) {
    return _tryParseDouble(it['distance_km']) ??
        _tryParseDouble(it['distanceKm']) ??
        _tryParseDouble(it['km']) ??
        _tryParseDouble(it['distance']);
  }

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
  }

  void _setPrettyError(Object e) {
    final baseUrl = Api.dio.options.baseUrl;
    _errorTitle = 'İstek başarısız';
    _errorDetail = 'İstek: $baseUrl/parks/nearby\n\n$e';
  }

  Map<String, dynamic> _radiusParams(double radiusKm) {
    final v = radiusKm.round();
    return {'radius_km': v, 'radiusKm': v, 'radius': v, 'km': v};
  }

  Future<void> _load({required double radiusKm, required LatLng loc}) async {
    if (_loading) {
      _pendingRadiusKm = radiusKm;
      return;
    }

    setState(() {
      _loading = true;
      _errorTitle = null;
      _errorDetail = null;
    });

    try {
      final r = await Api.dio.get(
        '/parks/nearby',
        queryParameters: {
          ..._radiusParams(radiusKm),
          'lat': loc.latitude,
          'lng': loc.longitude,
          'lon': loc.longitude, 
        },
      );

      final raw = (r.data?['items'] as List?) ?? const [];
      final list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      list.sort((a, b) {
        final da = _extractDistanceKm(a);
        final db = _extractDistanceKm(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _setPrettyError(e);
      });
    }

    final pending = _pendingRadiusKm;
    _pendingRadiusKm = null;
    if (pending != null && (pending - radiusKm).abs() > 0.001) {
      final l = HomeLocation.location.value;
      if (l != null) _load(radiusKm: pending, loc: l);
    }
  }

  void _onRadiusChanged(double v) => setState(() => _radiusKm = v);

  void _onRadiusChangeEnd(double v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      final loc = HomeLocation.location.value;
      if (!mounted || loc == null) return;
      _load(radiusKm: v, loc: loc);
    });
  }

  @override
  Widget build(BuildContext context) {
    final radiusLabel = _radiusKm.toStringAsFixed(_radiusKm < 10 ? 1 : 0);

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Yakındakiler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Yenile',
                onPressed: _loading
                    ? null
                    : () {
                        final loc = HomeLocation.location.value;
                        if (loc != null) _load(radiusKm: _radiusKm, loc: loc);
                      },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$radiusLabel km içinde',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_items.length} otopark',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Slider(
                  value: _radiusKm,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '$radiusLabel km',
                  onChanged: _onRadiusChanged,
                  onChangeEnd: _onRadiusChangeEnd,
                ),
                ValueListenableBuilder<LatLng?>(
                  valueListenable: HomeLocation.location,
                  builder: (context, loc, _) {
                    if (loc == null) {
                      return Text(
                        'Konum izni bekleniyor…',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                      );
                    }

                    final locText =
                        'Konum: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';

                    if (_loading) {
                      return Text(
                        '$locText • Yükleniyor…',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                      );
                    }

                    return Text(
                      locText,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_errorTitle != null)
                  ? _ErrorView(title: _errorTitle!, detail: _errorDetail)
                  : (HomeLocation.location.value == null)
                      ? const Center(
                          child: Text('Yakındaki otoparkları görmek için konum izni gereklidir.'),
                        )
                      : (_items.isEmpty)
                          ? Center(child: Text('$radiusLabel km içinde otopark bulunamadı.'))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 6),
                              itemBuilder: (context, i) {
                                final it = _items[i];

                                final title = (it['title'] ?? it['park_title'] ?? 'Otopark')
                                    .toString();
                                final city = (it['city'] ?? it['park_city'] ?? '').toString();
                                final distKm = _extractDistanceKm(it);

                                final subtitle = distKm == null
                                    ? city
                                    : (city.isEmpty
                                        ? _formatDistance(distKm)
                                        : '$city • ${_formatDistance(distKm)}');

                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  leading: const Icon(Icons.local_parking),
                                  title: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(subtitle),
                                  trailing: const Icon(Icons.chevron_right),
                                );
                              },
                            ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Yakındakiler')),
      body: body,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String title;
  final String? detail;

  const _ErrorView({
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(detail!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
