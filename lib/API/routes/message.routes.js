const express = require('express');
const router = express.Router();
const Message = require('../models/message.model');
const User = require('../models/user.model');

// Middleware d'authentification supposé
const authenticate = require('../middleware/auth');

// Envoyer un message (uniquement si le sender est thérapeute)
router.post('/send', authenticate, async (req, res) => {
  try {
    const { receiverId, content } = req.body;

    const sender = req.user; // Utilisateur connecté

    if (sender.role !== 'thérapeute') {
      return res.status(403).json({ message: 'Seuls les thérapeutes peuvent envoyer des messages.' });
    }

    const receiver = await User.findById(receiverId);
    if (!receiver || receiver.role !== 'patient') {
      return res.status(400).json({ message: 'Destinataire invalide (doit être un patient).' });
    }

    const message = new Message({
      sender: sender._id,
      receiver: receiverId,
      content
    });

    await message.save();

    res.status(201).json({ message: 'Message envoyé avec succès.', data: message });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur.', error });
  }
});

// Récupérer les messages reçus par l'utilisateur connecté
router.get('/received', authenticate, async (req, res) => {
  try {
    const messages = await Message.find({ receiver: req.user._id })
      .populate('sender', 'name role')
      .sort({ sentAt: -1 });

    res.status(200).json({ messages });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur.', error });
  }
});

module.exports = router;
