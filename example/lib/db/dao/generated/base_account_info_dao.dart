// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DbGenerator
// **************************************************************************

// NOTE: 可以直接使用该生成类，建议最好继承生成类再使用

import 'package:simple_orm/base_dao.dart';
import 'package:simple_orm_example/db/entity/account_info.dart';
import 'package:sqflite/sqflite.dart';

class BaseUserInfoDao extends BaseDao<UserInfo> {
  static String tableName = "user_info";
  static late Database db;

  static const String columnId = "id";
  static const String columnUsername = "username";
  static const String columnNickname = "nickname";
  static const String columnSex = "sex";
  static const String columnAddress = "address";

  static String _createTableSQL() {
    return "CREATE TABLE IF NOT EXISTS `user_info` (`id` INTEGER PRIMARY KEY autoincrement,`username` TEXT,`nickname` TEXT,`sex` TEXT,`address` TEXT)";
  }

  static Map<String, String> _columnMap() => {
        columnId: 'INTEGER',
        columnUsername: 'TEXT',
        columnNickname: 'TEXT',
        columnSex: 'TEXT',
        columnAddress: 'TEXT',
      };

  static List<String>? _indexList() {
    return const [
      'CREATE INDEX IF NOT EXISTS `sex_index` ON user_info (`sex`);'
    ];
  }

  static _createTable() async {
    await db.execute(_createTableSQL());
  }

  static _createIndex() async {
    // 创建索引
    final indexs = _indexList();
    if (indexs != null) {
      for (var indexString in indexs) {
        if (indexString.isNotEmpty) {
          await db.execute(indexString);
        }
      }
    }
  }

  static _updateCols() async {
    final oldCols = await getTableInfo();
    final newCols = _columnMap();
    List<String> updateSQLs = [];
    log('oldCols: $oldCols');
    // 检查新增字段
    newCols.forEach((key, value) {
      if (!oldCols.containsKey(key)) {
        log("add new column: $key, $value");
        updateSQLs.add('ALTER TABLE $tableName ADD COLUMN $key $value;');
      }
    });

    if (updateSQLs.isNotEmpty) {
      for (var sql in updateSQLs) {
        await db.execute(sql);
      }
    }
  }

  static getTableInfo() async {
    ensureDB();
    var ret = await db.rawQuery('PRAGMA table_info("$tableName")');
    if (ret != null && ret.isNotEmpty) {
      Map<String, String> result = {};
      for (var element in ret) {
        result[element['name'] as String] = element['type'] as String;
      }
      return result;
    } else {
      return {};
    }
  }

  static ensureDB() {
    if (db == null) {
      throw Exception('should invoke initTable first');
    }
  }

  static Future initTable(Database _db) async {
    db = _db;
    // 创建表
    await _createTable();
    // 更新字段
    await _updateCols();
    // 创建索引
    // NOTE：先更新字段再创建索引，防止索引的字段不存在
    await _createIndex();
  }

  @override
  Future<bool> insertOrUpdate(UserInfo entity) async {
    ensureDB();
    Map<String, Object> values = {};
    if (entity.id != null && !entity.id!.isNaN) {
      values['id'] = entity.id!;
    }
    if (entity.username != null && entity.username!.isNotEmpty) {
      values['username'] = entity.username!;
    }
    if (entity.nickname != null && entity.nickname!.isNotEmpty) {
      values['nickname'] = entity.nickname!;
    }
    if (entity.sex != null && entity.sex!.isNotEmpty) {
      values['sex'] = entity.sex!;
    }
    if (entity.address != null && entity.address!.isNotEmpty) {
      values['address'] = entity.address!;
    }

    int ret = await db.insert(tableName, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return ret != 0;
  }

  @override
  Future<UserInfo?> getById(dynamic id) async {
    ensureDB();
    final valuesList =
        await db.rawQuery('SELECT * FROM user_info WHERE id = ?', [id]);
    if (valuesList.isEmpty) {
      return null;
    }
    final values = valuesList[0];
    final item = UserInfo();

    item.id = values['id'] as int?;
    item.username = values['username'] as String?;
    item.nickname = values['nickname'] as String?;
    item.sex = values['sex'] as String?;
    item.address = values['address'] as String?;

    return item;
  }

  @override
  Future<UserInfo?> getFirstOrNull(UserInfo entity) async {
    ensureDB();
    final list = await getList(entity);
    if (list.isEmpty) {
      return null;
    }
    return list[0];
  }

  @override
  Future<List<UserInfo?>> getList([UserInfo? entity]) async {
    ensureDB();
    String querySql = 'SELECT * FROM user_info';
    if (entity != null) {
      StringBuffer whereSb = StringBuffer(' WHERE 1=1');
      if (entity.id != null && !entity.id!.isNaN) {
        whereSb.write(' AND ');
        whereSb.write('id=${entity.id}');
      }
      if (entity.username != null && entity.username!.isNotEmpty) {
        whereSb.write(' AND ');
        whereSb.write('username=${entity.username}');
      }
      if (entity.nickname != null && entity.nickname!.isNotEmpty) {
        whereSb.write(' AND ');
        whereSb.write('nickname=${entity.nickname}');
      }
      if (entity.sex != null && entity.sex!.isNotEmpty) {
        whereSb.write(' AND ');
        whereSb.write('sex=${entity.sex}');
      }
      if (entity.address != null && entity.address!.isNotEmpty) {
        whereSb.write(' AND ');
        whereSb.write('address=${entity.address}');
      }

      querySql = querySql + whereSb.toString();
    }

    final valuesList = await db.rawQuery(querySql);
    List<UserInfo> ret = [];
    for (var values in valuesList) {
      final item = UserInfo();
      item.id = values['id'] as int?;
      item.username = values['username'] as String?;
      item.nickname = values['nickname'] as String?;
      item.sex = values['sex'] as String?;
      item.address = values['address'] as String?;

      ret.add(item);
    }
    return ret;
  }

  @override
  Future<bool> delete([UserInfo? entity]) async {
    ensureDB();
    if (entity == null) {
      await db.execute('DELETE FROM user_info');
      return true;
    }
    String deleteSql = 'DELETE FROM user_info WHERE 1=1 ';
    StringBuffer whereSb = StringBuffer();
    if (entity.id != null && !entity.id!.isNaN) {
      whereSb.write(' AND ');
      whereSb.write('id=${entity.id}');
    }
    if (entity.username != null && entity.username!.isNotEmpty) {
      whereSb.write(' AND ');
      whereSb.write('username=${entity.username}');
    }
    if (entity.nickname != null && entity.nickname!.isNotEmpty) {
      whereSb.write(' AND ');
      whereSb.write('nickname=${entity.nickname}');
    }
    if (entity.sex != null && entity.sex!.isNotEmpty) {
      whereSb.write(' AND ');
      whereSb.write('sex=${entity.sex}');
    }
    if (entity.address != null && entity.address!.isNotEmpty) {
      whereSb.write(' AND ');
      whereSb.write('address=${entity.address}');
    }

    deleteSql = deleteSql + whereSb.toString();
    final ret = await db.rawDelete(deleteSql);
    return ret != 0;
  }

  @override
  Future<int> updateValues(
      Map<String, Object> updateValues, Map<String, Object> whereArgs) async {
    ensureDB();
    final whereSb = StringBuffer('1 = 1');
    if (whereArgs.isNotEmpty) {
      for (var ele in whereArgs.entries) {
        whereSb.write(' AND ');
        whereSb.write('${ele.key} = ${ele.value}');
      }
      return await db.update(tableName, updateValues,
          where: whereSb.toString());
    }
    return 0;
  }
}
