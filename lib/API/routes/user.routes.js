const express = require('express');
const router = express.Router();
const User = require('../models/user.model.js');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const { verifyToken, isTherapist } = require('./auth.middleware');

// Route pour récupérer les utilisateurs (uniquement pour les thérapeutes)
router.get('/users', verifyToken, isTherapist, async (req, res) => {
    try {
        const users = await User.find();
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Route pour l'enregistrement d'un nouvel utilisateur
router.post('/register', async (req, res) => {
    try {
        const { name, email, password, type } = req.body;

        // Vérifier si l'utilisateur existe déjà
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "L'utilisateur existe déjà" });
        }

        // Hachage du mot de passe
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({ name, email, password: hashedPassword, type });
        await newUser.save();

        // Générer le token JWT
        const token = jwt.sign(
            { id: newUser._id, type: newUser.type },
            'ton_secret_key',  // Remplace par process.env.JWT_SECRET pour plus de sécurité
            { expiresIn: '2h' }
        );

        res.status(201).json({
            message: 'Utilisateur enregistré avec succès',
            token,
            user: { id: newUser._id, name: newUser.name, email: newUser.email, type: newUser.type }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Route pour la connexion
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) return res.status(401).json({ message: 'Mot de passe incorrect' });

        // Générer le token JWT
        const token = jwt.sign(
            { id: user._id, type: user.type },
            'ton_secret_key', 
            { expiresIn: '2h' }
        );

        res.json({ token, user: { id: user._id, name: user.name, type: user.type } });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;