
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'user_dao.dart';
import 'therapeute_dao.dart';
import 'activity_dao.dart';
import 'notification_dao.dart';
import 'programme_exercice_dao.dart';
import 'exercice_dao.dart';
import 'rappel_exercice_dao.dart';
import 'ordonnance_dao.dart';
import 'rappel_ordonnance_dao.dart';


class AppDatabase {
  static final AppDatabase _singleton = AppDatabase._();
  static AppDatabase get instance => _singleton;

  Completer<Database>? _dbOpenCompleter;

  // Instances des DAO
  late UtilisateurDao utilisateurDao;
  /*late TherapeuteDao therapeuteDao;
  late ActiviteDao activiteDao;
  late NotificationDao notificationDao;
  late ProgrammeExerciceDao programmeExerciceDao;
  late ExerciceDao exerciceDao;
  late RappelExerciceDao rappelExerciceDao;
  late OrdonnanceDao ordonnanceDao;
  late RappelOrdonnanceDao rappelOrdonnanceDao;*/

  AppDatabase._();

  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      await _openDatabase();
    }
    return _dbOpenCompleter!.future;
  }

  Future<void> _openDatabase() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, 'demo.db');
    final database = await databaseFactoryIo.openDatabase(dbPath);

    // Initialiser les DAO avec l'instance de la base de données
    utilisateurDao = UtilisateurDao(database);
    therapeuteDao = TherapeuteDao(database);
    activiteDao = ActiviteDao(database);
    notificationDao = NotificationDao(database);
    programmeExerciceDao = ProgrammeExerciceDao(database);
    exerciceDao = ExerciceDao(database);
    rappelExerciceDao = RappelExerciceDao(database);
    ordonnanceDao = OrdonnanceDao(database);
    rappelOrdonnanceDao = RappelOrdonnanceDao(database);

    _dbOpenCompleter!.complete(database);
  }
}