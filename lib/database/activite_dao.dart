import 'package:sembast/sembast.dart';
import '../models/activite.dart';

class ActiviteDao {
  static const String STORE_NAME = 'activites';
  final _store = intMapStoreFactory.store(STORE_NAME);

  final Database database;
  ActiviteDao(this.database);

  Future<void> insert(Activite activite) async {
    await _store.add(database, activite.toMap());
  }

  Future<List<Activite>> getAll() async {
    final records = await _store.find(database);
    return records.map((snapshot) => Activite.fromMap(snapshot.value)).toList();
  }

  Future<void> deleteAll() async {
    await _store.delete(database);
  }
}
