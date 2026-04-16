// src/server.js
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import sequelize from './config/database.js';

// Load env FIRST
dotenv.config();

// Import all models
import './models/User.js';
import './models/employee.js';
import './models/Citizen.js';
import './models/Demande.js';
import './models/request.js';
import './models/notifications.js';

// Import routes
import notificationRoutes from './routes/notification.js';
import authRoutes from './routes/authRoutes.js';
import adminRoutes from './routes/admin.js';
import demandeRoutes from './routes/demandeRoutes.js';
import employeeRoutes from './routes/employee.js';
import requestRoutes from './routes/request.js';

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/notifications', notificationRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/demandes', demandeRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/requests', requestRoutes);

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'API is running with PostgreSQL' });
});

// Start server
async function startServer() {
  try {
    // Connect to DB
    await sequelize.authenticate();
    console.log('PostgreSQL connected successfully');

    // Sync models (create/update tables)
    await sequelize.sync({ alter: true });
    console.log(' All PostgreSQL tables created/updated');

    // Start server
    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
      console.log('\n Test in Postman:');
      console.log(`GET  http://localhost:${PORT}/`);
      console.log(`POST http://localhost:${PORT}/api/notifications/send-by-position`);
    });

  } catch (error) {
    console.error(' Error starting server:', error);

    console.log('\n Check the following:');
    console.log('1. PostgreSQL is running on port 5432');
    console.log('2. Database "notification_db" exists');
    console.log('3. Username/password are correct');
    console.log('4. Run: node src/sync-db.js if needed');
  }
}

startServer();