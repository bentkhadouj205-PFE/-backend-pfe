// src/routes/employee.js
import express from 'express';
import { Employee } from '../models/employee.js'; // Make sure this model is updated for PostgreSQL

const router = express.Router();

// Get employee by position (instead of ID)
router.get('/position/:position', async (req, res) => {
  try {
    const employee = await Employee.findOne({
      where: { position: req.params.position }
    });
    
    if (!employee) {
      return res.status(404).json({ message: 'Employee not found' });
    }
    
    res.json(employee);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Other employee routes...
export default router;