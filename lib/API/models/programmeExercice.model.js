const mongoose = require('mongoose');

const programmeExerciceSchema = new mongoose.Schema({
  utilisateur_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Utilisateur' },
  therapeute_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Therapeute' },
  titre: String,
  description: String,
  date_creation: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ProgrammeExercice', programmeExerciceSchema);