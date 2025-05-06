import 'package:sembast/sembast.dart';
import '../models/patient.dart';

class PatientDao {
  static const String storeName = 'patients';
  final _store = intMapStoreFactory.store(storeName);
  final Database db;

  PatientDao(this.db);

  Future<void> insert(Patient patient) async {
    await _store.add(db, patient.toMap());
  }

  Future<Patient?> getByNumeroId(String numeroId) async {
    final finder = Finder(filter: Filter.equals('numero_id', numeroId));
    final record = await _store.findFirst(db, finder: finder);
    return record != null ? Patient.fromMap(record.value) : null;
  }

  Future<List<Patient>> getAll() async {
    final records = await _store.find(db);
    return records.map((e) => Patient.fromMap(e.value)).toList();
  }
}
