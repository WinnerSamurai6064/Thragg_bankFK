import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _pinCtrl      = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscurePin  = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_pinCtrl.text.length != 4) {
      setState(() => _error = 'PIN must be exactly 4 digits');
      return;
    }
    setState(() { _loading = true; _error = null; });
    
    final result = await AuthService.signup(
      fullName: _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      pin:      _pinCtrl.text,
    );
    
    setState(() => _loading = false);
    
    if (result['success'] == true) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: result['user'])),
        (_) => false,
      );
    } else {
      setState(() => _error = result['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Open Account',
          style: GoogleFonts.spaceGrotesk(
            color: kDark, fontWeight: FontWeight.w800,
          )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kYellow, kYellowLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome Bonus',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800, fontSize: 17, color: kDark,
                      )),
                    Text('\$200 credited to your new account instantly!',
                      style: GoogleFonts.dmSans(
                        fontSize: 13, color: kDark.withOpacity(0.7),
                      )),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 32),

            _Label('Full Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Treyvonte Winz',
                prefixIcon: Icon(Icons.person_outline_rounded, color: kGrey),
              ),
            ),
            const SizedBox(height: 20),

            _Label('Email Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.alternate_email_rounded, color: kGrey),
              ),
            ),
            const SizedBox(height: 20),

            _Label('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                hintText: 'Min. 8 characters',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: kGrey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: kGrey,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _Label('4-Digit PIN'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pinCtrl,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                prefixIcon: const Icon(Icons.pin_outlined, color: kGrey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePin ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: kGrey,
                  ),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kDanger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, color: kDanger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: GoogleFonts.dmSans(
                    color: kDanger, fontSize: 13,
                  ))),
                ]),
              ),
            ],

            const SizedBox(height: 36),
            SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: _loading ? null : _signup,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: kDark),
                      )
                    : const Text('Create Account — Free'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'By creating an account you agree to Thragg Bank\'s Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 12, color: kGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: kDark,
    ));
}
