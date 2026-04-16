import express from 'express';
import { Sequelize } from 'sequelize';
import { Notification } from '../models/notifications.js';

const router = express.Router();
const { Op } = Sequelize;

router.get('/position/:position', async (req, res) => {
  try {
    const service = req.query.service;
    const employeePosition = req.params.position; // Now using position instead of id
    
    const query = {
      [Op.or]: [
        { position: employeePosition },  // position instead of employeeId
        ...(service ? [{ service: service }] : [])
      ]
    };

    const notifications = await Notification.findAll({
      where: query,
      order: [['createdAt', 'DESC']],
      limit: 50
    });
    
    res.json(notifications);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
router.put('/:uuid/read', async (req, res) => {
  try {
    const notification = await Notification.findOne({
      where: { id: req.params.uuid }
    });
    
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    notification.isRead = true;
    await notification.save();
    
    res.json(notification);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

router.put('/position/:position/read-all', async (req, res) => {
  try {
    const employeePosition = req.params.position; // position instead of id
    const { service } = req.body;
    
    const query = {
      [Op.or]: [
        { position: employeePosition },  // position instead of employeeId
        ...(service ? [{ service: service }] : [])
      ]
    };

    await Notification.update(
      { isRead: true },
      { where: query }
    );
    
    res.json({ message: 'All notifications marked as read' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { position, title, message, service } = req.body; // position instead of employeeId
    
    const notification = await Notification.create({
      position,  // Using position field
      title,
      message,
      service,
      isRead: false
    });
    
    res.status(201).json(notification);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});
router.post('/send-by-position', async (req, res) => {
  try {
    const { position, title, message, service } = req.body;
    
    let notification = await Notification.findOne({
      where: { position: position }
    });
    
    if (!notification) {
      notification = await Notification.create({
        position,
        title,
        message,
        service,
        isRead: false
      });
      
      return res.status(201).json({
        success: true,
        action: 'created',
        message: ` Notification created for position: ${position}`,
        notification: {
          id: notification.id,
          position: notification.position,
          title: notification.title,
          message: notification.message,
          service: notification.service
        }
      });
    }
    notification.title = title;
    notification.message = message;
    if (service) notification.service = service;
    await notification.save();
    
    res.status(200).json({
      success: true,
      action: 'updated',
      message: ` Notification sent to position: ${position}`,
      notification: {
        id: notification.id,
        position: notification.position,
        title: notification.title,
        message: notification.message,
        service: notification.service
      }
    });
    
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});
router.delete('/position/:position', async (req, res) => {
  try {
    const deleted = await Notification.destroy({
      where: { position: req.params.position }
    });
    
    if (deleted === 0) {
      return res.status(404).json({ 
        message: `No notification found at position: ${req.params.position}` 
      });
    }
    
    res.json({ 
      success: true, 
      message: `Notification at position '${req.params.position}' deleted` 
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/all', async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      order: [['createdAt', 'DESC']]
    });
    res.json(notifications);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;