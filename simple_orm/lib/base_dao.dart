abstract class BaseDao<T> {
  /// 插入一条数据，如果主键存在就更新该条数据
  Future<bool> insertOrUpdate(T entity) async => false;

  /// 根据主键查询数据
  Future<T?> getById(dynamic id) async => null;

  /// 根据查询条件获取查到的第一个值
  Future<T?> getFirstOrNull(T entity) async => null;

  /// 根据设置的条件查询数据，不传表示获取所有数据
  Future<List<T?>> getList([T? entity]) async => [];

  /// 根据条件删除数据，不传表示删除所有数据
  Future<bool> delete([T? entity]) async => false;

  Future<int> update(Map<String, Object> updateValues,
          Map<String, Object> whereArgs) async =>
      0;
}

log(message) {
  print(message);
}
