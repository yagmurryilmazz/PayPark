import 'package:flutter/material.dart';

// AUTH
import 'package:paypark/features/auth/onboarding/welcome_page.dart';
import 'package:paypark/features/auth/auth_gate.dart';
import 'package:paypark/features/auth/login_page.dart';
import 'package:paypark/features/auth/register_page.dart';

// HOME
import 'package:paypark/home/home_page.dart';
import 'package:paypark/home/my_reservations_page.dart';
import 'package:paypark/home/support_page.dart';

// PARKS
import 'package:paypark/parks/park_detail_page.dart';

// PROFILE
import 'package:paypark/profile/profile_page.dart';

// ROUTES
import 'package:paypark/routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case AppRoutes.gate:
        return MaterialPageRoute(builder: (_) => const AuthGate());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case AppRoutes.myReservations:
        return MaterialPageRoute(
          builder: (_) => const MyReservationsPage(embedded: false),
        );

      case AppRoutes.support:
        return MaterialPageRoute(builder: (_) => const SupportPage());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case AppRoutes.parkDetail:
        final arg = settings.arguments;

        String parkId = '';
        if (arg is String) parkId = arg;
        if (arg is Map) parkId = (arg['id'] ?? arg['parkId'] ?? '').toString();

        if (parkId.trim().isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Park id missing')),
            ),
          );
        }

        return MaterialPageRoute(builder: (_) => ParkDetailPage(parkId: parkId));

      
      case AppRoutes.myParks:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Owner panel coming soon')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
