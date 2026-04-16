// src/models/request.js
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Request = sequelize.define('Request', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false
  },
  citizen: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: {}
  },
  citizenId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'citizens',
      key: 'id'
    },
    onUpdate: 'CASCADE',
    onDelete: 'SET NULL'
  },
  subject: {
    type: DataTypes.STRING,
    allowNull: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  serviceType: {
    type: DataTypes.STRING,
    allowNull: true
  },
  assignedTo: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: 'Position like fiche_residence, certificat_residence, etc.'
  },
  assignedToId: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: 'Employee UUID'
  },
  assignedToName: {
    type: DataTypes.STRING,
    allowNull: true
  },
  assignedToEmail: {
    type: DataTypes.STRING,
    allowNull: true
  },
  assignedBy: {
    type: DataTypes.STRING,
    allowNull: true
  },
  assignedById: {
    type: DataTypes.UUID,
    allowNull: true
  },
  assignedEmployeeName: {
    type: DataTypes.STRING,
    allowNull: true
  },
  validatedBy: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: 'Position of validator'
  },
  validatedById: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: 'Employee UUID of validator'
  },
  validationDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'rejected'),
    defaultValue: 'pending',
    allowNull: false
  },
  documentStatus: {
    type: DataTypes.ENUM('pending', 'valid', 'missing', 'rejected'),
    defaultValue: 'pending',
    allowNull: false
  },
  comment: {
    type: DataTypes.TEXT,
    defaultValue: '',
    allowNull: false
  },
  notificationSent: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    allowNull: false
  },
  notificationRead: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    allowNull: false
  }
}, {
  tableName: 'requests',
  timestamps: true,
  indexes: [
    {
      fields: ['citizenId']
    },
    {
      fields: ['status']
    },
    {
      fields: ['documentStatus']
    },
    {
      fields: ['assignedTo']
    },
    {
      fields: ['assignedToId']
    },
    {
      fields: ['validatedById']
    },
    {
      fields: ['createdAt']
    }
  ]
});

export { Request };