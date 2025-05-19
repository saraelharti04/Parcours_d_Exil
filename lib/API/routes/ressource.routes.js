const express = require('express');
const Ressource = require('../models/ressource.model');
const router = express.Router();

// Route POST pour ajouter une ressource
router.post('/add_ressource', async (req, res) => {
  try {
    const {
      id,
      titre,
      type,
      categorie,
      sousCategorie,
      fichier,
      audioFR,
      audioEN,
      image
    } = req.body;

    if (!titre || !type || !categorie || !sousCategorie || !fichier) {
      return res.status(400).json({ message: 'Champs requis manquants.' });
    }

    const newRessource = new Ressource({
      id,
      titre,
      type,
      categorie,
      sousCategorie,
      fichier,   // Chemins Appwrite ou ID fichier
      audioFR,
      audioEN,
      image
    });

    await newRessource.save();

    res.status(201).json({
      message: 'Ressource ajoutée avec succès',
      data: newRessource
    });
  } catch (error) {
    console.error('Erreur lors de l\'ajout de la ressource :', error);
    res.status(500).json({
      message: 'Erreur serveur lors de l\'ajout de la ressource',
      error
    });
  }
});

router.get('/download/:id', async (req, res) => {
  const client = new sdk.Client()
    .setEndpoint('https://fra.cloud.appwrite.io/v1')
    .setProject('6825cc670032c4d0b58e')

  const storage = new sdk.Storage(client);

  try {
    const stream = await storage.getFileDownload('6825cfaf00103670137a', req.params.id);
    stream.pipe(res);
  } catch (err) {
    console.error('Erreur Appwrite:', err);
    res.status(500).json({ error: 'Téléchargement échoué' });
  }
});

// Route GET pour récupérer toutes les ressources
router.get('/all', async (req, res) => {
  try {
    const ressources = await Ressource.find();
    if (!ressources.length) {
      return res.status(404).json({ message: 'Aucune ressource trouvée.' });
    }
    res.status(200).json(ressources);
  } catch (error) {
    console.error('Erreur lors de la récupération des ressources :', error);
    res.status(500).json({
      message: 'Erreur serveur lors de la récupération des ressources.',
      error
    });
  }
});

// Route GET pour récupérer une ressource par ID
router.get('/get_ressource/:id', async (req, res) => {
  try {
    const ressource = await Ressource.findById(req.params.id);
    if (!ressource) {
      return res.status(404).json({ message: 'Ressource non trouvée' });
    }
    res.status(200).json(ressource);
  } catch (error) {
    console.error('Erreur lors de la récupération de la ressource :', error);
    res.status(500).json({
      message: 'Erreur serveur lors de la récupération de la ressource',
      error
    });
  }
});

module.exports = router;
