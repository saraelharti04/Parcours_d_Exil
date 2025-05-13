const express = require('express');
const router = express.Router();
const Activite = require('../models/activity.model.js');

// Route publique : récupérer toutes les activités

const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Activity = require('../models/Activity');

// middleware d'authentification
const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Token manquant' });

  try {
    const decoded = jwt.verify(token, 'ton_secret_key');
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Token invalide' });
  }
};

// POST /api/activities
router.post('/activities', authenticate, async (req, res) => {
  try {
    const { title, description, date, time, genre } = req.body;

    if (!title || !date || !time || !genre) {
      return res.status(400).json({ message: 'Champs requis manquants' });
    }

    const activity = new Activity({ title, description, date, time, genre });
    await activity.save();

    return res.status(201).json({ message: 'Activité créée avec succès' });
  } catch (err) {
    console.error('Erreur création activité:', err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;


module.exports = router;