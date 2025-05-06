import 'package:sembast/sembast.dart';
import '../models/therapeute.dart';

class TherapeuteDao {
  static const String STORE_NAME = 'therapeutes';
  final _store = intMapStoreFactory.store(STORE_NAME);

  final Database database;
  TherapeuteDao(this.database);

  Future<void> insert(Therapeute therapeute) async {
    await _store.add(database, therapeute.toMap());
  }

  Future<Therapeute?> getByNumeroId(String numeroId) async {
    final finder = Finder(filter: Filter.equals('numero_id', numeroId));
    final recordSnapshot = await _store.findFirst(database, finder: finder);
    return recordSnapshot != null ? Therapeute.fromMap(recordSnapshot.value) : null;
  }
}
