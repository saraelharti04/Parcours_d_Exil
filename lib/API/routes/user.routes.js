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
// Route pour l'enregistrement d'un nouvel utilisateur
router.post('/register', async (req, res) => {
  try {
    const { username, password, type, genre } = req.body;

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: "L'utilisateur existe déjà" });
    }

    // Hachage du mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Création du nouvel utilisateur avec genre
    const newUser = new User({
      username,
      password: hashedPassword,
      type,
      genre,
    });

    await newUser.save();

    // Générer le token JWT
    const token = jwt.sign(
      { id: newUser._id, type: newUser.type },
      'ton_secret_key',  // Remplace par process.env.JWT_SECRET pour plus de sécurité
      { expiresIn: '2h' }
    );

    return res.status(200).json({
      message: 'Utilisateur enregistré avec succès',
      token,
      user: {
        id: newUser._id,
        username: newUser.username,
        type: newUser.type,
        genre: newUser.genre,
      }
    });
  } catch (error) {
    console.error('Erreur lors de l’enregistrement :', error);
    return res.status(500).json({ message: error.message });
  }
});


// Route pour la connexion
router.post('/login', async (req, res) => {
    const { username , password } = req.body;

    try {
        const user = await User.findOne({ username });
        if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) return res.status(401).json({ message: 'Mot de passe incorrect' });

        // Générer le token JWT
        const token = jwt.sign(
            { id: user._id, type: user.type },
            'ton_secret_key', 
            { expiresIn: '2h' }
        );

        res.status(200).json({
              message: 'Connexion réussie',
              token,
              type: user.type,
              user: {
                id: user._id,
                username: user.username
              }
            });
          } catch (error) {
        res.status(500).json({ message: error.message });
        }
});

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

// route pour renvoyer les infos du compte connecté
router.get('/me', authenticate, async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

  res.json({
    username: user.username,
    genre: user.genre || '',
  });
});

module.exports = router;