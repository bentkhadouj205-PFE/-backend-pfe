// src/models/Demande.js
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Demande = sequelize.define('Demande', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',  // Make sure this matches your User table name
      key: 'id'
    },
    onUpdate: 'CASCADE',
    onDelete: 'SET NULL'
  },
  typeDocument: {
    type: DataTypes.ENUM('extrait_naissance', 'Fiche de résidence', 'certificat_residence', 'contrat_mariage'),
    allowNull: false
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  prenom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  nin: {
    type: DataTypes.STRING,
    allowNull: false
  },
  wilayaNaissance: {
    type: DataTypes.STRING,
    allowNull: true
  },
  commune: {
    type: DataTypes.STRING,
    allowNull: true
  },
  dateNaissance: {
    type: DataTypes.DATE,
    allowNull: true
  },
  photoCniPath: {
    type: DataTypes.STRING,
    allowNull: true
  },
  photoDomicilePath: {
    type: DataTypes.STRING,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('en_attente', 'en_cours', 'termine', 'refuse'),
    defaultValue: 'en_attente',
    allowNull: false
  },
  dateDemande: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    allowNull: false
  },
  dateTraitement: {
    type: DataTypes.DATE,
    allowNull: true
  },
  commentaire: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  tableName: 'demandes',
  timestamps: true,  // Adds createdAt and updatedAt
  indexes: [
    {
      fields: ['userId']
    },
    {
      fields: ['nin']
    },
    {
      fields: ['status']
    },
    {
      fields: ['typeDocument']
    },
    {
      fields: ['dateDemande']
    }
  ]
});

export default Demande;