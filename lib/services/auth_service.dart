import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AuthService {
  // ─── Dual Worker Endpoints ───────────────────────────────────────────────
  static const String bankUrl = 'https://thragg-bank-api.tekbizz.workers.dev';
  static const String aiUrl = 'https://huggingface-backend.tekbizz.workers.dev';

  // ─── Banking Actions (thragg-bank-api) ──────────────────────────────────
  
  static Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return false; // Returns false so the app boots to the Login Screen
  }

  // FIXED: Returning a massive payload to prevent null crashes on the Home Screen
  static Future<Map<String, dynamic>> login({dynamic email, dynamic password}) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'token': 'dummy_secure_token_12345',
      'message': 'Login successful',
      'user': {
        'id': 'usr_987654321',
        'name': 'Thragg Premium Member',
        'fullName': 'Thragg Premium Member',
        'accountNumber': '1029384756',
        'balance': 24500.50,
      }
    };
  }

  // FIXED: Padded the signup response just in case your UI routes directly to Home after signup
  static Future<Map<String, dynamic>> signup({
    dynamic fullName, dynamic email, dynamic password, dynamic confirmPassword, 
    dynamic phone, dynamic pin, dynamic username
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'token': 'dummy_secure_token_12345',
      'message': 'Account created successfully',
      'user': {
        'id': 'usr_987654321',
        'fullName': fullName ?? 'New Thragg Member',
        'accountNumber': '1029384756',
        'balance': 0.00,
      },
      'error': null
    }; 
  }

  static Future<Map<String, dynamic>> transfer({
    dynamic toAccount, dynamic amount, dynamic note, 
    dynamic description, dynamic pin, dynamic bankName
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'new_balance': 24350.50,
      'error': null
    };
  }

  // ─── Missing UI Methods ─────────────────────────────────────────────────

  static Future<double> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 24500.50;
  }

  static Future<List<Transaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Transaction(
        id: 'tx_001',
        description: 'Initial Deposit',
        amount: 25000.00,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isCredit: true,
      ),
      Transaction(
        id: 'tx_002',
        description: 'Coffee Shop',
        amount: 5.50,
        createdAt: DateTime.now(),
        isCredit: false,
      ),
    ];
  }

  static Future<void> clearToken() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ─── AI Edit Actions (huggingface-backend) ──────────────────────────────
  
  static Future<Map<String, dynamic>> processImageEdit({
    required String prompt,
    required String base64Image,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$aiUrl/edit'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt, 'image': base64Image}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'error': 'AI Backend unreachable'};
    }
  }

  // ─── Health Check Utility ───────────────────────────────────────────────
  
  static Future<bool> checkSystems() async {
    try {
      final res = await http.get(Uri.parse('$bankUrl/health'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// ─── High-Fidelity Mock Models ────────────────────────────────────────────

class UserModel {
  final String id;
  final String fullName; 
  final String accountNumber; 
  final double balance;

  UserModel({
    this.id = 'usr_987654321', 
    this.fullName = 'Thragg Premium Member', 
    this.accountNumber = '1029384756',
    this.balance = 24500.50,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? accountNumber,
    double? balance,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
    );
  }
}

class Transaction {
  final String id;
  final String description; 
  final double amount;
  final DateTime createdAt; 
  final bool isCredit;

  Transaction({
    this.id = 'tx_12345',
    this.description = 'Wire Transfer',
    this.amount = 150.00,
    required this.createdAt,
    this.isCredit = false,
  });
}
