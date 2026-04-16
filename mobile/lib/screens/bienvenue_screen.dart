// ============================================================================
// BIENVENUE SCREEN - Page d'accueil
// ============================================================================

import 'package:flutter/material.dart';
import 'dart:math';

class BienvenueScreen extends StatefulWidget {  // ← BienvenueScreen
  const BienvenueScreen({super.key});

  @override
  State<BienvenueScreen> createState() => _BienvenueScreenState();  // ← _BienvenueScreen
}

class _BienvenueScreenState extends State<BienvenueScreen>
    with TickerProviderStateMixin {
  
  // Controller dyel animation papiers
  late AnimationController _papersController;

  @override
  void initState() {
    super.initState();
    
    // Animation papiers - Ydourou b slowly
    _papersController = AnimationController(
      duration: const Duration(seconds: 20), // 20 seconds bach ykoun smooth
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _papersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background: Beige mat
      backgroundColor: const Color(0xFFF5F5DC),
      
      body: Stack(
        children: [
          
          // =================================================================
          // LAYER 1: Animated Papers Background
          // =================================================================
          
          ...List.generate(8, (index) {
            return AnimatedBuilder(
              animation: _papersController,
              builder: (context, child) {
                // 7sab position - Kol paper 3andou trajectory different
                final t = _papersController.value;
                final random = index * 0.8;
                
                // X: Ymchi men gauche l droite b slowly
                final baseX = MediaQuery.of(context).size.width * 0.1;
                final moveX = (t + random) % 1.0 * MediaQuery.of(context).size.width * 0.8;
                final x = baseX + moveX;
                
                // Y: Ytbaddel b sin wave
                final baseY = MediaQuery.of(context).size.height * (0.1 + (index % 5) * 0.15);
                final waveY = 30 * sin(t * 2 * pi + index);
                final y = baseY + waveY;
                
                // Rotation: Ydour b slowly
                final rotation = sin(t * pi + index) * 0.2;
                
                // Opacity: Ytbaddel b slowly
                final opacity = 0.08 + 0.05 * sin(t * pi * 2 + index);
                
                // Size: Ytbaddel chwiya
                final size = 30.0 + (index % 3) * 10;
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Opacity(
                      opacity: opacity,
                      child: Icon(
                        // Icons differentes dyel papiers/documents
                        index % 4 == 0 ? Icons.description :
                        index % 4 == 1 ? Icons.article :
                        index % 4 == 2 ? Icons.folder_open :
                        Icons.insert_drive_file,
                        size: size,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // =================================================================
          // LAYER 2: Main Content
          // =================================================================
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  
                  // =============================================================
                  // HEADER - Logo sghir + Baladiya Digital
                  // =============================================================
                  
                  const SizedBox(height: 40),
                  
                  Row(
                    children: [
                      // Logo sghir
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            //color: const Color(0xFFF5F5DC),
                            //padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              'assets/images/logoo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Text "Baladiya Digital"
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BALADIYA',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'DIGITALE',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2E7D32).withOpacity(0.7),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // =============================================================
                  // SPACER - Bach text yji fel wast
                  // =============================================================
                  
                  const Spacer(),

                  // =============================================================
                  // CENTER - Jomla avec SHADER/GRADIENT (kima splash)
                  // =============================================================
                  
                  Column(
                    children: [
                      // "Connectez-vous" - Gradient
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
                          'Connectez-vous',
                          style: TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // "pour accéder..." - Gradient khlaf
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFF2E7D32),
                              Color(0xFF4CAF50),
                              Color(0xFF81C784),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'pour accéder aux \nservices de votre mairie',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  // =============================================================
                  // SPACER
                  // =============================================================
                  
                  const Spacer(),

                  // =============================================================
                  // BOTTOM - 2 Buttons
                  // =============================================================
                  
                  // Button 1: Se connecter (Gradient)
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF1B5E20),
                          Color(0xFF2E7D32),
                          Color(0xFF4CAF50),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/connexion');  // ← Ydih l-connexion
                        },
                        child: const Center(
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Button 2: Créer un compte (Outline)
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF2E7D32),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
  Navigator.pushNamed(context, '/creation');  // ← Ydih l-creation
},
                        child: const Center(
                          child: Text(
                            'Créer un compte',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // =============================================================
                  // SPACER BOTTOM
                  // =============================================================
                  
                  const SizedBox(height: 40),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}