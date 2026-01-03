import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/paypark_app_bar.dart';
import 'fake_payment_service.dart';

class FakePaymentPage extends StatefulWidget {
  const FakePaymentPage({super.key});

  @override
  State<FakePaymentPage> createState() => _FakePaymentPageState();
}

class _FakePaymentPageState extends State<FakePaymentPage> {
  final _holderCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();

  bool _saving = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    _expCtrl.addListener(_autoSlashExp);
  }

  @override
  void dispose() {
    _expCtrl.removeListener(_autoSlashExp);
    _holderCtrl.dispose();
    _numberCtrl.dispose();
    _expCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  String _digits(String s) => s.replaceAll(RegExp(r'\D+'), '');

  void _autoSlashExp() {
    
    final raw = _expCtrl.text;
    final digits = _digits(raw);

    String formatted;
    if (digits.length <= 2) {
      formatted = digits;
    } else {
      final mm = digits.substring(0, 2);
      final yy = digits.substring(2, digits.length.clamp(2, 4));
      formatted = '$mm/$yy';
    }
    if (formatted.length > 5) formatted = formatted.substring(0, 5);

    if (formatted == raw) return;

    _expCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  bool _validExp(String s) {
    final t = s.trim();
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(t)) return false;

    final mm = int.tryParse(t.substring(0, 2)) ?? 0;
    final yy = int.tryParse(t.substring(3, 5)) ?? -1;
    if (mm < 1 || mm > 12) return false;
    if (yy < 0) return false;
    return true;
  }

  bool _validCvc(String s) => RegExp(r'^\d{3}$').hasMatch(_digits(s));

  Future<void> _save() async {
    if (_saving) return;

    final holder = _holderCtrl.text.trim();
    final numDigits = _digits(_numberCtrl.text);
    final exp = _expCtrl.text.trim();
    final cvc = _digits(_cvcCtrl.text);

    if (holder.isEmpty) {
      setState(() => _err = 'Kart üzerindeki isim boş olamaz.');
      return;
    }
    if (numDigits.length < 12) {
      setState(() => _err = 'Kart numarası geçersiz.');
      return;
    }
    if (!_validExp(exp)) {
      setState(() => _err = 'Son kullanım AA/YY formatında olmalı. (örn: 12/28)');
      return;
    }
    if (!_validCvc(cvc)) {
      setState(() => _err = 'CVC 3 haneli olmalı.');
      return;
    }

    setState(() {
      _err = null;
      _saving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));

    final method = FakePaymentService.I.createMethod(
      cardNumberDigits: numDigits,
      holder: holder,
    );

    if (!mounted) return;
    Navigator.pop(context, method); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PayParkAppBar(
        title: 'PayPark',
        showBack: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Ödeme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            TextField(
              controller: _holderCtrl,
              decoration: const InputDecoration(
                labelText: 'Kart üzerindeki isim',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _numberCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                LengthLimitingTextInputFormatter(23),
              ],
              decoration: const InputDecoration(
                labelText: 'Kart numarası',
                hintText: '4242 4242 4242 4242',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Son kullanım (AA/YY)',
                      hintText: '12/28',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _cvcCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3), // ✅ max 3
                    ],
                    decoration: const InputDecoration(
                      labelText: 'CVC',
                      hintText: '123',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            if (_err != null) ...[
              const SizedBox(height: 10),
              Text(_err!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.lock),
                label: Text(_saving ? 'İşleniyor...' : 'Kartı kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
