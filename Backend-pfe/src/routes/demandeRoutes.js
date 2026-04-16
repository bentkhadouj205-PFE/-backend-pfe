// src/routes/demandeRoutes.js

import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import Demande from '../models/Demande.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const router = express.Router();

// CONFIGURATION MULTER - Upload des photos

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadPath = path.join(__dirname, '../uploads/demandes');
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 },
});

// ROUTE: Extrait de Naissance
router.post('/extrait-naissance', async (req, res) => {
  try {
    console.log(' Nouvelle demande extrait naissance reçue:', req.body);

    const {
      user_id, nom, prenom, nin,
      wilaya_naissance, commune,
      date_naissance, type_document, date_demande
    } = req.body;

    if (!user_id || !wilaya_naissance || !commune || !date_naissance) {
      return res.status(400).json({
        success: false,
        message: 'Champs obligatoires manquants: user_id, wilaya, commune, date_naissance'
      });
    }

    const nouvelleDemande = new Demande({
      userId: user_id,
      typeDocument: type_document || 'extrait_naissance',
      nom,
      prenom,
      nin,
      wilayaNaissance: wilaya_naissance,
      commune: commune,
      baladiya: commune,
      dateNaissance: new Date(date_naissance),
      dateDemande: new Date(date_demande || Date.now()),
      status: 'en_attente'
    });

    await nouvelleDemande.save();

    res.status(201).json({
      success: true,
      message: 'Demande extrait de naissance créée avec succès',
      demandeId: nouvelleDemande._id
    });

  } catch (error) {
    console.error('Erreur extrait-naissance:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ROUTE: Carte de Séjour
router.post('/carte-sejour',
  upload.fields([
    { name: 'photo_cni', maxCount: 1 },
    { name: 'photo_domicile', maxCount: 1 }
  ]),
  async (req, res) => {
    try {
      console.log(' Demande Carte de Séjour reçue');

      const {
        user_id,
        nom,
        prenom,
        nin,
        type_document = 'carte_sejour',
        date_demande
      } = req.body;

      if (!user_id || !nom || !prenom || !nin) {
        return res.status(400).json({
          success: false,
          message: 'Champs obligatoires manquants: user_id, nom, prenom, nin'
        });
      }

      if (!req.files?.photo_cni || !req.files?.photo_domicile) {
        return res.status(400).json({
          success: false,
          message: 'Les deux photos sont obligatoires (photo_cni et photo_domicile)'
        });
      }

      const nouvelleDemande = new Demande({
        userId: user_id,
        typeDocument: type_document,
        nom,
        prenom,
        nin,
        photoCniPath: req.files.photo_cni[0].path,
        photoDomicilePath: req.files.photo_domicile[0].path,
        status: 'en_attente',
        dateDemande: new Date(date_demande || Date.now()),
      });

      await nouvelleDemande.save();

      console.log('Carte de Séjour sauvegardée ID:', nouvelleDemande._id);

      res.status(201).json({
        success: true,
        message: 'Demande carte de séjour envoyée avec succès',
        demandeId: nouvelleDemande._id
      });

    } catch (error) {
      console.error('Erreur carte-sejour:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur: ' + error.message
      });
    }
  }
);

// ROUTE: Récupérer mes demandes
router.get('/mes-demandes/:userId', async (req, res) => {
  try {
    const demandes = await Demande.find({ userId: req.params.userId })
      .sort({ dateDemande: -1 });

    res.json({
      success: true,
      demandes
    });
  } catch (error) {
    console.error('Erreur mes-demandes:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

export default router;