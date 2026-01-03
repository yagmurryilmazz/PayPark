import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/api.dart';
import '../core/widgets/paypark_app_bar.dart';
import '../core/widgets/reservation_create_sheet.dart';
import '../models/park.dart';

class ParkDetailPage extends StatefulWidget {
  final String parkId;
  const ParkDetailPage({super.key, required this.parkId});

  @override
  State<ParkDetailPage> createState() => _ParkDetailPageState();
}

class _ParkDetailPageState extends State<ParkDetailPage> {
  Future<Park> fetchDetail() async {
    final res = await Api.dio.get('/parks/${widget.parkId}');
    final data = Map<String, dynamic>.from((res.data?['park'] as Map?) ?? {});
    return Park.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PayParkAppBar(title: 'PayPark', showBack: true),
      body: FutureBuilder<Park>(
        future: fetchDetail(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return Center(child: Text('Detail failed: ${snap.error ?? ''}'));
          }

          final p = snap.data!;
          final price = p.hourlyPrice == null ? '-' : '₺${p.hourlyPrice!.toStringAsFixed(0)}/h';
          final avail = p.available == null ? '-' : '${p.available}/${p.capacity ?? '-'}';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(p.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(p.city, style: const TextStyle(color: Colors.black54)),
              if (p.address != null) ...[
                const SizedBox(height: 10),
                Text(p.address!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _InfoTile(label: 'Price', value: price, icon: Icons.payments_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(label: 'Availability', value: avail, icon: Icons.event_available_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (p.hasLocation) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 190,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(p.lat!, p.lon!),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.paypark',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(p.lat!, p.lon!),
                              width: 56,
                              height: 56,
                              child: const Icon(Icons.local_parking_rounded, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              SizedBox(
                height: 46,
                child: FilledButton.icon(
                  onPressed: () async {
                    final created = await showReservationCreateSheet(
                      context,
                      initialPark: ParkLite(id: p.id, title: p.title, city: p.city),
                    );
                    if (created && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reservation created')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Reserve now'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
