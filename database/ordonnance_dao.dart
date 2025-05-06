import 'package:sembast/sembast.dart';
import 'models/ordonnance.dart';

class OrdonnanceDao {
  static const String STORE_NAME = 'ordonnances';
  final _ordonnanceStore = intMapStoreFactory.store(STORE_NAME);

  // Référence à la base de données
  final Database database;

  OrdonnanceDao(this.database);

  // Insérer une ordonnance
  Future<void> insert(Ordonnance ordonnance) async {
    await _ordonnanceStore.add(database, ordonnance.toMap());
  }

  // Mettre à jour une ordonnance
  Future<void> update(Ordonnance ordonnance) async {
    final finder = Finder(filter: Filter.byKey(ordonnance.id));
    await _ordonnanceStore.update(database, ordonnance.toMap(), finder: finder);
  }

  // Supprimer une ordonnance
  Future<void> delete(Ordonnance ordonnance) async {
    final finder = Finder(filter: Filter.byKey(ordonnance.id));
    await _ordonnanceStore.delete(database, finder: finder);
  }

  // Récupérer une ordonnance par ID
  Future<Ordonnance?> getById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _ordonnanceStore.findFirst(database, finder: finder);
    return recordSnapshot != null ? Ordonnance.fromMap(recordSnapshot.value) : null;
  }

  // Récupérer toutes les ordonnances
  Future<List<Ordonnance>> getAll() async {
    final recordSnapshots = await _ordonnanceStore.find(database);
    return recordSnapshots.map((snapshot) => Ordonnance.fromMap(snapshot.value)).toList();
  }
}