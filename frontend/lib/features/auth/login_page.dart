import 'package:flutter/material.dart';
import 'package:paypark/core/api.dart';
import 'package:paypark/core/storage.dart';
import 'package:paypark/routes.dart';
import 'package:paypark/core/widgets/paypark_app_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await Api.dio.post('/auth/login', data: {
        'email': emailC.text.trim(),
        'password': passC.text,
      });

      final token = (res.data['token'] ?? '').toString();
      if (token.isEmpty) throw Exception('Token not found');

      await Storage.setToken(token);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      setState(() => error = 'Login failed');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const PayParkAppBar(
        title: 'PayPark',
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: passC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            const SizedBox(height: 20),

            if (error != null) ...[
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: Text(loading ? 'Signing in...' : 'Login'),
              ),
            ),

            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.register),
              child:
                  const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
