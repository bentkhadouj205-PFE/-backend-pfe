import { Resend } from 'resend';
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function initializeEmail() {
  console.log('✅ Resend email service ready');
  return true;
}

export async function generateCertificatePDF(data) {
  const now = new Date();
  const today = `${now.getFullYear()}/${String(now.getMonth()+1).padStart(2,'0')}/${String(now.getDate()).padStart(2,'0')}`;

  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage([595.28, 841.89]);
  const { width, height } = page.getSize();
  const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);

  const black = rgb(0,0,0);
  const grey  = rgb(0.5,0.5,0.5);

  // helper: dotted line
  const dots = (x1, x2, yPos) => {
    for (let x = x1; x < x2; x += 4) {
      page.drawLine({ 
        start: { x: x, y: yPos }, 
        end: { x: x + 2, y: yPos }, 
        thickness: 0.5, 
        color: grey 
      });
    }
  };

  const txt = (text, x, y, f=font, size=9, color=black) => {
    page.drawText(String(text||''), { x, y, font:f, size, color });
  };

  const line = (x1,y1,x2,y2, t=0.5) => {
    page.drawLine({ start:{x:x1,y:y1}, end:{x:x2,y:y2}, thickness:t, color:black });
  };

  // ── HEADER ──────────────────────────────────────────────
  // Since pdf-lib doesn't support Arabic natively,
  // we use transliterated French that matches the official form layout

  txt('Republique Algerienne Democratique et Populaire', 130, height-30, fontBold, 10);
  txt('Ministere de l\'Interieur et des Collectivites Locales', 120, height-45, font, 8);
  txt('Registre National de l\'Etat Civil', 190, height-58, fontBold, 8);

  // Title
  txt('SHAHADA AL MILAD', 210, height-85, fontBold, 16);
  txt('(Acte de Naissance)', 210, height-100, font, 10);
  txt('Copie electronique', 230, height-113, font, 8);

  line(50, height-118, width-50, height-118);

  // Cert number row
  txt('Raqm Al Shahada:', 50, height-135, font, 9);
  txt(data.actNumber || '..........', 160, height-135, fontBold, 9);
  txt('fi yawm:', 350, height-135, font, 9);
  dots(395, width-50, height-133);

  // ── ROW 1 ──
  let y = height - 155;
  dots(50, 200, y);
  txt('\'ala al-sa\'a', 205, y, font, 9);
  dots(265, 400, y);
  txt('wulida(t) bi', 405, y, font, 9);
  dots(460, width-50, y);

  // ── ROW 2 ──
  y -= 18;
  txt('baladiya', 50, y, font, 9);
  dots(95, 300, y);
  txt('wilaya', 305, y, font, 9);
  txt(data.wilaya || '..........', 340, y, fontBold, 9);

  // ── ROW 3 ──
  y -= 18;
  txt('../../..', 50, y, font, 9);
  txt('Al musamm(a/at):', 80, y, font, 9);
  txt(`${data.fullName || '..........'}`, 180, y, fontBold, 10);
  dots(180 + fontBold.widthOfTextAtSize(data.fullName||'', 10) + 5, width-50, y);

  // ── ROW 4 — السن ──
  y -= 18;
  txt('Al-sinn (Genre):', 50, y, font, 9);
  dots(145, width-50, y);

  // ── ROW 5 — الأب ──
  y -= 18;
  txt('Ibn(at):', 50, y, font, 9);
  dots(90, 250, y);
  txt('\'omrohu:', 255, y, font, 9);
  dots(295, 380, y);
  txt('mihnatohu:', 385, y, font, 9);
  dots(440, width-50, y);

  // ── ROW 6 — الأم ──
  y -= 18;
  txt('wa:', 50, y, font, 9);
  dots(65, 250, y);
  txt('\'omroha:', 255, y, font, 9);
  dots(295, 380, y);
  txt('mihnatoha:', 385, y, font, 9);
  dots(440, width-50, y);

  // ── ROW 7 — السكن ──
  y -= 18;
  txt('Al-sakinin:', 50, y, font, 9);
  dots(105, 270, y);
  txt('baladiya:', 275, y, font, 9);
  txt(data.commune || '..........', 320, y, fontBold, 9);
  txt('wilaya:', 420, y, font, 9);
  txt(data.wilaya || '..........', 455, y, fontBold, 9);

  // ── ROW 8 — حرر ──
  y -= 18;
  txt('Hurira fi:', 50, y, font, 9);
  dots(100, 280, y);
  txt('\'ala al-sa\'a:', 285, y, font, 9);
  dots(345, width-50, y);

  // ── ROW 9 — إعلان ──
  y -= 18;
  txt('I\'lan adla bihi Al-sayyid(a):', 50, y, font, 9);
  dots(210, width-50, y);

  y -= 18;
  dots(50, width-50, y);

  // ── ROW 10 — ضابط ──
  y -= 18;
  txt('Wa ba\'d al-tilawa waqa\'a ma\'ana nahnu:', 50, y, font, 9);
  dots(255, 380, y);
  txt('dabitu al-hala al-madaniya bil-baladiya', 385, y, font, 8);

  // ── البيانات الهامشية ──
  y -= 18;
  txt('Al-hamishiya:', 50, y, font, 9);
  dots(185, width-50, y);
  y -= 15; dots(50, width-50, y);
  y -= 15; dots(50, width-50, y);
  y -= 15; dots(50, width-50, y);
  y -= 15; dots(50, width-50, y);

  // ── تاريخ الإصدار ──
  y -= 25;
  line(50, y+10, width-50, y+10, 0.3);
  txt(`Hurrira bi: ${data.commune || 'Mostaganem'}   fi:   ${today}`, 50, y, font, 9);

  // ── الكتابة اللاتينية ──
  y -= 25;
  txt('Al-kitaba al-latiniya lil-ism wal-laqab:', 150, y, fontBold, 9);
  y -= 15;
  txt(`${data.fullName || ''}`, 200, y, fontBold, 10);
  dots(50, width-50, y-2);

  // ── الملاحظات ──
  y -= 25;
  txt('1- Kamil al-huruf', 50, y, font, 8);
  y -= 13;
  txt('2- Ism wa laqab al-awlad', 50, y, font, 8);

  // ── تذييل ──
  line(50, y-10, width-50, y-10, 0.5);
  y -= 22;
  txt('Mustakhraj min Al-Sijil Al-Watani lil-Hala Al-Madaniya', 130, y, fontBold, 9);
  y -= 13;
  txt('Al-Marja\': J.M 7', 240, y, font, 8);

  const pdfBytes = await pdfDoc.save();
  return Buffer.from(pdfBytes);
}

export const emailService = {
  async sendValidationEmailWithPDF(citizenEmail, citizenFirstName, requestSubject, employeeName, comment, pdfBuffer) {
    const { data, error } = await resend.emails.send({
      from: 'Baladiya Digital <onboarding@resend.dev>',
      to: citizenEmail, // ← always send to your own email for demo
      subject: `Votre document est pret - ${requestSubject || 'Acte de Naissance'}`,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:600px;margin:auto;border:1px solid #ddd;border-radius:8px;overflow:hidden">
          <div style="background:#00782B;padding:20px;text-align:center">
            <h1 style="color:#fff;margin:0;font-size:22px">Baladiya Digital</h1>
            <p style="color:#c8f5d8;margin:4px 0 0">Service Etat Civil Numerique</p>
          </div>
          <div style="padding:24px">
            <p style="font-size:16px">Bonjour <strong>${citizenFirstName || ''}</strong>,</p>
            <p>Votre demande d'<strong>${requestSubject || 'Acte de Naissance'}</strong> a ete <span style="color:#00782B;font-weight:bold">approuvee</span>.</p>
            <p>Votre document officiel est joint a cet email en format PDF.</p>
            ${comment ? `<p style="background:#f5f5f5;padding:12px;border-radius:6px;font-style:italic">Note : ${comment}</p>` : ''}
            <p style="color:#888;font-size:13px;margin-top:20px">Traite par : <strong>${employeeName || 'Service Etat Civil'}</strong></p>
          </div>
          <div style="background:#f9f9f9;padding:12px;text-align:center;font-size:11px;color:#aaa">
            Baladiya Digital - Document genere automatiquement.
          </div>
        </div>
      `,
      attachments: [{
        filename: 'acte_naissance.pdf',
        content: pdfBuffer.toString('base64'),
      }],
    });

    if (error) throw new Error(error.message);
    return { messageId: data?.id };
  },
};