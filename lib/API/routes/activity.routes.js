const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Activity = require('../models/activity.model.js');


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

// GET /api/activities
router.get('/activities', authenticate, async (req, res) => {
  try {
    const activities = await Activity.find().sort({ date: 1 });
    return res.status(200).json(activities);
  } catch (err) {
    console.error('Erreur récupération activités:', err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;


module.exports = router;