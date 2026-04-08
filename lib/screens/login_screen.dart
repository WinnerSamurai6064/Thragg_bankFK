import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final result = await AuthService.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    setState(() => _loading = false);
    
    if (result['success'] == true) {
      if (!mounted) return;
      
      final userData = result['user'];
      final userObj = UserModel(
        id: userData['id'] ?? 'usr_123',
        fullName: userData['fullName'] ?? 'Thragg Member',
        accountNumber: userData['accountNumber'] ?? '0000000000',
        balance: (userData['balance'] as num?)?.toDouble() ?? 0.0,
      );

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => HomeScreen(user: userObj),
      ));
    } else {
      setState(() => _error = result['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _HeroHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Welcome back', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w800, color: kDark)),
                      const SizedBox(height: 4),
                      Text('Sign in to your account', style: GoogleFonts.dmSans(fontSize: 15, color: kGrey)),
                      const SizedBox(height: 32),
                      _Label('Email address'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'you@example.com', prefixIcon: Icon(Icons.alternate_email_rounded, color: kGrey)),
                      ),
                      const SizedBox(height: 20),
                      _Label('Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: kGrey),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: kGrey),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: kDanger.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            const Icon(Icons.error_outline_rounded, color: kDanger, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!, style: GoogleFonts.dmSans(color: kDanger, fontSize: 13))),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: kDark)) : const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: GoogleFonts.dmSans(color: kGrey)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                            child: Text('Create one', style: GoogleFonts.dmSans(color: kYellowDark, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 260,
      decoration: const BoxDecoration(color: kYellow, borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      child: Stack(
        children: [
          Positioned(top: -40, right: -40, child: _Circle(160, kYellowLight.withOpacity(0.5))),
          Positioned(bottom: -20, left: -30, child: _Circle(120, kYellowDark.withOpacity(0.3))),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: kDark, borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('TB', style: TextStyle(color: kYellow, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1))),
                ),
                const SizedBox(height: 14),
                Text('THRAGG BANK', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: kDark, letterSpacing: 2)),
                Text('Financial freedom, simplified.', style: GoogleFonts.dmSans(fontSize: 13, color: kDark.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size; final Color color;
  const _Circle(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: kDark));
}
