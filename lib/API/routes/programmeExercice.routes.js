const express = require('express');
const router = express.Router();
const ProgrammeExercice = require('../models/programmeExercice.model.js');
const { verifyToken } = require('.auth.middleware.model.js');

router.get('/', verifyToken, async (req, res) => {
  try {
    const programmes = await ProgrammeExercice.find({ utilisateur_id: req.user.id });
    res.json(programmes);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;