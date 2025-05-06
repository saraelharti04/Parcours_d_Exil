import 'package:sembast/sembast.dart';
import '../models/message.dart';

class MessageDao {
  static const String STORE_NAME = 'messages';
  final _store = intMapStoreFactory.store(STORE_NAME);

  final Database database;
  MessageDao(this.database);

  Future<void> insert(Message message) async {
    await _store.add(database, message.toMap());
  }

  Future<List<Message>> getMessagesForPatient(String patientId) async {
    final finder = Finder(filter: Filter.equals('patient_id', patientId));
    final recordSnapshots = await _store.find(database, finder: finder);
    return recordSnapshots.map((snapshot) => Message.fromMap(snapshot.value)).toList();
  }

  Future<List<Message>> getAllMessages() async {
    final records = await _store.find(database);
    return records.map((record) => Message.fromMap(record.value)).toList();
  }
}
