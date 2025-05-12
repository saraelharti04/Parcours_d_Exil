const express = require('express');
const multer = require('multer');
const path = require('path');
const Ressource = require('../models/ressource.model');
const router = express.Router();

// Configuration du stockage de Multer
const storage = multer.memoryStorage(); // Stockage en mémoire pour traiter en base64

const upload = multer({ storage: storage });

// Route pour ajouter une ressource
router.post('/add_ressource', upload.single('data'), async (req, res) => {
  try {
    const { titre, description, type, categorie, sousCategorie } = req.body;

    if (!req.file) {
      return res.status(400).json({ message: 'Aucun fichier n\'a été téléchargé' });
    }

    // Convertir le fichier en base64
    const fileData = req.file.buffer.toString('base64');

    // Créer la ressource avec les données du fichier
    const newRessource = new Ressource({
      titre,
      description,
      type,
      categorie,
      sousCategorie,
      data: fileData,  // Stocker le fichier en base64
    });

    // Sauvegarder la ressource dans la base de données
    await newRessource.save();

    return res.status(201).json({ message: 'Ressource ajoutée avec succès', data: newRessource });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Erreur serveur lors de l\'ajout de la ressource', error });
  }
});


router.get('/get_ressource/:id', async (req, res) => {
  try {
    const ressource = await Ressource.findById(req.params.id);

    if (!ressource) {
      return res.status(404).json({ message: 'Ressource non trouvée' });
    }

    const fileData = ressource.data; // Donnée en base64

    // Déterminer le type du fichier (image, vidéo, audio, etc.)
    const fileType = ressource.type; // Assurez-vous que "type" est correctement défini

    // Définir les headers en fonction du type de fichier
    res.setHeader('Content-Type', fileType);

    // Définir la réponse comme un fichier
    const buffer = Buffer.from(fileData, 'base64');

    // Envoyer le fichier en réponse
    res.send(buffer);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Erreur serveur lors de la récupération de la ressource', error });
  }
});

module.exports = router;
