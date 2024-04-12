
import 'package:simple_orm_annotation/annotation/column_info.dart';
import 'package:simple_orm_annotation/annotation/table.dart';

@Table(name: 'user_info', index: {'sex_index': ['sex']})
class UserInfo {
  @ColumnInfo(name: 'id', primaryKey: true, autoIncrement: true)
  int? id;
  @ColumnInfo(name: 'username')
  String? username;
  @ColumnInfo(name: 'nickname')
  String? nickname;
  @ColumnInfo(name: 'sex')
  String? sex;
  @ColumnInfo(name: 'address')
  String? address;
}