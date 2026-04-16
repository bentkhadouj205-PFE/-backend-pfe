import User from '../models/User.js';

export const register = async (req, res, next) => {
  try {
    const { nom, prenom, nin, email, telephone, adresse, codePostal, password } = req.body;

    console.log('Inscription reçue:', email);

    const existingEmail = await User.findOne({ email });
    if (existingEmail) {
      return res.status(400).json({ success: false, message: 'Email déjà utilisé', field: 'email' });
    }

    const existingNIN = await User.findOne({ nin });
    if (existingNIN) {
      return res.status(400).json({ success: false, message: 'NIN déjà utilisé', field: 'nin' });
    }

    const user = new User({ nom, prenom, nin, email, telephone, adresse, codePostal, password });

    await user.crypterPassword();
    await user.save();

    console.log('Compte créé:', email);

    res.status(201).json({
      success: true,
      message: 'Compte créé avec succès',
      user: {
        id: user._id,
        nom: user.nom,
        prenom: user.prenom,
        email: user.email,
        telephone: user.telephone,
        adresse: user.adresse,
        nin: user.nin,
        role: user.role
      }
    });

  } catch (error) {
    console.error('Erreur inscription:', error);

    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ success: false, message: 'Erreur de validation', errors: messages });
    }

    if (error.code === 11000) {
      const field = Object.keys(error.keyValue)[0];
      if (field === 'email') return res.status(400).json({ success: false, message: 'Email déjà utilisé', field: 'email' });
      if (field === 'nin') return res.status(400).json({ success: false, message: 'NIN déjà utilisé', field: 'nin' });
      return res.status(400).json({ success: false, message: 'Donnée déjà utilisée' });
    }

    res.status(500).json({ success: false, message: 'Erreur serveur', error: error.message });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log('Tentative connexion:', email);

    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      return res.status(404).json({ success: false, status: 404, message: 'Email non trouvé' });
    }

    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      return res.status(401).json({ success: false, status: 401, message: 'Mot de passe incorrect' });
    }

    console.log('Connexion réussie:', email);

    res.json({
      success: true,
      message: 'Connexion réussie',
      user: {
        id: user._id,
        nom: user.nom,
        prenom: user.prenom,
        email: user.email,
        telephone: user.telephone,
        adresse: user.adresse,
        codePostal: user.codePostal,
        nin: user.nin,
        role: user.role
      }
    });

  } catch (error) {
    console.error('Erreur connexion:', error);
    res.status(500).json({ success: false, status: 500, message: 'Erreur serveur', error: error.message });
  }
};

export const getMe = async (req, res) => {
  try {
    res.json({ message: 'Route protégée - à implémenter' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};