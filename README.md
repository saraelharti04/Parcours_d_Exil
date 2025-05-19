## Installation locale

### Prérequis à avoir

- Flutter installé [`flutter.dev`](https://flutter.dev)
- Node.js et npm installés [`nodejs.org`](https://nodejs.org)

### Étapes pour faire tourner l'application

```bash
# Cloner le projet
git clone https://github.com/kinderSchokobon19/parcours_d_exil.git
cd parcours-exil

# Démarrer le backend
cd lib/API
npm install
npm run server

# Démarrer l'application mobile
cd ../..
flutter pub get
flutter run
