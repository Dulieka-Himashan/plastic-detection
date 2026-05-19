import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class ApiService {
  // Register or login user
  static Future<UserModel?> registerUser({
    required String email,
    required String name,
    required String studentId,
    String faculty = '',
    String degree = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'student_id': studentId,
          'faculty': faculty,
          'degree': degree,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(data['user']);
      }
      return null;
    } catch (e) {
      print('API Error: ${e.toString()}');
      return null;
    }
  }

  // Get user profile and points
  static Future<UserModel?> getUser(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$userEndpoint?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get transaction history
  static Future<List<TransactionModel>> getTransactions(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$transactionsEndpoint?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['transactions'];
        return items.map((e) => TransactionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Redeem points
  static Future<Map<String, dynamic>?> redeemPoints({
    required String email,
    required String voucherType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(redeemEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'voucher_type': voucherType,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      }
      return {'error': data['error']};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}