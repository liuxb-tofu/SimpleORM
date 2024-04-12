import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'db_generator.dart';

Builder dbBuilder(final BuilderOptions options) {

  print('config: ${options.config.toString()}');
  /// 将生成的provider定向到provider目录下，在yaml中设置会不生效
  BuilderOptions newOpt = const BuilderOptions({'build_extensions': {'^lib/db/entity/{{}}.dart': ["lib/db/dao/generated/base_{{}}_dao.dart"]}});
  newOpt = newOpt.overrideWith(options);
  return LibraryBuilder(DbGenerator(), generatedExtension: '.dart', options: newOpt);
}
