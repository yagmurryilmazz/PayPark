import 'dart:math';

class FakePaymentMethod {
  final String id;
  final String brand; 
  final String last4;
  final String holder;

  const FakePaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holder,
  });
}

class FakeChargeResult {
  final bool ok;
  final String message;
  final double amount;
  final String currency;
  final FakePaymentMethod method;

  const FakeChargeResult({
    required this.ok,
    required this.message,
    required this.amount,
    required this.currency,
    required this.method,
  });
}


class FakePaymentService {
  FakePaymentService._();
  static final FakePaymentService I = FakePaymentService._();

  final Map<String, FakePaymentMethod> _byReservationId = {};
  final Random _rnd = Random();

  FakePaymentMethod createMethod({
    required String cardNumberDigits,
    required String holder,
  }) {
    final digits = cardNumberDigits.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    final brand = _detectBrand(digits);

    final id = _fakeId(prefix: 'pm_');
    return FakePaymentMethod(id: id, brand: brand, last4: last4, holder: holder.trim().isEmpty ? 'Kart Sahibi' : holder.trim());
  }

  void attachToReservation(String reservationId, FakePaymentMethod method) {
    _byReservationId[reservationId] = method;
  }

  FakePaymentMethod? methodOfReservation(String reservationId) {
    return _byReservationId[reservationId];
  }

  Future<FakeChargeResult> charge({
    required String reservationId,
    required double amount,
    String currency = 'TRY',
  }) async {
    // Fake network delay
    await Future.delayed(const Duration(milliseconds: 650));

    final method = _byReservationId[reservationId];
    if (method == null) {
      return FakeChargeResult(
        ok: false,
        message: 'Bu rezervasyon için kayıtlı kart bulunamadı.',
        amount: amount,
        currency: currency,
        method: const FakePaymentMethod(id: 'pm_missing', brand: 'Card', last4: '----', holder: '---'),
      );
    }

    return FakeChargeResult(
      ok: true,
      message: 'Ödeme alındı.',
      amount: amount,
      currency: currency,
      method: method,
    );
  }

  String _fakeId({required String prefix}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final s = List.generate(14, (_) => chars[_rnd.nextInt(chars.length)]).join();
    return '$prefix$s';
  }

  String _detectBrand(String digits) {
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'MasterCard';
    if (digits.startsWith('34') || digits.startsWith('37')) return 'Amex';
    return 'Card';
  }
}
