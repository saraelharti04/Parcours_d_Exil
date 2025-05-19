const mongoose = require('mongoose');

const ressourceSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true }, // Identifiant unique (optionnel, sinon _id fait l’affaire)
  titre: { type: String, required: true },
  type: { type: String, required: true }, // pdf, audio, video
  fichier: { type: String, required: true }, // URL ou identifiant du fichier dans Appwrite
  audioFR: { type: String, default: '' }, // optionnel
  audioEN: { type: String, default: '' }, // optionnel
  image: { type: String, default: '' }, // optionnel
  categorie: { type: String, required: true },
  sousCategorie: { type: String, required: true },
});

const Ressource = mongoose.model('Ressource', ressourceSchema);

module.exports = Ressource;
