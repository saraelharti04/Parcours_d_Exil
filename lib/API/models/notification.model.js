const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  utilisateur_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Utilisateur' },
  activite_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Activite', default: null },
  message: String,
  date_envoi: Date
});

module.exports = mongoose.model('Notification', notificationSchema);