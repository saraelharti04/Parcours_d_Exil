const express = require('express');
const router = express.Router();
const Ordonnance = require('../models/ordonnance.model.js');
const { verifyToken } = require('.auth.middleware.js');
// GET toutes les ordonnances du patient connecté
router.get('/', verifyToken, async (req, res) => {
  try {
    const ordonnances = await Ordonnance.find({ utilisateur_id: req.user.id });
    res.json(ordonnances);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET une ordonnance spécifique (accès restreint)
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const ordonnance = await Ordonnance.findById(req.params.id);
    if (!ordonnance || ordonnance.utilisateur_id.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Accès non autorisé' });
    }
    res.json(ordonnance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST une nouvelle ordonnance (réservé aux thérapeutes)
router.post('/', verifyToken, async (req, res) => {
  if (req.user.type !== 'thérapeute') {
    return res.status(403).json({ message: 'Seuls les thérapeutes peuvent créer une ordonnance' });
  }
  try {
    const ordonnance = new Ordonnance(req.body);
    await ordonnance.save();
    res.status(201).json(ordonnance);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// PUT mise à jour (réservée au propriétaire)
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const ordonnance = await Ordonnance.findById(req.params.id);
    if (!ordonnance || ordonnance.utilisateur_id.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Accès refusé' });
    }
    Object.assign(ordonnance, req.body);
    await ordonnance.save();
    res.json(ordonnance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE une ordonnance (réservée au propriétaire)
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const ordonnance = await Ordonnance.findById(req.params.id);
    if (!ordonnance || ordonnance.utilisateur_id.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Accès refusé' });
    }
    await ordonnance.deleteOne();
    res.json({ message: 'Supprimée' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;