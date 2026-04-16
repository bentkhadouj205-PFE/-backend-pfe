// src/controllers/notificationController.js
const Notification = require('../models/notifications');

// Send notification by position (main function you need)
const sendNotificationByPosition = async (req, res) => {
  try {
    const { position, title, message } = req.body;
    
    // Find by POSITION (not ID!)
    let notification = await Notification.findOne({ 
      where: { position: position } 
    });
    
    if (!notification) {
      notification = await Notification.create({
        position,
        title,
        message
      });
      return res.status(201).json({
        success: true,
        action: 'created',
        message: ` Notification created at position: ${position}`,
        notification
      });
    }
    
    notification.title = title;
    notification.message = message;
    await notification.save();
    
    res.status(200).json({
      success: true,
      action: 'updated',
      message: ` Notification sent to position: ${position}`,
      notification
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get notification by position
const getNotificationByPosition = async (req, res) => {
  try {
    const { position } = req.params;
    
    const notification = await Notification.findOne({
      where: { position }
    });
    
    if (!notification) {
      return res.status(404).json({ 
        error: `No notification found at position: ${position}` 
      });
    }
    
    res.status(200).json(notification);
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get all notifications
const getAllNotifications = async (req, res) => {
  try {
    const notifications = await Notification.findAll();
    res.status(200).json(notifications);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete notification by position
const deleteNotificationByPosition = async (req, res) => {
  try {
    const { position } = req.params;
    
    const deleted = await Notification.destroy({
      where: { position }
    });
    
    if (deleted === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    
    res.status(200).json({ 
      success: true, 
      message: `Notification at position '${position}' deleted` 
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  sendNotificationByPosition,
  getNotificationByPosition,
  getAllNotifications,
  deleteNotificationByPosition
};