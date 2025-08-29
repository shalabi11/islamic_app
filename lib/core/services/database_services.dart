import 'package:islamic_app/features/prayer_times/data/model/prayer_time_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'islamic_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE prayer_times(
        location_key TEXT PRIMARY KEY, -- ✅ التعديل هنا: مفتاح فريد لكل موقع وتاريخ
        date TEXT NOT NULL,
        fajr TEXT NOT NULL,
        sunrise TEXT NOT NULL,
        dhuhr TEXT NOT NULL,
        asr TEXT NOT NULL,
        maghrib TEXT NOT NULL,
        isha TEXT NOT NULL
      )
    ''');
  }

  // الدالة الآن تستقبل مفتاحاً فريداً
  Future<void> insertPrayerTimes(
    String locationKey,
    String date,
    PrayerTimeModel prayerTimes,
  ) async {
    final db = await database;
    await db.insert('prayer_times', {
      'location_key': locationKey,
      'date': date,
      'fajr': prayerTimes.fajr,
      'sunrise': prayerTimes.sunrise,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // الدالة الآن تبحث باستخدام المفتاح الفريد
  Future<PrayerTimeModel?> getPrayerTimes(String locationKey) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prayer_times',
      where: 'location_key = ?',
      whereArgs: [locationKey],
    );

    if (maps.isNotEmpty) {
      return PrayerTimeModel(
        fajr: maps[0]['fajr'],
        sunrise: maps[0]['sunrise'],
        dhuhr: maps[0]['dhuhr'],
        asr: maps[0]['asr'],
        maghrib: maps[0]['maghrib'],
        isha: maps[0]['isha'],
      );
    }
    return null;
  }
}
