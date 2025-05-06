const mongoose = require('mongoose');

const rappelOrdonnanceSchema = new mongoose.Schema({
  utilisateur_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Utilisateur' },
  ordonnance_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Ordonnance' },
  date_heure: Date
});

module.exports = mongoose.model('RappelOrdonnance', rappelOrdonnanceSchema);