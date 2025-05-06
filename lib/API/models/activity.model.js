const mongoose = require('mongoose');

const activiteSchema = new mongoose.Schema({
  titre: String,
  description: String,
  date_heure: Date,
  type: { type: String, enum: ['Atelier', 'GAP', 'Musicothérapie'] }
});

module.exports = mongoose.model('Activite', activiteSchema);