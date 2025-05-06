const express = require('express');
const Message = require('../models/message.model.js');
const User = require('../models/user.model.js');

const router = express.Router();

// ROUTE : Envoyer un message
router.post('/', async (req, res) => {
    try {
        const { senderId, receiverId, content } = req.body;

        const sender = await User.findById(senderId);
        const receiver = await User.findById(receiverId);

        if (!sender || !receiver) {
            return res.status(404).json({ message: "Utilisateur introuvable" });
        }

        const message = new Message({ sender: senderId, receiver: receiverId, content });
        await message.save();

        res.status(201).json(message);
    } catch (error) {
        res.status(500).json({ message: "Erreur serveur", error });
    }
});

// ROUTE : Récupérer les messages reçus par un patient
router.get('/:patientId', async (req, res) => {
    try {
        const { patientId } = req.params;

        const messages = await Message.find({ receiver: patientId })
            .populate('sender', 'email')  // ou 'name' si ton modèle User a un champ name
            .sort({ timestamp: -1 });

        res.status(200).json(messages);
    } catch (error) {
        res.status(500).json({ message: "Erreur serveur", error });
    }
});

module.exports = router;
