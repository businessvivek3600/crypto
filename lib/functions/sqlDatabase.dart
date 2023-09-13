// create a database to store the transactions
import 'dart:convert';

import 'package:my_global_tools/utils/default_logger.dart';
import 'package:sqflite/sqflite.dart';

class SqlDb {
  static final SqlDb _instance = SqlDb._internal();
  factory SqlDb() => _instance;

  ///commands to create the transactions table
  var sqlTransactionsCommand =
      "CREATE TABLE transactions (id INTEGER PRIMARY KEY, type TEXT, data TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";

  SqlDb._internal();

  late Database _db;

  Future<Database> get db async {
    try {
      _db = await initDb();
      // await upgradeDb();
    } catch (e) {
      errorLog(e.toString(), 'SqlDb');
    }
    return _db;
  }

  initDb() async {
    String path = await getDatabasesPath();
    return await openDatabase("${path}transactions.db", version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(sqlTransactionsCommand);
    });
  }

  //upgrade database version
  Future upgradeDb() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS transactions");
    await dbClient.execute(sqlTransactionsCommand);
  }

  Future<int> insert(String type, Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient
        .insert('transactions', {'type': type, 'data': jsonEncode(data)});
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // update the transaction
  Future<int> update(int id, Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient
        .update('transactions', data, where: 'id = ?', whereArgs: [id]);
  }

  // get all the transactions
  Future<List<Map<String, dynamic>>> getAll({String? oredrBy}) async {
    var dbClient = await db;
    return await dbClient.query('transactions', orderBy: oredrBy);
  }

  // get a transaction by id
  Future<Map<String, dynamic>> getById(int id) async {
    var dbClient = await db;
    List<Map<String, dynamic>> result =
        await dbClient.query('transactions', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : {};
  }

  // get a transaction by type
  Future<List<Map<String, dynamic>>> getByType(String type) async {
    var dbClient = await db;
    return await dbClient
        .query('transactions', where: 'type = ?', whereArgs: [type]);
  }
}
