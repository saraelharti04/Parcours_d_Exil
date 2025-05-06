import 'package:sembast/sembast.dart';
import 'models/rappel_ordonnance.dart';

class RappelOrdonnanceDao {
  static const String STORE_NAME = 'rappels_ordonnances';
  final _rappelOrdonnanceStore = intMapStoreFactory.store(STORE_NAME);

  // Référence à la base de données
  final Database database;

  RappelOrdonnanceDao(this.database);

  // Insérer un rappel d'ordonnance
  Future<void> insert(RappelOrdonnance rappelOrdonnance) async {
    await _rappelOrdonnanceStore.add(database, rappelOrdonnance.toMap());
  }

  // Mettre à jour un rappel d'ordonnance
  Future<void> update(RappelOrdonnance rappelOrdonnance) async {
    final finder = Finder(filter: Filter.byKey(rappelOrdonnance.id));
    await _rappelOrdonnanceStore.update(database, rappelOrdonnance.toMap(), finder: finder);
  }

  // Supprimer un rappel d'ordonnance
  Future<void> delete(RappelOrdonnance rappelOrdonnance) async {
    final finder = Finder(filter: Filter.byKey(rappelOrdonnance.id));
    await _rappelOrdonnanceStore.delete(database, finder: finder);
  }

  // Récupérer un rappel d'ordonnance par ID
  Future<RappelOrdonnance?> getById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _rappelOrdonnanceStore.findFirst(database, finder: finder);
    return recordSnapshot != null ? RappelOrdonnance.fromMap(recordSnapshot.value) : null;
  }

  // Récupérer tous les rappels d'ordonnances
  Future<List<RappelOrdonnance>> getAll() async {
    final recordSnapshots = await _rappelOrdonnanceStore.find(database);
    return recordSnapshots.map((snapshot) => RappelOrdonnance.fromMap(snapshot.value)).toList();
  }
}