import 'package:sembast/sembast.dart';
import 'models/activite.dart';

class ActiviteDao {
  static const String STORE_NAME = 'activites';
  final _activiteStore = intMapStoreFactory.store(STORE_NAME);

  // Référence à la base de données
  final Database database;

  ActiviteDao(this.database);

  // Insérer une activité
  Future<void> insert(Activite activite) async {
    await _activiteStore.add(database, activite.toMap());
  }

  // Mettre à jour une activité
  Future<void> update(Activite activite) async {
    final finder = Finder(filter: Filter.byKey(activite.id));
    await _activiteStore.update(database, activite.toMap(), finder: finder);
  }

  // Supprimer une activité
  Future<void> delete(Activite activite) async {
    final finder = Finder(filter: Filter.byKey(activite.id));
    await _activiteStore.delete(database, finder: finder);
  }

  // Récupérer une activité par ID
  Future<Activite?> getById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _activiteStore.findFirst(database, finder: finder);
    return recordSnapshot != null ? Activite.fromMap(recordSnapshot.value) : null;
  }

  // Récupérer toutes les activités
  Future<List<Activite>> getAll() async {
    final recordSnapshots = await _activiteStore.find(database);
    return recordSnapshots.map((snapshot) => Activite.fromMap(snapshot.value)).toList();
  }
}