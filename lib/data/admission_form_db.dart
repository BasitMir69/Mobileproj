import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'admission_form.dart';

class AdmissionFormDb {
  static final AdmissionFormDb instance = AdmissionFormDb._();
  AdmissionFormDb._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'admissions.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE admission_forms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            parentName TEXT NOT NULL,
            parentEmail TEXT NOT NULL,
            phone TEXT NOT NULL,
            childName TEXT NOT NULL,
            childDob TEXT NOT NULL,
            gradeApplying TEXT NOT NULL,
            campus TEXT NOT NULL,
            notes TEXT NOT NULL,
            gender TEXT NOT NULL,
            documentPath TEXT,
            status TEXT NOT NULL DEFAULT 'pending',
            testDate TEXT
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE admission_forms ADD COLUMN gender TEXT NOT NULL DEFAULT ''");
          await db.execute(
              "ALTER TABLE admission_forms ADD COLUMN documentPath TEXT");
          await db.execute(
              "ALTER TABLE admission_forms ADD COLUMN status TEXT NOT NULL DEFAULT 'pending'");
          await db
              .execute("ALTER TABLE admission_forms ADD COLUMN testDate TEXT");
        }
      },
    );
    return _db!;
  }

  Future<int> insert(AdmissionForm form) async {
    final db = await database;
    return db.insert('admission_forms', form.toMap());
  }

  Future<List<AdmissionForm>> all() async {
    final db = await database;
    final maps = await db.query('admission_forms', orderBy: 'id DESC');
    return maps.map((m) => AdmissionForm.fromMap(m)).toList();
  }

  Future<int> updateStatus(int id, String status, {String? testDate}) async {
    final db = await database;
    return db.update(
      'admission_forms',
      {
        'status': status,
        'testDate': testDate,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('admission_forms', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('admission_forms');
  }
}
