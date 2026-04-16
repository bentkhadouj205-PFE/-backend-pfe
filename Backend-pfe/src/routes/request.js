import express from 'express';
import { Request } from '../models/request.js';
import { emailService, initializeEmail } from './emailServices.js';
import { PDFService } from './pdfservice.js';
import { Employee } from '../models/employee.js';

const router = express.Router();
let testAccountSetup = false;

// Employees mapped by POSITION with UUIDs
const employees = {
  'fiche_residence': { 
    id: '11111111-1111-1111-1111-111111111111',  // UUID format
    name: 'Sarah', 
    email: 'sarah@gmail.com', 
    service: 'Fiche de residence', 
    position: 'fiche_residence' 
  },
  'certificat_residence': { 
    id: '22222222-2222-2222-2222-222222222222',  // UUID format
    name: 'Jamel', 
    email: 'jamel@gmail.com', 
    service: 'Certificat de residence', 
    position: 'certificat_residence' 
  },
  'acte_naissance': { 
    id: '33333333-3333-3333-3333-333333333333',  // UUID format
    name: 'Fatima', 
    email: 'fatima@gmail.com', 
    service: 'Acte de naissance', 
    position: 'acte_naissance' 
  },
  'certificat_mariage': { 
    id: '44444444-4444-4444-4444-444444444444',  // UUID format
    name: 'Maria', 
    email: 'maria@gmail.com', 
    service: 'Certificat de mariage', 
    position: 'certificat_mariage' 
  }
};

const EMPLOYEE_PASSWORD = 'employee123';

console.log('\n=== EMPLOYES ENREGISTRES ===');
Object.values(employees).forEach(emp => {
  console.log(`${emp.name}: ${emp.email} / ${EMPLOYEE_PASSWORD} (Position: ${emp.position} - Service: ${emp.service} - ID: ${emp.id})`);
});
console.log('============================\n');

// Submit request
router.post('/submit', async (req, res) => {
  try {
    if (!testAccountSetup) {
      await initializeEmail();
      testAccountSetup = true;
    }

    const { citizenData, subject, description, serviceType } = req.body;
    console.log('\n=== NOUVELLE DEMANDE ===');
    console.log('Citoyen:', citizenData.firstName, citizenData.lastName);
    
    let assignedEmployee = employees['certificat_residence'];
    const serviceLower = (serviceType || '').toLowerCase();
    
    if (serviceLower.includes('fiche') || serviceLower.includes('residence')) {
      assignedEmployee = employees['fiche_residence'];
    } else if (serviceLower.includes('certificat') || serviceLower.includes('residence')) {
      assignedEmployee = employees['certificat_residence'];
    } else if (serviceLower.includes('Acte') || serviceLower.includes('naissance')) {
      assignedEmployee = employees['acte_naissance'];
    } else if (serviceLower.includes('certificat') || serviceLower.includes('mariage')) {
      assignedEmployee = employees['certificat_mariage'];
    }if (serviceLower.includes('Autorisation ') || serviceLower.includes('forage')) {
      assignedEmployee = employees['Autorisation de forage'];
    }
    
    console.log(`Assigné à: ${assignedEmployee.name} (Position: ${assignedEmployee.position} - Service: ${assignedEmployee.service})`);

    const newRequest = await Request.create({
      citizen: citizenData,
      subject,
      description,
      serviceType: serviceType || 'Non spécifié',
      assignedTo: assignedEmployee.position,  // Using POSITION as string
      assignedToId: assignedEmployee.id,      // Using UUID
      assignedToName: assignedEmployee.name,
      assignedToEmail: assignedEmployee.email,
      status: 'pending',
    });
    
    console.log('Demande enregistree:', newRequest.id);
    
    try {
      await emailService.sendEmployeeNotification(
        assignedEmployee.email,
        assignedEmployee.name,
        `${citizenData.firstName} ${citizenData.lastName}`,
        subject,
        serviceType
      );
    } catch (emailError) {
      console.error('Email failed:', emailError.message);
    }
    
    res.status(201).json({
      message: 'Demande soumise avec succes',
      requestId: newRequest.id,
      assignedTo: {
        id: assignedEmployee.id,
        name: assignedEmployee.name,
        position: assignedEmployee.position,
        service: assignedEmployee.service
      }
    });
    
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: error.message });
  }
});

// Employee login (using POSITION or UUID)
router.post('/login', async (req, res) => {
  try {
    const { email, password, position, employeeId } = req.body;
    
    if (password !== EMPLOYEE_PASSWORD) {
      return res.status(401).json({ message: 'Mot de passe incorrect' });
    }
    
    let employee = null;
    if (position) {
      employee = Object.values(employees).find(emp => emp.position === position);
    } else if (email) {
      employee = Object.values(employees).find(emp => emp.email === email);
    } else if (employeeId) {
      employee = Object.values(employees).find(emp => emp.id === employeeId);
    }
    
    if (!employee) {
      return res.status(404).json({ message: 'Employe non trouve' });
    }
    
    console.log(`\nConnexion: ${employee.name} (Position: ${employee.position} - Service: ${employee.service} - ID: ${employee.id})`);
    
    res.json({
      message: 'Connexion reussie',
      employee: {
        id: employee.id,
        name: employee.name,
        email: employee.email,
        service: employee.service,
        position: employee.position
      }
    });
    
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get my requests (by POSITION)
router.get('/my-requests/:position', async (req, res) => {
  try {
    const requests = await Request.findAll({
      where: { assignedTo: req.params.position },
      order: [['createdAt', 'DESC']]
    });
    
    res.json({
      count: requests.length,
      requests: requests
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get my requests by employee UUID
router.get('/my-requests/by-employee/:employeeId', async (req, res) => {
  try {
    const employee = Object.values(employees).find(emp => emp.id === req.params.employeeId);
    
    if (!employee) {
      return res.status(404).json({ message: 'Employe non trouve' });
    }
    
    const requests = await Request.findAll({
      where: { assignedTo: employee.position },
      order: [['createdAt', 'DESC']]
    });
    
    res.json({
      count: requests.length,
      employee: {
        id: employee.id,
        name: employee.name,
        position: employee.position
      },
      requests: requests
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get single request (by UUID)
router.get('/request/:requestId', async (req, res) => {
  try {
    const request = await Request.findByPk(req.params.requestId);
    if (!request) {
      return res.status(404).json({ message: 'Demande non trouvee' });
    }
    res.json(request);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get requests by status
router.get('/status/:status', async (req, res) => {
  try {
    const requests = await Request.findAll({
      where: { status: req.params.status },
      order: [['createdAt', 'DESC']]
    });
    
    res.json({
      count: requests.length,
      requests: requests
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Validate with PDF (using POSITION)
router.put('/validate-with-pdf/:requestId', async (req, res) => {
  try {
    const { status, documentStatus, comment, position } = req.body;
    
    const request = await Request.findByPk(req.params.requestId);
    
    if (!request) {
      return res.status(404).json({ message: 'Demande non trouvee' });
    }
    
    const employee = employees[position];
    
    request.status = status;
    if (documentStatus) request.documentStatus = documentStatus;
    if (comment) request.comment = comment;
    request.validatedBy = position;
    request.validatedById = employee?.id || null;
    request.validationDate = new Date();
    
    await request.save();
    
    console.log('\n=== VALIDATION ===');
    console.log('Demande:', request.id);
    console.log('Statut:', status);
    console.log('Valide par position:', position);
    console.log('Valide par ID:', employee?.id);
    console.log('Service:', employee?.service);
    
    let pdfBuffer = null;
    try {
      pdfBuffer = await PDFService.generateCitizenPDF(request.citizen, request);
      console.log('PDF genere:', pdfBuffer.length, 'bytes');
    } catch (pdfError) {
      console.error('PDF Error:', pdfError.message);
    }
    
    let emailSent = false;
    if ((status === 'completed' || status === 'rejected') && pdfBuffer && request.citizen?.email) {
      try {
        await emailService.sendValidationEmailWithPDF(
          request.citizen.email,
          request.citizen.firstName,
          request.subject,
          status,
          employee?.name || 'Service municipal',
          comment,
          pdfBuffer
        );
        emailSent = true;
        console.log('Email envoye');
      } catch (emailError) {
        console.error('Email Error:', emailError.message);
      }
    }
    
    res.json({
      message: 'Demande traitee',
      request,
      pdfGenerated: !!pdfBuffer,
      emailSent
    });
    
  } catch (error) {
    console.error('Validation error:', error);
    res.status(500).json({ message: error.message });
  }
});

// Download PDF (by UUID)
router.get('/download-pdf/:requestId', async (req, res) => {
  try {
    const request = await Request.findByPk(req.params.requestId);
    if (!request) {
      return res.status(404).json({ message: 'Demande non trouvee' });
    }
    
    const pdfBuffer = await PDFService.generateCitizenPDF(request.citizen, request);
    
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=demande-${request.id}.pdf`);
    res.send(pdfBuffer);
    
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all requests (for admin)
router.get('/all-requests', async (req, res) => {
  try {
    const requests = await Request.findAll({
      order: [['createdAt', 'DESC']]
    });
    
    res.json({
      count: requests.length,
      requests: requests
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update request status by position
router.put('/request/:requestId/status', async (req, res) => {
  try {
    const { status, comment } = req.body;
    const request = await Request.findByPk(req.params.requestId);
    
    if (!request) {
      return res.status(404).json({ message: 'Demande non trouvee' });
    }
    
    request.status = status;
    if (comment) request.comment = comment;
    await request.save();
    
    res.json({
      message: 'Statut mis a jour',
      request
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete request by UUID
router.delete('/request/:requestId', async (req, res) => {
  try {
    const deleted = await Request.destroy({
      where: { id: req.params.requestId }
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