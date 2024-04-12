class Table {
  /// 表名
  final String? name;
  /// 索引，"索引名": ["字段1", "字段2"]
  final Map<String, List<String>>? index;

  const Table({this.name, this.index});

}