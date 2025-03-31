import 'package:sembast/sembast.dart';
import 'models/rappel_exercice.dart';

class RappelExerciceDao {
  static const String STORE_NAME = 'rappels_exercices';
  final _rappelExerciceStore = intMapStoreFactory.store(STORE_NAME);

  // Référence à la base de données
  final Database database;

  RappelExerciceDao(this.database);

  // Insérer un rappel d'exercice
  Future<void> insert(RappelExercice rappelExercice) async {
    await _rappelExerciceStore.add(database, rappelExercice.toMap());
  }

  // Mettre à jour un rappel d'exercice
  Future<void> update(RappelExercice rappelExercice) async {
    final finder = Finder(filter: Filter.byKey(rappelExercice.id));
    await _rappelExerciceStore.update(database, rappelExercice.toMap(), finder: finder);
  }

  // Supprimer un rappel d'exercice
  Future<void> delete(RappelExercice rappelExercice) async {
    final finder = Finder(filter: Filter.byKey(rappelExercice.id));
    await _rappelExerciceStore.delete(database, finder: finder);
  }

  // Récupérer un rappel d'exercice par ID
  Future<RappelExercice?> getById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _rappelExerciceStore.findFirst(database, finder: finder);
    return recordSnapshot != null ? RappelExercice.fromMap(recordSnapshot.value) : null;
  }

  // Récupérer tous les rappels d'exercices
  Future<List<RappelExercice>> getAll() async {
    final recordSnapshots = await _rappelExerciceStore.find(database);
    return recordSnapshots.map((snapshot) => RappelExercice.fromMap(snapshot.value)).toList();
  }
}