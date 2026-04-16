
// IMPORTS - Libraries li nhtajhom

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// MAIN CLASS - Splash Screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// STATE CLASS - Logic w animations

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
    
  // CONTROLLERS
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _particleController;

  // ANIMATIONS
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _buttonScale;

  // INIT STATE
  @override
  void initState() {
    super.initState();

    // TEXT ANIMATION
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textSlide = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // BUTTON ANIMATION
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));

    // PAPIERS ANIMATION - 10s 
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),  
      vsync: this,
    )..repeat();

    // SEQUENCE
    _textController.forward().then((_) {
      _buttonController.forward();
    });
  }

  // DISPOSE
  @override
  void dispose() {
    _textController.dispose();
    _buttonController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // NAVIGATION
  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/bienvenue');
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      
      body: Stack(
        children: [
          
          // LAYER 1: WAVES 
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: WavePainter(
                  animation: _particleController.value,
                ),
              );
            },
          ),

          // LAYER 2: PAPIERS 
          ...List.generate(10, (index) {  
            return AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                final t = _particleController.value;
                final random = index * 0.8;
                
                // X: Ymchi men gauche l droite
                final baseX = MediaQuery.of(context).size.width * 0.05;
                final moveX = (t + random) % 1.0 * MediaQuery.of(context).size.width * 0.9;
                final x = baseX + moveX;
                
                // Y: Wave
                final baseY = MediaQuery.of(context).size.height * (0.1 + (index % 6) * 0.12);
                final waveY = 40 * sin(t * 2 * pi + index);
                final y = baseY + waveY;
                
                // Rotation
                final rotation = sin(t * pi + index) * 0.3;
                
                // Opacity: Shwiya akber bch ybanou
                final opacity = 0.10 + 0.06 * sin(t * pi * 2 + index);  
                
                // Size
                final size = 25.0 + (index % 4) * 8;
                
                // Icons
                final IconData icon = index % 4 == 0 
                    ? Icons.description
                    : index % 4 == 1 
                        ? Icons.article
                        : index % 4 == 2 
                            ? Icons.folder_open
                            : Icons.insert_drive_file;

                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Opacity(
                      opacity: opacity,
                      child: Icon(
                        icon,
                        size: size,
                       
                        color: index % 2 == 0 
                            ? const Color(0xFF1B5E20)  
                            : const Color(0xFF2E7D32), 
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // LAYER 3: MAIN CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    const SizedBox(height: 40),
                    
                    // LOGO
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/images/logoo.png',fit: BoxFit.contain,),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // TEXT
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFade.value,
                          child: Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Bienvenue
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      colors: [
                                        Color(0xFF1B5E20),
                                        Color(0xFF2E7D32),
                                        Color(0xFF4CAF50),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'Bienvenue',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // dans votre
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      colors: [
                                        Color(0xFF2E7D32),
                                        Color(0xFF4CAF50),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'dans votre',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // BALADIYA DIGITALE
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      colors: [
                                        Color(0xFF1B5E20),
                                        Color(0xFF2E7D32),
                                        Color(0xFF4CAF50),
                                        Color(0xFF2E7D32),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'BALADIYA DIGITALE',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 100),

                    // BUTTON
                    AnimatedBuilder(
                      animation: _buttonController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonScale.value,
                          child: GestureDetector(
                            onTap: _goToHome,
                            child: Container(
                              width: 220,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF1B5E20),
                                    Color(0xFF2E7D32),
                                    Color(0xFF4CAF50),
                                    Color(0xFF2E7D32),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2E7D32).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Commencer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// WAVES PAINTER - 
class WavePainter extends CustomPainter {
  final double animation;

  WavePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Wave 1 - 
    final paint1 = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.03)  // ← Rj3na 0.03
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x += 10) {
      
      final y = size.height * 0.7 + 
                30 * sin((x / size.width * 2 * pi) + (animation * 2 * pi));
      path1.lineTo(x, y);
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Wave 2 
    final paint2 = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.02)  // ← Rj3na 0.02
      ..style = PaintingStyle.fill;
    
    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.8 + 
                40 * sin((x / size.width * 2 * pi) + (animation * 2 * pi) + 1);
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}