const express = require('express');
const router = express.Router();
const Exercice = require('../models/exercice.model.js');
const { verifyToken } = require('.auth.middleware.js');

router.get('/programme/:programmeId', verifyToken, async (req, res) => {
  try {
    const exercices = await Exercice.find({ programme_id: req.params.programmeId });
    res.json(exercices);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;