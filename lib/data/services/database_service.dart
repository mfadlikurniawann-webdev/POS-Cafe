import 'package:postgres/postgres.dart';
import '../../core/config/app_config.dart';

class DatabaseService {
  static DatabaseService? _instance;
  Connection? _connection;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Connection> get connection async {
    if (_connection == null || _connection!.isOpen == false) {
      await _connect();
    }
    return _connection!;
  }

  Future<void> _connect() async {
    _connection = await Connection.open(
      Endpoint(
        host: AppConfig.dbHost,
        port: AppConfig.dbPort,
        database: AppConfig.dbName,
        username: AppConfig.dbUser,
        password: AppConfig.dbPassword,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.require),
    );
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? params,
  }) async {
    final conn = await connection;
    final result = params != null
        ? await conn.execute(Sql.named(sql), parameters: params)
        : await conn.execute(sql);
    return result.map((row) => row.toColumnMap()).toList();
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
    final conn = await connection;
    final result = params != null
        ? await conn.execute(Sql.named(sql), parameters: params)
        : await conn.execute(sql);
    return result.affectedRows;
  }

  Future<T> runTransaction<T>(Future<T> Function(Connection conn) fn) async {
    final conn = await connection;
    return conn.runTx((session) => fn(conn));
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  bool get isConnected => _connection?.isOpen == true;
}
