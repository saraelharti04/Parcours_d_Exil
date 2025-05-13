const mongoose = require('mongoose');

const ActivitySchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  date: { type: String, required: true },   // format YYYY-MM-DD
  time: { type: String, required: true },   // format HH:mm
  genre: {
    type: String,
    enum: ['Homme', 'Femme', 'Autre', 'Tous'],
    required: true
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Activity', ActivitySchema);
