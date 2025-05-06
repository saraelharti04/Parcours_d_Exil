const express = require('express');
const router = express.Router();
const RappelOrdonnance = require('../models/rappelOrdonnance.model.js');
const { verifyToken } = require('.auth.middleware.js');

router.get('/', verifyToken, async (req, res) => {
  try {
    const rappels = await RappelOrdonnance.find({ utilisateur_id: req.user.id });
    res.json(rappels);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;