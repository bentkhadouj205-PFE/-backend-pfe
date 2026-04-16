import PDFDocument from 'pdfkit';

export class PDFService {
  static generateCitizenPDF(citizenData, requestData) {
    return new Promise((resolve, reject) => {
      try {
        const doc = new PDFDocument();
        const chunks = [];
        
        doc.on('data', chunk => chunks.push(chunk));
        doc.on('end', () => {
          const pdfBuffer = Buffer.concat(chunks);
          resolve(pdfBuffer);
        });

        // Header
        doc.rect(0, 0, 612, 100).fill('#1e40af');
        doc.fillColor('#ffffff');
        doc.fontSize(28).font('Helvetica-Bold');
        doc.text('BALADIYA DIGITAL', 50, 30);
        doc.fontSize(14).font('Helvetica');
        doc.text('Fiche de Traitement de Demande', 50, 65);
        
        // Use id instead of _id for PostgreSQL UUID
        doc.fontSize(10);
        doc.text(`Ref: ${requestData.id || requestData._id || 'N/A'}`, 450, 40);
        doc.text(`Date: ${new Date().toLocaleDateString('fr-FR')}`, 450, 55);
        
        // Citizen Information
        doc.fillColor('#1f2937');
        doc.fontSize(16).font('Helvetica-Bold');
        doc.text('INFORMATIONS DU CITOYEN', 50, 130);
        doc.moveTo(50, 150).lineTo(562, 150).stroke('#e5e7eb');
        
        const citizenInfo = [
          ['Nom complet:', `${citizenData.firstName || ''} ${citizenData.lastName || ''}`],
          ['Email:', citizenData.email || 'Non specifie'],
          ['Telephone:', citizenData.phone || 'Non specifie'],
          ['NIN:', citizenData.nin || 'Non specifie'],
          ['Adresse:', citizenData.address || 'Non specifiee']
        ];
        
        let y = 170;
        doc.fontSize(11).font('Helvetica-Bold');
        citizenInfo.forEach(([label, value]) => {
          doc.fillColor('#4b5563');
          doc.text(label, 50, y);
          doc.fillColor('#1f2937').font('Helvetica');
          doc.text(value, 200, y);
          doc.font('Helvetica-Bold');
          y += 25;
        });
        
        // Request Details
        y += 20;
        doc.fillColor('#1e40af');
        doc.fontSize(16).font('Helvetica-Bold');
        doc.text('DETAILS DE LA DEMANDE', 50, y);
        doc.moveTo(50, y + 20).lineTo(562, y + 20).stroke('#e5e7eb');
        
        const requestInfo = [
          ['Type:', requestData.subject || requestData.typeDocument || 'Non specifie'],
          ['Description:', requestData.description || requestData.message || 'Aucune description'],
          ['Service:', requestData.serviceType || requestData.service || 'Non specifie'],
          ['Date:', requestData.createdAt ? new Date(requestData.createdAt).toLocaleDateString('fr-FR') : (requestData.dateDemande ? new Date(requestData.dateDemande).toLocaleDateString('fr-FR') : 'Non specifiee')],
          ['Statut:', requestData.status || 'En attente']
        ];
        
        y += 40;
        doc.fontSize(11).font('Helvetica-Bold');
        requestInfo.forEach(([label, value]) => {
          doc.fillColor('#4b5563');
          doc.text(label, 50, y);
          doc.fillColor('#1f2937').font('Helvetica');
          if (label === 'Description:') {
            doc.text(value, 200, y, { width: 362 });
            y += 40;
          } else {
            doc.text(value, 200, y);
            y += 25;
          }
          doc.font('Helvetica-Bold');
        });
        
        // Document Information (for carte sejour type requests)
        if (requestData.photoCniPath || requestData.photoDomicilePath) {
          y += 30;
          doc.fillColor('#1e40af');
          doc.fontSize(16).font('Helvetica-Bold');
          doc.text('DOCUMENTS FOURNIS', 50, y);
          doc.moveTo(50, y + 20).lineTo(562, y + 20).stroke('#e5e7eb');
          
          y += 40;
          doc.fillColor('#1f2937').fontSize(11);
          if (requestData.photoCniPath) {
            doc.text('Carte Nationale d\'Identite:', 50, y);
            doc.text('Fournie', 250, y);
            y += 25;
          }
          if (requestData.photoDomicilePath) {
            doc.text('Justificatif de Domicile:', 50, y);
            doc.text('Fourni', 250, y);
            y += 25;
          }
        }
        
        // Validation
        y += 30;
        doc.fillColor('#059669');
        doc.fontSize(16).font('Helvetica-Bold');
        doc.text('VALIDATION', 50, y);
        doc.moveTo(50, y + 20).lineTo(562, y + 20).stroke('#e5e7eb');
        
        y += 40;
        doc.fillColor('#1f2937').fontSize(11);
        doc.text('Cette demande a ete traitee et validee.', 50, y);
        doc.text(`Date: ${new Date().toLocaleDateString('fr-FR')}`, 50, y + 20);
        doc.text(`Heure: ${new Date().toLocaleTimeString('fr-FR')}`, 50, y + 40);
        
        // QR Code or additional info (optional)
        if (requestData.id) {
          y += 60;
          doc.fontSize(8);
          doc.fillColor('#9ca3af');
          doc.text(`ID de la demande: ${requestData.id}`, 50, y);
        }
        
        // Footer
        doc.rect(0, 750, 612, 42).fill('#f3f4f6');
        doc.fillColor('#6b7280').fontSize(9).font('Helvetica');
        doc.text('Document genere par Baladiya Digital', 50, 765);
        doc.text('© 2024 Administration Municipale', 50, 780);
        
        doc.end();
      } catch (error) {
        reject(error);
      }
    });
  }

  // New method for generating notification PDF
  static generateNotificationPDF(position, notificationData) {
    return new Promise((resolve, reject) => {
      try {
        const doc = new PDFDocument();
        const chunks = [];
        
        doc.on('data', chunk => chunks.push(chunk));
        doc.on('end', () => {
          const pdfBuffer = Buffer.concat(chunks);
          resolve(pdfBuffer);
        });

        // Header
        doc.rect(0, 0, 612, 100).fill('#1e40af');
        doc.fillColor('#ffffff');
        doc.fontSize(28).font('Helvetica-Bold');
        doc.text('BALADIYA DIGITAL', 50, 30);
        doc.fontSize(14).font('Helvetica');
        doc.text('Notification de Poste', 50, 65);
        
        doc.fontSize(10);
        doc.text(`Poste: ${position}`, 450, 40);
        doc.text(`Date: ${new Date().toLocaleDateString('fr-FR')}`, 450, 55);
        
        // Notification Details
        doc.fillColor('#1f2937');
        doc.fontSize(16).font('Helvetica-Bold');
        doc.text('DETAILS DE LA NOTIFICATION', 50, 130);
        doc.moveTo(50, 150).lineTo(562, 150).stroke('#e5e7eb');
        
        let y = 170;
        doc.fontSize(11).font('Helvetica-Bold');
        
        doc.fillColor('#4b5563');
        doc.text('Titre:', 50, y);
        doc.fillColor('#1f2937').font('Helvetica');
        doc.text(notificationData.title || 'Non specifie', 200, y);
        
        y += 25;
        doc.font('Helvetica-Bold');
        doc.fillColor('#4b5563');
        doc.text('Message:', 50, y);
        doc.fillColor('#1f2937').font('Helvetica');
        doc.text(notificationData.message || 'Aucun message', 200, y, { width: 362 });
        
        y += 40;
        doc.font('Helvetica-Bold');
        doc.fillColor('#4b5563');
        doc.text('Service:', 50, y);
        doc.fillColor('#1f2937').font('Helvetica');
        doc.text(notificationData.service || 'General', 200, y);
        
        y += 25;
        doc.font('Helvetica-Bold');
        doc.fillColor('#4b5563');
        doc.text('Priorite:', 50, y);
        doc.fillColor('#1f2937').font('Helvetica');
        doc.text(notificationData.priority || 'Normale', 200, y);
        
        // Footer
        doc.rect(0, 750, 612, 42).fill('#f3f4f6');
        doc.fillColor('#6b7280').fontSize(9).font('Helvetica');
        doc.text('Document genere par Baladiya Digital', 50, 765);
        doc.text('© 2024 Administration Municipale', 50, 780);
        
        doc.end();
      } catch (error) {
        reject(error);
      }
    });
  }
}

export default PDFService;