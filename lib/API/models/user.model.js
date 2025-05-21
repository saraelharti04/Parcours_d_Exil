const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    username: String,
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
    },
    lastMessageIdSeen: {
      type: String,
      default: null,
    }
});

module.exports = mongoose.model('User', UserSchema);