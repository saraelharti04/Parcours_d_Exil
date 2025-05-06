import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import '../models/patient.dart';
import '../models/therapeute.dart';
import '../models/message.dart';
import '../models/activite.dart';
import '../models/ressource.dart';

import 'patient_dao.dart';
import 'therapeute_dao.dart';
import 'message_dao.dart';
import 'activite_dao.dart';
import 'ressource_dao.dart';

class AppDatabase {
  static final AppDatabase _singleton = AppDatabase._internal();
  late Database _db;

  late PatientDao patientDao;
  late TherapeuteDao therapeuteDao;
  late MessageDao messageDao;
  late ActiviteDao activiteDao;
  late RessourceDao ressourceDao;

  AppDatabase._internal();

  factory AppDatabase() {
    return _singleton;
  }

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/parcours_exil.db';
    _db = await databaseFactoryIo.openDatabase(dbPath);

    patientDao = PatientDao(_db);
    therapeuteDao = TherapeuteDao(_db);
    messageDao = MessageDao(_db);
    activiteDao = ActiviteDao(_db);
    ressourceDao = RessourceDao(_db);
  }

  Database get database => _db;
}
