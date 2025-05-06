const mongoose = require('mongoose');

const exerciceSchema = new mongoose.Schema({
  programme_id: { type: mongoose.Schema.Types.ObjectId, ref: 'ProgrammeExercice' },
  nom: String,
  duree: Number, // secondes
  repetitions: Number,
  ordre: Number
});

module.exports = mongoose.model('Exercice', exerciceSchema);