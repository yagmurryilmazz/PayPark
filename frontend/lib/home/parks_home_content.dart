import 'package:flutter/material.dart';

import 'map_page.dart';
import 'nearby_list_page.dart';

class ParksHomeContent extends StatelessWidget {
  const ParksHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.height * 0.46;

    
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPark'),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              
              SizedBox(
                height: mapHeight,
                width: double.infinity,
                child: _RoundedCard(
                  radius: 18,
                  borderColor: appBarColor,
                  borderWidth: 4,
                  child: const MapPage(),
                ),
              ),

              const SizedBox(height: 12),

              
              const Expanded(
                child: _RoundedCard(
                  radius: 18,
                  child: NearbyListPage(embedded: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color? borderColor;
  final double? borderWidth;

  const _RoundedCard({
    required this.child,
    required this.radius,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final side = (borderColor != null && (borderWidth ?? 0) > 0)
        ? BorderSide(color: borderColor!, width: borderWidth!)
        : BorderSide.none;

    return Material(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: side,
      ),
      child: child,
    );
  }
}
