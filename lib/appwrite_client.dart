import 'package:appwrite/appwrite.dart';

class AppwriteClient {
  final Client client;
  final Storage storage;

  AppwriteClient() :
        client = Client()
            .setEndpoint('https://fra.cloud.appwrite.io/v1') // Remplacez par votre endpoint Appwrite
            .setProject('6825cc670032c4d0b58e')     // Remplacez par votre ID de projet Appwrite
            .setSelfSigned(),                  // Utilisez cette ligne si vous utilisez un certificat auto-signé
        storage = Storage(Client()
            .setEndpoint('https://fra.cloud.appwrite.io/v1')
            .setProject('6825cc670032c4d0b58e')
            .setSelfSigned());

}