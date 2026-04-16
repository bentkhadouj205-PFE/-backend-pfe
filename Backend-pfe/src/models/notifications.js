import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Notification = sequelize.define('Notification', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false
  },
  position: {          
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Position like "acte de nessence", "Fiche de résidence", "acte de mariage"'
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  service: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: 'Service/department like "état civil", "autorisation de forage"'
  },
  isRead: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  tableName: 'notifications',
  timestamps: true,    // Adds createdAt and updatedAt automatically
  indexes: [
    {
      fields: ['position'],  // Index for faster position queries
      name: 'notifications_position_idx'
    },
    {
      fields: ['service'],
      name: 'notifications_service_idx'
    },
    {
      fields: ['isRead'],
      name: 'notifications_isread_idx'
    }
  ]
});

export { Notification };