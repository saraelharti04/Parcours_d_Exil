const mongoose = require('mongoose');

const ordonnanceSchema = new mongoose.Schema({
  utilisateur_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Utilisateur' },
  therapeute_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Therapeute' },
  medicament: String,
  posologie: String,
  date_prescription: Date
});

module.exports = mongoose.model('Ordonnance', ordonnanceSchema);