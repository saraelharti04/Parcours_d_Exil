const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader) return res.status(401).json({ message: 'Token manquant' });

    const token = authHeader.split(' ')[1];

    try {
        const decoded = jwt.verify(token, 'ton_secret_key');
        req.user = decoded; // On stocke les infos de l'user ici
        next();
    } catch (err) {
        return res.status(403).json({ message: 'Token invalide' });
    }
};

// Vérifie si le user est un thérapeute
const isTherapist = (req, res, next) => {
    if (req.user.type !== 'thérapeute') {
        return res.status(403).json({ message: 'Accès réservé aux thérapeutes' });
    }
    next();
};

module.exports = { verifyToken, isTherapist };