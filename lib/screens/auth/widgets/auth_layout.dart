import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget infoPanel;
  final Widget formPanel;
  final bool infoOnLeft;

  const AuthLayout({
    super.key,
    required this.infoPanel,
    required this.formPanel,
    this.infoOnLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    final infoWidget = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE6EFFF), Color(0xFFF3EBFF)], // Soft gradient blue+purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background grid/dots pattern from images (simulated with opacity)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _DotGridPainter(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: infoPanel,
          ),
        ],
      ),
    );

    final formWidget = Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: formPanel,
          ),
        ),
      ),
    );

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: formWidget,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: infoOnLeft
            ? [
                Expanded(flex: 1, child: infoWidget),
                Expanded(flex: 1, child: formWidget),
              ]
            : [
                Expanded(flex: 1, child: formWidget),
                Expanded(flex: 1, child: infoWidget),
              ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    
    for (double i = 0; i < size.width; i += 30) {
      for (double j = 0; j < size.height; j += 30) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
