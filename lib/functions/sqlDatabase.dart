// create a database to store the transactions
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class SqlDb {
  static final SqlDb _instance = SqlDb._internal();
  factory SqlDb() => _instance;

  SqlDb._internal();

  late Database _db;

  Future<Database> get db async {
    _db = await initDb();
    return _db;
  }

  initDb() async {
    String path = await getDatabasesPath();
    return await openDatabase("${path}transactions.db", version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE transactions (id INTEGER PRIMARY KEY, type TEXT, data TEXT)");
    });
  }

  //upgrade database version
  Future upgradeDb() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS transactions");
    await dbClient.execute(
        "CREATE TABLE transactions (id INTEGER PRIMARY KEY, type TEXT, data TEXT)");
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
  Future<List<Map<String, dynamic>>> getAll() async {
    var dbClient = await db;
    return await dbClient.query('transactions');
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
