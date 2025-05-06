import 'package:sembast/sembast.dart';
import 'models/notification.dart';

class NotificationDao {
  static const String STORE_NAME = 'notifications';
  final _notificationStore = intMapStoreFactory.store(STORE_NAME);

  // Référence à la base de données
  final Database database;

  NotificationDao(this.database);

  // Insérer une notification
  Future<void> insert(Notification notification) async {
    await _notificationStore.add(database, notification.toMap());
  }

  // Mettre à jour une notification
  Future<void> update(Notification notification) async {
    final finder = Finder(filter: Filter.byKey(notification.id));
    await _notificationStore.update(database, notification.toMap(), finder: finder);
  }

  // Supprimer une notification
  Future<void> delete(Notification notification) async {
    final finder = Finder(filter: Filter.byKey(notification.id));
    await _notificationStore.delete(database, finder: finder);
  }

  // Récupérer une notification par ID
  Future<Notification?> getById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _notificationStore.findFirst(database, finder: finder);
    return recordSnapshot != null ? Notification.fromMap(recordSnapshot.value) : null;
  }

  // Récupérer toutes les notifications
  Future<List<Notification>> getAll() async {
    final recordSnapshots = await _notificationStore.find(database);
    return recordSnapshots.map((snapshot) => Notification.fromMap(snapshot.value)).toList();
  }
}