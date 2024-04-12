import 'package:simple_orm_example/db/dao/generated/base_account_info_dao.dart';

class UserInfoDao extends BaseUserInfoDao {
  static UserInfoDao? _instance;

  factory UserInfoDao() => _instance ??= UserInfoDao._();

  UserInfoDao._();
}