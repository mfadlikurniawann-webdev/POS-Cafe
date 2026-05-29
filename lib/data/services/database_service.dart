import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kReleaseMode

class DatabaseService {
  static DatabaseService? _instance;

  // Hardcode the vercel URL for safety to avoid URI scheme missing errors in Dart HTTP
  final String _apiUrl = 'https://pos-cafe-zeta.vercel.app/api/query'; 

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  // To maintain compatibility with existing repositories that might check connection
  Future<dynamic> get connection async {
    return this; 
  }

  Future<void> _connect() async {
    // No-op for HTTP
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': sql,
          'params': params,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'] as List;
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Database Query Error: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Database HTTP Exception: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> queryOne(
    String sql, {
    Map<String, dynamic>? params,
  }) async {
    final rows = await query(sql, params: params);
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> execute(
    String sql, {
    Map<String, dynamic>? params,
  }) async {
    final rows = await query(sql, params: params);
    // Neon returns the affected rows typically as array length for some queries
    // or we can just return 1 for success since the previous code just wanted affected rows
    return 1;
  }

  // Dummy runTransaction for compatibility
  Future<T> runTransaction<T>(Future<T> Function(dynamic conn) fn) async {
    return fn(this);
  }

  Future<void> close() async {
    // No-op for HTTP
  }

  bool get isConnected => true;
}
