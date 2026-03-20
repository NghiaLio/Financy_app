// ignore_for_file: file_names

import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:hive/hive.dart';
part 'AI_settings.g.dart';

@HiveType(typeId: 10)
class AiSettings extends HiveObject {
  @HiveField(0)
  bool isConfirm;

  @HiveField(1)
  MoneySource? defaultMoneySource;

  AiSettings({this.isConfirm = true, this.defaultMoneySource});

  AiSettings copyWith({bool? isConfirm, MoneySource? defaultMoneySource}) {
    return AiSettings(
      isConfirm: isConfirm ?? this.isConfirm,
      defaultMoneySource: defaultMoneySource ?? this.defaultMoneySource,
    );
  }
}
