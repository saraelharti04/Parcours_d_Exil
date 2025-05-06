const express = require('express');
const router = express.Router();
const Notification = require('../models/notification.model.js');
const { verifyToken } = require('.auth.middleware.js');

router.get('/', verifyToken, async (req, res) => {
  try {
    const notifications = await Notification.find({ utilisateur_id: req.user.id });
    res.json(notifications);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;