  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final result = await AuthService.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    setState(() => _loading = false);
    
    if (result['success'] == true) {
      if (!mounted) return;
      
      // FIX: Translate the raw JSON map into a proper UserModel object
      final userData = result['user'];
      final userObj = UserModel(
        id: userData['id'] ?? 'usr_123',
        fullName: userData['fullName'] ?? 'Thragg Member',
        accountNumber: userData['accountNumber'] ?? '0000000000',
        balance: (userData['balance'] as num?)?.toDouble() ?? 0.0,
      );

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => HomeScreen(user: userObj), // Pass the object, not the Map!
      ));
    } else {
      setState(() => _error = result['error']);
    }
  }
