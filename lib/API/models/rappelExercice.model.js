const mongoose = require('mongoose');

const rappelExerciceSchema = new mongoose.Schema({
  utilisateur_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Utilisateur' },
  exercice_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Exercice' },
  date_heure: Date
});

module.exports = mongoose.model('RappelExercice', rappelExerciceSchema);