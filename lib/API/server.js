const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const userRoutes = require('./routes/user.routes.js');
const messageRoutes = require('./routes/message.routes.js');
const activityRoutes = require('./routes/activity.routes.js');

const ressourcesRoutes = require('./routes/ressource.routes.js');
const User = require('./models/user.model.js');

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

// Middleware de base
app.use(cors());
app.use(express.json());

// 🔤 Forcer l'encodage UTF-8 pour toutes les réponses
app.use((req, res, next) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  next();
});

// Connexion à MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('✅ Connexion à MongoDB réussie'))
  .catch((err) => console.error('❌ Erreur de connexion à MongoDB :', err));

// 🔗 Routes API
app.use('/api', userRoutes);
app.use('/api', activityRoutes);
app.use('/api/messages', messageRoutes);

app.use('/api/ressources', ressourcesRoutes);

// 🆕 Enregistrement d’un patient
app.post('/api/register', async (req, res) => {
  const { email, password, genre } = req.body;

  if (!email || !password || !genre) {
    return res.status(400).json({ message: 'Champs manquants' });
  }

  const existing = await User.findOne({ email });
  if (existing) {
    return res.status(409).json({ message: 'Ce compte existe déjà' });
  }

  const newUser = new User({ email, password, genre, type: 'patient' });
  await newUser.save();
  res.status(201).json({ message: 'Compte patient créé avec succès' });
});

// 🔐 Connexion utilisateur
app.post('/api/login', async (req, res) => {
  const { email, password, type } = req.body;

  const user = await User.findOne({ email });

  if (!user) return res.status(401).json({ message: 'Utilisateur non trouvé' });
  if (user.password !== password) return res.status(401).json({ message: 'Mot de passe incorrect' });
  if (user.type !== type) return res.status(403).json({ message: `Ce compte est un compte ${user.type}` });

  res.status(200).json({ message: 'Connexion réussie', type: user.type, userId: user._id });
});

// 🚀 Lancement du serveur
app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Serveur en écoute sur http://0.0.0.0:${port}`);
});
