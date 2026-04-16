// src/sync-db.js
import sequelize from './config/database.js';
import './models/User.js';
import './models/employee.js';
import './models/Citizen.js';
import './models/Demande.js';
import './models/request.js';
import './models/notifications.js';

async function syncDatabase() {
  try {
    console.log(' Connecting to PostgreSQL...');
    await sequelize.authenticate();
    console.log(' PostgreSQL connected successfully');
    
    console.log(' Creating database tables...');
    // Sync all models (alter: true updates tables without dropping data)
    await sequelize.sync({ alter: true });
    console.log(' All tables created/updated successfully');
    
    console.log('\nTables created:');
    console.log('  - Users');
    console.log('  - Employees');
    console.log('  - Citizens');
    console.log('  - Demandes');
    console.log('  - Requests');
    console.log('  - Notifications');
    
    process.exit(0);
  } catch (error) {
    console.error(' Error:', error.message);
    console.log('\n Troubleshooting:');
    console.log('1. Is PostgreSQL running?');
    console.log('2. Check your .env file credentials');
    console.log('3. Does database "notification_db" exist?');
    process.exit(1);
  }
}

syncDatabase();