import 'package:flutter/material.dart';
import 'package:paypark/router.dart';
import 'package:paypark/routes.dart';

const Color kBrandBlue = Color(0xFF3B82F6);

void main() {
  runApp(const PayParkApp());
}

class PayParkApp extends StatelessWidget {
  const PayParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kBrandBlue,
      brightness: Brightness.light,
      primary: kBrandBlue,
      background: Colors.white,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'PayPark',
      debugShowCheckedModeBanner: false,

      
      builder: (context, child) {
        return Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => PopScope(
                canPop: false,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,

        
        scaffoldBackgroundColor: Colors.white,

        
        appBarTheme: const AppBarTheme(
          backgroundColor: kBrandBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        
        iconTheme: const IconThemeData(color: kBrandBlue),

        
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kBrandBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kBrandBlue,
            side: const BorderSide(color: kBrandBlue, width: 1.2),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kBrandBlue,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),

       
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F7FB),
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.50)),
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.70)),
          floatingLabelStyle: const TextStyle(color: kBrandBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBrandBlue, width: 1.8),
          ),
        ),

        
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: kBrandBlue,
          unselectedItemColor: Colors.black.withOpacity(0.55),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: kBrandBlue.withOpacity(0.12),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? kBrandBlue : Colors.black.withOpacity(0.55),
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? Colors.black : Colors.black.withOpacity(0.65),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            );
          }),
        ),
      ),

      initialRoute: AppRoutes.gate,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
