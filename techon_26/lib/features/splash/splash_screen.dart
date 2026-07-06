import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD1DC), // Pastel Pink
              Color(0xFFE6DDF2), // Light Purplish
              Color(0xFFAEC6CF), // Pastel Blue
              Color(0xFFFDFD96), // Pastel Yellow
            ],
            stops: [0.1, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(180), // Semi-transparent
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A67C4).withAlpha(40), // Purplish shadow
                          blurRadius: 40,
                          spreadRadius: 10,
                          offset: const Offset(0, 15),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withAlpha(200),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      size: 70,
                      color: Color(0xFF8A67C4), // Purplish primary
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'StockMaster',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5A3D8A), // Deep purplish
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Inventory with Elegance.',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF5A3D8A).withAlpha(180),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 60),
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF8A67C4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
