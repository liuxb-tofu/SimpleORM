class ColumnInfo {
  /// 字段名
  final String? name;
  /// 是否是主键
  final bool primaryKey;
  /// 是否自增——只有int类型支持自增
  final bool? autoIncrement;
  const ColumnInfo({this.name, this.primaryKey = false, this.autoIncrement});
}