import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AuthService {
  // ─── Dual Worker Endpoints ───────────────────────────────────────────────
  static const String bankUrl = 'https://thragg-bank-api.tekbizz.workers.dev';
  static const String aiUrl = 'https://huggingface-backend.tekbizz.workers.dev';

  // ─── Banking Actions (thragg-bank-api) ──────────────────────────────────
  
  // Accepts 0, 1, or 2 positional arguments to stop the "0 given" error
  static Future<Map<String, dynamic>> login([dynamic email, dynamic password]) async {
    await Future.delayed(const Duration(seconds: 2));
    return {'success': true};
  }

  // Uses named parameters to catch 'fullName' and anything else your UI sends
  static Future<bool> signup({
    dynamic fullName, dynamic email, dynamic password, dynamic confirmPassword, 
    dynamic phone, dynamic pin, dynamic username
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return true; 
  }

  // Uses named parameters to catch 'toAccount' and others
  static Future<bool> transfer({
    dynamic toAccount, dynamic amount, dynamic note, 
    dynamic description, dynamic pin, dynamic bankName
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
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
  final String fullName; // Fixed from 'name'
  final String accountNumber; // Added missing field
  final double balance;

  UserModel({
    this.id = 'usr_987654321', 
    this.fullName = 'Thragg Premium Member', 
    this.accountNumber = '1029384756',
    this.balance = 24500.50,
  });

  // Added missing copyWith method for state management
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
  final String description; // Fixed from 'title'
  final double amount;
  final DateTime createdAt; // Fixed from 'date'
  final bool isCredit;

  Transaction({
    this.id = 'tx_12345',
    this.description = 'Wire Transfer',
    this.amount = 150.00,
    required this.createdAt,
    this.isCredit = false,
  });
}
