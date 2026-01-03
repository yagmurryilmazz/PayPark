import 'package:flutter/material.dart';
import 'package:paypark/core/storage.dart';
import 'package:paypark/routes.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final token = await Storage.getToken();
    if (!mounted) return;

    final next = (token != null && token.isNotEmpty) ? AppRoutes.home : AppRoutes.welcome;
    Navigator.pushNamedAndRemoveUntil(context, next, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
