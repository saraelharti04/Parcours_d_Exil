const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: String,
    email: String,
    password: String,
    genre : String,
    type: {
        type: String,
        enum: {
            values: ['thérapeute', 'patient'],
            message: '{VALUE} n\'est pas un type valide. Utilisez "thérapeute" ou "patient".'
        },
        default: 'patient',
        required: true
    }
});

module.exports = mongoose.model('User', UserSchema);