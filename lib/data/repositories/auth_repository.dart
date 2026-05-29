import '../models/user.dart';
import '../services/database_service.dart';

class AuthRepository {
  final _db = DatabaseService.instance;

  Future<User?> login(String username, String password) async {
    // In production, you would hash the provided password and compare.
    // For this prototype, we check raw password_hash column based on schema.
    final row = await _db.queryOne(
      'SELECT id, username, role FROM users WHERE username = @username AND password_hash = @password',
      params: {
        'username': username,
        'password': password,
      },
    );

    if (row != null) {
      return User.fromMap(row);
    }
    return null;
  }
}
