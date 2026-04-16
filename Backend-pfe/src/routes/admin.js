import express from 'express';
import { Request } from '../models/request.js';
import { Employee } from '../models/employee.js';
import { Op } from 'sequelize';

const router = express.Router();

const ADMIN_CREDENTIALS = {
  email: 'admin@gmail.com',
  password: 'admin123',
  id: '00000000-0000-0000-0000-000000000001'  
};
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    console.log('\n=== TENTATIVE CONNEXION ADMIN ===');
    console.log('Email:', email);
    
    if (email !== ADMIN_CREDENTIALS.email) {
      console.log('Email admin incorrect');
      return res.status(401).json({ message: 'Identifiants incorrects' });
    }
    
    if (password !== ADMIN_CREDENTIALS.password) {
      console.log('Mot de passe admin incorrect');
      return res.status(401).json({ message: 'Identifiants incorrects' });
    }
    console.log('Admin connecte');
    
    res.json({
      message: 'Connexion admin reussie',
      user: {
        id: ADMIN_CREDENTIALS.id,  // UUID format
        email: ADMIN_CREDENTIALS.email,
        firstName: 'Administrateur',
        lastName: '',
        name: 'Administrateur',
        role: 'admin',
        service: 'Administration',
        position: 'Administrateur Systeme',
        phone: '',
        joinDate: new Date().toISOString()
      }
    });
    
  } catch (error) {
    console.error('Erreur login admin:', error);
    res.status(500).json({ message: error.message });
  }
});
router.get('/employees', async (req, res) => {
  try {
    const employees = await Employee.findAll({
      attributes: { exclude: ['password'] },
      order: [['createdAt', 'DESC']]
    });
    
    console.log(`\nAdmin: ${employees.length} employes trouves`);
    
    res.json({
      count: employees.length,
      employees: employees
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
router.get('/employees/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const employee = await Employee.findByPk(id, {
      attributes: { exclude: ['password'] }
    });
    
    if (!employee) {
      return res.status(404).json({ message: 'Employe non trouve' });
    }
    
    res.json(employee);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/all-requests', async (req, res) => {
  try {
    const requests = await Request.findAll({
      order: [['createdAt', 'DESC']]
    });
    
    console.log(`\nAdmin: ${requests.length} demandes trouvees`);
    
    res.json({
      count: requests.length,
      requests: requests
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
router.get('/requests/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const request = await Request.findByPk(id);
    
    if (!request) {
      return res.status(404).json({ message: 'Demande non trouvee' });
    }
    
    res.json(request);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
router.get('/stats', async (req, res) => {
  try {
    const total = await Request.count();
    const pending = await Request.count({ where: { status: 'pending' } });
    const completed = await Request.count({ where: { status: 'completed' } });
    const rejected = await Request.count({ where: { status: 'rejected' } });
    
    console.log('\nStatistiques admin:');
    console.log(`  Total: ${total} | En attente: ${pending} | Termine: ${completed} | Rejete: ${rejected}`);
    
    res.json({
      total,
      pending,
      completed,
      rejected
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
router.put('/requests/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status, commentaire } = req.body;
    
    const request = await Request.findByPk(id);
    
    if (!request) {
      return res.status(404).json({ message: 'Demande non trouvee' });
    }
    
    request.status = status;
    if (commentaire) request.commentaire = commentaire;
    request.dateTraitement = new Date();
    
    await request.save();
    
    res.json({
      message: 'Statut mis a jour avec succes',
      request: request
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
router.delete('/requests/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Request.destroy({
      where: { id: id }
    });
    
    if (deleted === 0) {
      return res.status(404).json({ message: 'Demande non trouvee' });
    }
    
    res.json({ message: 'Demande supprimee avec succes' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;