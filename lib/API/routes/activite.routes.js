const express = require('express');
const router = express.Router();
const Activite = require('../models/activity.model.js');

// Route publique : récupérer toutes les activités
router.get('/', async (req, res) => {
  try {
    const activites = await Activite.find();
    res.json(activites);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;