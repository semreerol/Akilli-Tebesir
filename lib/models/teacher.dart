import 'package:hive/hive.dart';

// Bu satır kod üretimi (code generation) için zorunludur.
// Dosya adıyla buradaki ismin aynı olduğundan emin ol.
part 'teacher.g.dart';

@HiveType(typeId: 1)
class Teacher extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String password;

  @HiveField(2)
  late String name; // "Yasemin Öğretmen" gibi isimler için

  Teacher({
    required this.username,
    required this.password,
    required this.name,
  });
}