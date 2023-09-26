// create a database to store the transactions
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class SqlDb {
  static final SqlDb _instance = SqlDb._internal();
  factory SqlDb() => _instance;

  ///commands to create the transactions table
  static String tableTransactions = 'transactions1';
  var sqlTransactionsCommand =
      "CREATE TABLE $tableTransactions (id INTEGER PRIMARY KEY, type TEXT, data TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";

  SqlDb._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String path = await getDatabasesPath();
    return await openDatabase("$path$tableTransactions.db", version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(sqlTransactionsCommand);
    });
  }

  //upgrade database version
  Future upgradeDb() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS $tableTransactions");
    await dbClient.execute(sqlTransactionsCommand);
  }

  Future<int> insert(String type, Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient
        .insert(tableTransactions, {'type': type, 'data': jsonEncode(data)});
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableTransactions, where: 'id = ?', whereArgs: [id]);
  }

  // update the transaction
  Future<int> update(int id, Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient
        .update(tableTransactions, data, where: 'id = ?', whereArgs: [id]);
  }

  // get all the transactions
  Future<List<Map<String, dynamic>>> getAll({String? oredrBy}) async {
    var dbClient = await db;
    return await dbClient.query(tableTransactions, orderBy: oredrBy);
  }

  // get a transaction by id
  Future<Map<String, dynamic>> getById(int id) async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient
        .query(tableTransactions, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : {};
  }

  // get a transaction by type
  Future<List<Map<String, dynamic>>> getByType(String type) async {
    var dbClient = await db;
    return await dbClient
        .query(tableTransactions, where: 'type = ?', whereArgs: [type]);
  }

  //drop the table
  Future dropTable() async {
    var dbClient = await db;
    await dbClient.execute("TRUNCATE TABLE IF EXISTS $tableTransactions");
  }
}
