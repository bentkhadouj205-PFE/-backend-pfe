import nodemailer from 'nodemailer';

let transporter = null;

export async function initializeEmail() {
  const testAccount = await nodemailer.createTestAccount();
  
  transporter = nodemailer.createTransport({
    host: 'smtp.ethereal.email',
    port: 587,
    secure: false,
    auth: {
      user: testAccount.user,
      pass: testAccount.pass,
    },
  });
  
  console.log('Email service initialized');
}

export const emailService = {
  async sendEmployeeNotification(employeeEmail, employeeName, citizenName, subject, serviceType) {
    if (!transporter) await initializeEmail();
    
    const info = await transporter.sendMail({
      from: '"Baladiya Digital" <baladiadigital27@gmail.com>',
      to: employeeEmail,
      subject: `Nouvelle demande: ${subject}`,
      html: `
        <h2>Bonjour ${employeeName},</h2>
        <p>Une nouvelle demande a ete assignee a votre service.</p>
        <ul>
          <li><strong>Citoyen:</strong> ${citizenName}</li>
          <li><strong>Sujet:</strong> ${subject}</li>
          <li><strong>Service:</strong> ${serviceType}</li>
        </ul>
      `
    });
    
    console.log('Email sent to employee:', info.messageId);
    return info;
  },
  
  async sendValidationEmailWithPDF(citizenEmail, citizenFirstName, requestSubject, status, employeeName, comment, pdfBuffer) {
    if (!transporter) await initializeEmail();
    
    const statusText = status === 'completed' ? 'approuvee' : 'rejetee';
    const statusColor = status === 'completed' ? '#059669' : '#dc2626';
    
    const info = await transporter.sendMail({
      from: '"Baladiya Digital" <baladiadigital27@gmail.com>',
      to: citizenEmail,
      subject: `Votre demande a ete ${statusText}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px;">
          <h2 style="color: #1e40af;">Bonjour ${citizenFirstName},</h2>
          <p>Votre demande "${requestSubject}" a ete <span style="color: ${statusColor}; font-weight: bold;">${statusText}</span>.</p>
          <div style="background: #f3f4f6; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <p><strong>Traite par:</strong> ${employeeName}</p>
            <p><strong>Date:</strong> ${new Date().toLocaleDateString('fr-FR')}</p>
            ${comment ? `<p><strong>Commentaire:</strong> ${comment}</p>` : ''}
          </div>
          <p>PDF ci-joint.</p>
        </div>
      `,
      attachments: [
        {
          filename: `demande-${Date.now()}.pdf`,
          content: pdfBuffer,
          contentType: 'application/pdf'
        }
      ]
    });
    
    console.log('Email with PDF sent:', info.messageId);
    return info;
  },
  
  async sendNotificationByPosition(position, title, message, serviceType) {
    if (!transporter) await initializeEmail();
    
    const info = await transporter.sendMail({
      from: '"Baladiya Digital" <baladiadigital27@gmail.com>',
      to: `${position}@gmail.com`,
      subject: `Notification: ${title}`,
      html: `
        <h2>Notification pour le poste: ${position}</h2>
        <p><strong>Titre:</strong> ${title}</p>
        <p><strong>Message:</strong> ${message}</p>
        <p><strong>Service:</strong> ${serviceType || 'General'}</p>
        <p><strong>Date:</strong> ${new Date().toLocaleString('fr-FR')}</p>
      `
    });
    
    console.log('Email notification sent to position:', position, info.messageId);
    return info;
  }
};

export { transporter };