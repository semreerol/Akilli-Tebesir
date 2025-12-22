import 'package:hive/hive.dart';

part 'teacher.g.dart';

@HiveType(typeId: 1)
class Teacher extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String password;

  @HiveField(2)
  late String name;

  Teacher({
    required this.username,
    required this.password,
    required this.name,
  });
}