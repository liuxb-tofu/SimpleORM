import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:simple_orm_annotation/annotation/table.dart';
import 'package:source_gen/source_gen.dart';


class DbGenerator extends GeneratorForAnnotation<Table> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    String fileName = buildStep.inputId.pathSegments.last;
    String package = buildStep.inputId.package;
    String importPath = buildStep.inputId.path.replaceFirst('lib/', '');
    String tableName = annotation.peek('name')?.stringValue ??
        element.displayName.toLowerCase();
    final indexMap = annotation.peek('index')?.mapValue ?? {};
    String entityClassName = element.displayName;
    String className = 'Base${capitalize(entityClassName)}Dao';
    List<_ColumnFieldInfo> columns = [];
    _ColumnFieldInfo? primaryKeyInfo;

    if (element.kind == ElementKind.CLASS) {
      for (var field in (element as ClassElement).fields) {
        DartObject? columnInfoElement;
        print(
            'visit field: ${field.name}, ${field.type.isDartCoreString}, runtime: ${field.runtimeType}');
        for (var annotation in field.metadata) {
          print(
              'visit annotation: ${annotation.computeConstantValue()}, ${annotation.element?.kind}');
          if (annotation.element?.kind == ElementKind.CONSTRUCTOR &&
              annotation.element?.displayName == 'ColumnInfo') {
            columnInfoElement = annotation.computeConstantValue();
            break;
          }
        }

        if (columnInfoElement != null) {
          String columnValue =
              columnInfoElement.getField('name')?.toStringValue() ?? field.name;
          String columnName = 'column${capitalize(columnValue)}';

          String columnType;
          String fieldType;
          bool autoIncrement = false;
          if (field.type.isDartCoreString) {
            columnType = 'TEXT';
            fieldType = 'String';
          } else if (field.type.isDartCoreBool) {
            columnType = 'NUMERIC';
            fieldType = 'bool';
          } else if (field.type.isDartCoreDouble) {
            columnType = 'NUMERIC';
            fieldType = 'double';
          } else if (field.type.isDartCoreInt) {
            columnType = 'INTEGER';
            fieldType = 'int';
            // 只有int类型才支持设置自增
            autoIncrement = columnInfoElement.getField('autoIncrement')?.toBoolValue() ?? false;
          } else if (field.type.isDartCoreNum) {
            columnType = 'NUMERIC';
            fieldType = 'num';
          } else {
            throw Exception('unsupported type: ${field.type}');
          }

          bool primaryKey =
              columnInfoElement.getField('primaryKey')?.toBoolValue() ?? false;
          final columnInfo = _ColumnFieldInfo(columnName, columnValue,
              columnType, field.name, fieldType, primaryKey, autoIncrement);
          if (primaryKey) {
            primaryKeyInfo = columnInfo;
          }
          columns.add(columnInfo);
        }
      }
      if (primaryKeyInfo == null) {
        throw Exception('entity must has a primary key');
      }
    }

    StringBuffer columnFieldSb = StringBuffer();
    StringBuffer createSqlSb =
        StringBuffer('CREATE TABLE IF NOT EXISTS `$tableName` (');
    List<String> indexStringList = [];
    StringBuffer setupValuesSb = StringBuffer();
    StringBuffer setupItemSb = StringBuffer();
    StringBuffer setupWhereSb = StringBuffer();
    StringBuffer columnMapSb = StringBuffer();

    for (var entry in indexMap.entries) {
      if (entry.value == null || entry.value!.toListValue()?.isEmpty == true) {
        continue;
      }
      final columnList = entry.value!.toListValue()!;
      StringBuffer indexSb = StringBuffer('\'CREATE INDEX IF NOT EXISTS `${entry.key!.toStringValue()}` ON $tableName (');
      for (int i =0; i < columnList.length; i++) {
        final col = columnList[i];
        indexSb.write('`${col.toStringValue()}`');
        if (i < columnList.length-1) {
          indexSb.write(',');
        }
      }
      indexSb.write(');\'');
      indexStringList.add(indexSb.toString());
    }
    int i = 0;
    for (var column in columns) {
      createSqlSb.write('`${column.columnValue}` ${column.columnType}');
      if (column.isPrimary) {
        createSqlSb.write(' PRIMARY KEY');
      }
      if (column.autoIncrement) {
        createSqlSb.write(' autoincrement');
      }
      if (i < columns.length - 1) {
        createSqlSb.write(',');
      }
      columnFieldSb.writeln(
          'static const String ${column.columnName} = "${column.columnValue}";');
      if (column.columnType == 'TEXT') {
        setupValuesSb.writeln(
            'if (entity.${column.entityFieldName} != null && entity.${column.entityFieldName}!.isNotEmpty) {');
        setupValuesSb.writeln(
            ' values[\'${column.columnValue}\'] = entity.${column.entityFieldName}!;');
        setupValuesSb.writeln('}');

        setupItemSb.writeln(
            'item.${column.entityFieldName} = values[\'${column.columnValue}\'] as String?;');

        setupWhereSb.writeln(
            'if (entity.${column.entityFieldName} != null && entity.${column.entityFieldName}!.isNotEmpty) {');
        setupWhereSb.writeln('  whereSb.write(\' AND \');');
        setupWhereSb.writeln(
            '  whereSb.write(\'${column.columnValue}=\${entity.${column.entityFieldName}}\');');
        setupWhereSb.writeln('}');
      } else if (column.columnType == 'NUMERIC' || column.columnType == 'INTEGER') {
        setupValuesSb.writeln(
            'if (entity.${column.entityFieldName} != null && !entity.${column.entityFieldName}!.isNaN) {');
        setupValuesSb.writeln(
            ' values[\'${column.columnValue}\'] = entity.${column.entityFieldName}!;');
        setupValuesSb.writeln('}');

        if (column.entityFieldType == 'double') {
          setupItemSb.writeln(
              'item.${column.entityFieldName} = values[\'${column.columnValue}\'] as double?;');
        } else if (column.entityFieldType == 'int') {
          setupItemSb.writeln(
              'item.${column.entityFieldName} = values[\'${column.columnValue}\'] as int?;');
        } else if (column.entityFieldType == 'bool') {
          setupItemSb.writeln(
              'item.${column.entityFieldName} = values[\'${column.columnValue}\'] as bool?;');
        } else {
          setupItemSb.writeln(
              'item.${column.entityFieldName} = values[\'${column.columnValue}\'] as num?;');
        }

        setupWhereSb.writeln(
            'if (entity.${column.entityFieldName} != null && !entity.${column.entityFieldName}!.isNaN) {');
        setupWhereSb.writeln('  whereSb.write(\' AND \');');
        setupWhereSb.writeln(
            '  whereSb.write(\'${column.columnValue}=\${entity.${column.entityFieldName}}\');');
        setupWhereSb.writeln('}');
      }

      columnMapSb.writeln('${column.columnName}: \'${column.columnType}\',');

      i++;
    }
    createSqlSb.write(')');
    String outputString = '''
      // NOTE: 可以直接使用本类，建议继承本类再使用
      
      import 'package:simple_orm/base_dao.dart';
      import 'package:$package/$importPath';
      import 'package:sqflite/sqflite.dart';
      
      class $className extends BaseDao<$entityClassName> {
        static String tableName = "$tableName";
        static late Database db;
        
        ${columnFieldSb.toString()}

        static String _createTableSQL() {
          return "${createSqlSb.toString()}";
        }

        static Map<String, String> _columnMap() => {
           ${columnMapSb.toString()}
        };
        
        static List<String>? _indexList() {
          return const [
            ${indexStringList.join(',')}
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
          log('oldCols: \$oldCols');
          // 检查新增字段
          newCols.forEach((key, value) {
            if (!oldCols.containsKey(key)) {
              log("add new column: \$key, \$value");
              updateSQLs.add('ALTER TABLE \$tableName ADD COLUMN \$key \$value;');
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
          var ret = await db.rawQuery('PRAGMA table_info("\$tableName")');
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
        Future<bool> insertOrUpdate($entityClassName entity) async {
          ensureDB();
          Map<String, Object> values = {};
          ${setupValuesSb.toString()}
          int ret = await db.insert(tableName, values, conflictAlgorithm: ConflictAlgorithm.replace);
          return ret != 0;
        }
        
        @override
        Future<$entityClassName?> getById(dynamic id) async {
          ensureDB();
          final valuesList = await db.rawQuery('SELECT * FROM $tableName WHERE ${primaryKeyInfo!.columnValue} = ?', [id]);
          if (valuesList.isEmpty) {
            return null;
          }
          final values = valuesList[0];
          final item = $entityClassName();

          ${setupItemSb.toString()}
          return item;
        }
        
        @override
        Future<$entityClassName?> getFirstOrNull($entityClassName entity) async {
          ensureDB();
          final list = await getList(entity);
          if (list.isEmpty) {
            return null;
          }
          return list[0];
        }
        
        @override
        Future<List<$entityClassName?>> getList([$entityClassName? entity]) async {
          ensureDB();
          String querySql = 'SELECT * FROM $tableName';
          if (entity != null) {
            StringBuffer whereSb = StringBuffer(' WHERE 1=1');
            ${setupWhereSb.toString()}
            querySql = querySql + whereSb.toString();
          }

          final valuesList = await db.rawQuery(querySql);
          List<$entityClassName> ret = [];
          for (var values in valuesList) {
            final item = $entityClassName();
            ${setupItemSb.toString()}
            ret.add(item);
          }
          return ret;
        }
        
        @override
        Future<bool> delete([$entityClassName? entity]) async {
          ensureDB();
          if (entity == null) {
            await db.execute('DELETE FROM $tableName');
            return true;
          }
          String deleteSql = 'DELETE FROM $tableName WHERE 1=1 ';
          StringBuffer whereSb = StringBuffer();
          ${setupWhereSb.toString()}
          deleteSql = deleteSql + whereSb.toString();
          final ret = await db.rawDelete(deleteSql);
          return ret != 0;
        }
        
        @override
        Future<int> updateValues(Map<String, Object> updateValues, Map<String, Object> whereArgs) async {
          ensureDB();
          final whereSb = StringBuffer('1 = 1');
          if (whereArgs.isNotEmpty) {
            for (var ele in whereArgs.entries) {
              whereSb.write(' AND ');
              whereSb.write('\${ele.key} = \${ele.value}');
            }
            return await db.update(tableName, updateValues, where: whereSb.toString());
          }
          return 0;
        }
      }
    ''';
    return outputString;
  }

  String capitalize(String string) {
    return "${string[0].toUpperCase()}${string.substring(1)}";
  }
}

class _ColumnFieldInfo {
  final String columnName;
  final String columnValue;
  final String columnType;
  final String entityFieldName;
  final String entityFieldType;
  final bool isPrimary;
  final bool autoIncrement;

  const _ColumnFieldInfo(this.columnName, this.columnValue, this.columnType,
      this.entityFieldName, this.entityFieldType, this.isPrimary, this.autoIncrement);
}
