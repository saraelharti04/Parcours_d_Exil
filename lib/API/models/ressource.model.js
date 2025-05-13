// ressource.model.js
const mongoose = require('mongoose');

const ressourceSchema = new mongoose.Schema({
  titre: { type: String, required: true },
  description: { type: String, required: true },
  data: { type: String, required: true },  // Le fichier encodé en Base64
  type: { type: String, required: true },  // 'image', 'video', ou 'audio'
  categorie: { type: String, required: true },
  sousCategorie: { type: String, required: true },
});

const Ressource = mongoose.model('Ressource', ressourceSchema);

module.exports = Ressource;
