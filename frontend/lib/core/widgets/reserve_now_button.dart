import 'package:flutter/material.dart';
import 'package:paypark/core/widgets/reservation_create_sheet.dart';

class ReserveNowButton extends StatelessWidget {
  final String parkId;
  final String parkTitle;
  final String parkCity;
  final VoidCallback? onCreated;

  const ReserveNowButton({
    super.key,
    required this.parkId,
    required this.parkTitle,
    required this.parkCity,
    this.onCreated,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final created = await showReservationCreateSheet(
          context,
          initialPark: ParkLite(id: parkId, title: parkTitle, city: parkCity),
        );
        if (created && onCreated != null) onCreated!();
      },
      icon: const Icon(Icons.add),
      label: const Text('Rezervasyon oluştur'),
    );
  }
}
