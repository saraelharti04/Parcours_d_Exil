import 'package:sembast/sembast.dart';
import 'package:application_parcours_d_exil/models/ressource.dart';

class RessourceDao {
  static const String storeName = 'ressources';
  final _store = stringMapStoreFactory.store(storeName);

  final Database database;
  RessourceDao(this.database);

  Future<void> insert(Ressource ressource) async {
    await _store.record(ressource.id).put(database, ressource.toMap());
  }

  Future<List<Ressource>> getAll() async {
    final records = await _store.find(database);
    return records.map((snap) => Ressource.fromMap(snap.value)).toList();
  }
}



