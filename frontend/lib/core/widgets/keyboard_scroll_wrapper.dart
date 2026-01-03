import 'package:flutter/material.dart';

class KeyboardScrollWrapper extends StatelessWidget {
  final Widget child;
  const KeyboardScrollWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: child,
      ),
    );
  }
}
