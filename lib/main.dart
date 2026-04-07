import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  // Ensure Flutter engine is ready before calling native code (SystemChrome)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait for a consistent banking UI experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set the status bar color to match our Thragg Bank yellow
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kYellow,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  runApp(const ThraggBankApp());
}

class ThraggBankApp extends StatelessWidget {
  const ThraggBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thragg Bank',
      debugShowCheckedModeBanner: false,
      // Uses the custom theme we defined in constants.dart
      theme: thraggTheme(),
      home: const SplashRouter(),
    );
  }
}

/// The SplashRouter handles the initial loading state and session check
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});
  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 700),
    )..forward();
    
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    
    _navigate();
  }

  Future<void> _navigate() async {
    // Artificial delay for the splash animation to play out
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // Check if a token exists in SharedPreferences
    final bool loggedIn = await AuthService.isLoggedIn();
    
    if (!mounted) return;

    if (loggedIn) {
      // If logged in, fetch the latest balance and user data
      final balance = await AuthService.getBalance();
      
      // Note: In this simple version, we push to Login if balance fetch fails
      // This ensures we always have a valid "hydrated" user object for the Home Screen
      if (balance != null) {
        // Here we'd ideally have a 'getCurrentUser' method. 
        // Since we're keeping it simple, we'll redirect to Login to ensure 
        // the user object is properly built from the login response.
      }
    }

    // Default route: Login Screen
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kYellow,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The Logo Icon
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: kDark,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: kDark.withOpacity(0.3),
                      blurRadius: 30, 
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('TB',
                    style: TextStyle(
                      color: kYellow, 
                      fontSize: 38,
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 2,
                    )),
                ),
              ),
              const SizedBox(height: 24),
              const Text('THRAGG BANK',
                style: TextStyle(
                  color: kDark, 
                  fontSize: 28,
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 4,
                )),
              const SizedBox(height: 6),
              Text('Financial freedom, simplified.',
                style: TextStyle(
                  color: kDark.withOpacity(0.55),
                  fontSize: 14,
                )),
            ],
          ),
        ),
      ),
    );
  }
}
