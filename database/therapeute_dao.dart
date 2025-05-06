import 'package:sembast/sembast.dart';
import 'models/utilisateur.dart';

class UtilisateurDao {
  static const String STORE_NAME = 'utilisateurs';
  final _utilisateurStore = intMapStoreFactory.store(STORE_NAME);

  // Référence à la base de données
  final Database database;

  UtilisateurDao(this.database);

  // Insérer un utilisateur
  Future<void> insert(Utilisateur utilisateur) async {
    await _utilisateurStore.add(database, utilisateur.toMap());
  }

  // Mettre à jour un utilisateur
  Future<void> update(Utilisateur utilisateur) async {
    final finder = Finder(filter: Filter.byKey(utilisateur.id));
    await _utilisateurStore.update(database, utilisateur.toMap(), finder: finder);
  }

  // Supprimer un utilisateur
  Future<void> delete(Utilisateur utilisateur) async {
    final finder = Finder(filter: Filter.byKey(utilisateur.id));
    await _utilisateurStore.delete(database, finder: finder);
  }

  // Récupérer un utilisateur par ID
  Future<Utilisateur?> getById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _utilisateurStore.findFirst(database, finder: finder);
    return recordSnapshot != null ? Utilisateur.fromMap(recordSnapshot.value) : null;
  }

  // Récupérer tous les utilisateurs
  Future<List<Utilisateur>> getAll() async {
    final recordSnapshots = await _utilisateurStore.find(database);
    return recordSnapshots.map((snapshot) => Utilisateur.fromMap(snapshot.value)).toList();
  }
}