import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AuthService {
  // ─── Dual Worker Endpoints ───────────────────────────────────────────────
  // Points to: thragg-bank-api.tekbizz.workers.dev
  static const String bankUrl = 'https://thragg-bank-api.tekbizz.workers.dev';
  
  // Points to: huggingface-backend.tekbizz.workers.dev
  static const String aiUrl = 'https://huggingface-backend.tekbizz.workers.dev';

  // ─── Banking Actions (thragg-bank-api) ──────────────────────────────────
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$bankUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'error': 'Bank connection failed'};
    }
  }

  // --- BULLETPROOF SIGNUP MOCK ---
  // Accepts dynamic arguments to catch whatever your UI sends without crashing
  static Future<bool> signup([dynamic a, dynamic b, dynamic c, dynamic d]) async {
    await Future.delayed(const Duration(seconds: 2)); // High-fidelity loading simulation
    return true; 
  }

  // --- BULLETPROOF TRANSFER MOCK ---
  static Future<bool> transfer([dynamic a, dynamic b, dynamic c, dynamic d]) async {
    await Future.delayed(const Duration(seconds: 2)); // High-fidelity loading simulation
    return true;
  }

  // ─── AI Edit Actions (huggingface-backend) ──────────────────────────────
  
  static Future<Map<String, dynamic>> processImageEdit({
    required String prompt,
    required String base64Image,
  }) async {
    try {
      // Note: Ensure your huggingface-backend Worker has an '/edit' or '/generate' route
      final res = await http.post(
        Uri.parse('$aiUrl/edit'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'image': base64Image,
        }),
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
// Placed here so your UI screens can instantly recognize them

class UserModel {
  final String id;
  final String name;
  final double balance;

  UserModel({
    this.id = 'usr_987654321', 
    this.name = 'Thragg Premium Member', 
    this.balance = 24500.50,
  });
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isCredit;

  Transaction({
    this.id = 'tx_12345',
    this.title = 'Wire Transfer',
    this.amount = 150.00,
    required this.date,
    this.isCredit = false,
  });
}
