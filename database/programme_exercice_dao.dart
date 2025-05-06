import 'package:sembast/sembast.dart';
import 'models/programme_exercice.dart';

class ProgrammeExerciceDao {
  static const String STORE_NAME = 'programmes_exercices';
  final _programmeExerciceStore = intMapStoreFactory.store(STORE_NAME);

  // Référence à la base de données
  final Database database;

  ProgrammeExerciceDao(this.database);

  // Insérer un programme d'exercice
  Future<void> insert(ProgrammeExercice programmeExercice) async {
    await _programmeExerciceStore.add(database, programmeExercice.toMap());
  }

  // Mettre à jour un programme d'exercice
  Future<void> update(ProgrammeExercice programmeExercice) async {
    final finder = Finder(filter: Filter.byKey(programmeExercice.id));
    await _programmeExerciceStore.update(database, programmeExercice.toMap(), finder: finder);
  }

  // Supprimer un programme d'exercice
  Future<void> delete(ProgrammeExercice programmeExercice) async {
    final finder = Finder(filter: Filter.byKey(programmeExercice.id));
    await _programmeExerciceStore.delete(database, finder: finder);
  }

  // Récupérer un programme d'exercice par ID
  Future<ProgrammeExercice?> getById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _programmeExerciceStore.findFirst(database, finder: finder);
    return recordSnapshot != null ? ProgrammeExercice.fromMap(recordSnapshot.value) : null;
  }

  // Récupérer tous les programmes d'exercices
  Future<List<ProgrammeExercice>> getAll() async {
    final recordSnapshots = await _programmeExerciceStore.find(database);
    return recordSnapshots.map((snapshot) => ProgrammeExercice.fromMap(snapshot.value)).toList();
  }
}
DAO pour Exercice
Copier
import 'package:sembast/sembast.dart';
import 'exercice.dart';

class ExerciceDao {
  static const String STORE_NAME = 'exercices';
  final _exerciceStore = intMapStoreFactory.store(STORE_NAME);

  // Référence à la base de données
  final Database database;

  ExerciceDao(this.database);

  // Insérer un exercice
  Future<void> insert(Exercice exercice) async {
    await _exerciceStore.add(database, exercice.toMap());
  }

  // Mettre à jour un exercice
  Future<void> update(Exercice exercice) async {
    final finder = Finder(filter: Filter.byKey(exercice.id));
    await _exerciceStore.update(database, exercice.toMap(), finder: finder);
  }

  // Supprimer un exercice
  Future<void> delete(Exercice exercice) async {
    final finder = Finder(filter: Filter.byKey(exercice.id));
    await _exerciceStore.delete(database, finder: finder);
  }

  // Récupérer un exercice par ID
  Future<Exercice?> getById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _exerciceStore.findFirst(database, finder: finder);
    return recordSnapshot != null ? Exercice.fromMap(recordSnapshot.value) : null;
  }

  // Récupérer tous les exercices
  Future<List<Exercice>> getAll() async {
    final recordSnapshots = await _exerciceStore.find(database);
    return recordSnapshots.map((snapshot) => Exercice.fromMap(snapshot.value)).toList();
  }
}