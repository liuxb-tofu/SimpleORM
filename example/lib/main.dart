import 'package:flutter/material.dart';
import 'package:simple_orm_example/db/dao/generated/base_account_info_dao.dart';
import 'package:sqflite/sqflite.dart';

import 'db/dao/user_info_dao.dart';
import 'db/entity/account_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await initDB();
  await BaseUserInfoDao.initTable(db);
  runApp(const MyApp());
}

initDB() async {
  // open the database
  final databasesPath = await getDatabasesPath();

  final dbPath = "$databasesPath/simple_orm_example.db";

  return await openDatabase(
    dbPath,
    version: 1,
    onCreate: (Database db, int version) async {},
    onUpgrade: (Database db, int oldVersion, int newVersion) async {},
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, String>? _tableInfo;
  List<UserInfo>? _userInfoList;
  int _count = 0;
  @override
  void initState() {
    asyncInit();
  }

  void asyncInit() async {
    BaseUserInfoDao.getTableInfo().then((value) {
      setState(() {
        _tableInfo = value;
      });
    });
    UserInfoDao().getList().then((value) {
      setState(() {
        _count = value.length;
        _userInfoList = value.cast<UserInfo>();
      });
    });
  }

  _addUser() {
    UserInfoDao().insertOrUpdate(UserInfo()
      ..username = 'user_$_count'
      ..nickname = 'nickname_$_count'
      ..address = 'address_$_count'
      ..sex = 'male'
    ).then((value) {
      _count++;
      asyncInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: _tableInfo == null
              ? Container()
              : Table(
                  defaultColumnWidth: const FixedColumnWidth(90),
                  children: [_buildRowTitle(), ..._buildRowData()],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addUser,
      ),
    );
  }

  _buildRowTitle() {
    final columnsList = <Widget>[];
    _tableInfo?.keys.forEach((element) {
      final column = Container(
        color: Colors.black38,
        child: Text(
          element,
          textAlign: TextAlign.center,
        ),
      );
      columnsList.add(column);
    });
    return TableRow(children: columnsList);
  }

  _buildRowData() {
    final columnsList = <TableRow>[];
    _userInfoList?.forEach((userInfo) {
      final rowWidget = <Widget>[];
      rowWidget
        ..add(Container(
          color: Colors.black38,
          child: Text(
            userInfo.id.toString(),
            textAlign: TextAlign.center,
          ),
        ))
        ..add(Container(
          color: Colors.black38,
          child: Text(
            userInfo.username ?? '',
            textAlign: TextAlign.center,
          ),
        ))
        ..add(Container(
          color: Colors.black38,
          child: Text(
            userInfo.nickname ?? '',
            textAlign: TextAlign.center,
          ),
        ))
        ..add(Container(
          color: Colors.black38,
          child: Text(
            userInfo.sex ?? '',
            textAlign: TextAlign.center,
          ),
        ))
        ..add(Container(
          color: Colors.black38,
          child: Text(
            userInfo.address ?? '',
            textAlign: TextAlign.center,
          ),
        ));
      columnsList.add(TableRow(children: rowWidget));
    });
    return columnsList;
  }
}
