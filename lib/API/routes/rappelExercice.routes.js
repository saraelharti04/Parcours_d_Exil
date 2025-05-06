const express = require('express');
const router = express.Router();
const RappelExercice = require('../models/rappelExercice.model.js');
const { verifyToken } = require('.auth.middleware.js');

router.get('/', verifyToken, async (req, res) => {
  try {
    const rappels = await RappelExercice.find({ utilisateur_id: req.user.id });
    res.json(rappels);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;