import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'main_navigation_screen.dart';
import 'user_setup_screen.dart';
import '../providers/settings_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _iconOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _backgroundOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Icon animations
    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _iconOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    // Text animations
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    // Background animation
    _backgroundOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start background animation
    _backgroundController.forward();
    
    // Wait a bit then start icon animation
    await Future.delayed(const Duration(milliseconds: 300));
    _iconController.forward();
    
    // Start text animation after icon starts
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Load settings and check setup status
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.loadSettings();
      
      // Navigate based on setup completion
      final targetScreen = settingsProvider.isSetupComplete 
          ? const MainNavigationScreen()
          : const UserSetupScreen();
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _iconController,
          _textController,
          _backgroundController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade600.withOpacity(_backgroundOpacityAnimation.value),
                  Colors.blue.shade800.withOpacity(_backgroundOpacityAnimation.value),
                  Colors.indigo.shade900.withOpacity(_backgroundOpacityAnimation.value),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated App Icon
                  Transform.scale(
                    scale: _iconScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _iconRotationAnimation.value * 0.5,
                      child: Opacity(
                        opacity: _iconOpacityAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated App Title
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            'Expense Tracker',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your expenses offline',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 