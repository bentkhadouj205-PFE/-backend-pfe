import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';

export async function initializeEmail() {
  console.log('✅ Brevo API Service ready');
  return true;
}

export async function generateCertificatePDF(data) {
  const now = new Date();
  const today = `${String(now.getDate()).padStart(2, '0')}/${String(now.getMonth() + 1).padStart(2, '0')}/${now.getFullYear()}`;

  const formatDate = (d) => {
    if (!d) return '../../..';
    const dt = new Date(d);
    return `${String(dt.getDate()).padStart(2, '0')}/${String(dt.getMonth() + 1).padStart(2, '0')}/${dt.getFullYear()}`;
  };

  const formatTime = (t) => (t ? t.substring(0, 5) : '......');

  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage([595.28, 841.89]);
  const { width, height } = page.getSize();

  const fontR = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const fontB = await pdfDoc.embedFont(StandardFonts.HelveticaBold);

  const black = rgb(0, 0, 0);
  const grey = rgb(0.45, 0.45, 0.45);
  const green = rgb(0.0, 0.47, 0.25);
  const white = rgb(1, 1, 1);
  const blue = rgb(0.1, 0.1, 0.6);

  const safe = (s) => String(s || '').replace(/[^\x00-\x7F]/g, '').trim();

  const txt = (text, x, y, f = fontR, size = 9, color = black) => {
    const s = safe(text);
    if (!s) return;
    page.drawText(s, { x, y, font: f, size, color });
  };

  const dots = (x1, x2, y) => {
    for (let x = x1; x < x2; x += 4)
      page.drawLine({ start: { x: x, y: y }, end: { x: x + 2, y: y }, thickness: 0.5, color: grey });
  };

const ln = (x1, y1, x2, y2, t = 0.5, c = black) =>
  page.drawLine({ start: { x: x1, y: y1 }, end: { x: x2, y: y2 }, thickness: t, color: c });

const val = (v, fallback = '..........') => safe(v) || fallback;

// ── HEADER ───────────────────────────────────────────────────────────────
page.drawRectangle({ x: 0, y: height - 62, width, height: 62, color: green });
txt('REPUBLIQUE ALGERIENNE DEMOCRATIQUE ET POPULAIRE', 85, height - 22, fontB, 10, white);
txt('Ministere de l\'Interieur et des Collectivites Locales', 110, height - 37, fontR, 8, rgb(0.85, 0.95, 0.85));
txt('Registre National de l\'Etat Civil', 185, height - 51, fontR, 8, rgb(0.85, 0.95, 0.85));

// right side: wilaya
txt('Wilaya: ' + val(data.wilayaDelivrance, 'Mostaganem').toUpperCase(), width - 160, height - 22, fontR, 8, white);

// ── TITLE ────────────────────────────────────────────────────────────────
txt('SHAHADA AL MILAD - ACTE DE NAISSANCE', 145, height - 82, fontB, 13, black);
txt('(Copie electronique / Nuskha Iliktruniya)', 185, height - 97, fontR, 8, grey);
ln(50, height - 103, width - 50, height - 103, 1, green);

// ── Cert Number + Date ───────────────────────────────────────────────────
let y = height - 122;
txt('N° Chahada:', 50, y, fontR, 9);
txt(val(data.numeroChahada), 125, y, fontB, 9, blue);
txt('N° Acte:', 280, y, fontR, 9);
txt(val(data.numeroActe), 325, y, fontB, 9, blue);
txt('fi yawm / le:', 420, y, fontR, 9);
dots(490, width - 50, y - 1);

// ── Row 1: heure + lieu ──────────────────────────────────────────────────
y -= 20;
txt("'Ala al-sa'a (Heure):", 50, y, fontR, 9);
txt(formatTime(data.heureNaissance), 165, y, fontB, 9);
dots(195, 265, y - 1);
txt('Wulida(t) bi (Ne(e) a):', 270, y, fontR, 9);
dots(375, width - 50, y - 1);

// ── Row 2: commune + wilaya naissance ────────────────────────────────────
y -= 18;
txt('Baladiya (Commune):', 50, y, fontR, 9);
txt(val(data.communeNaissance), 160, y, fontB, 9, blue);
txt('Wilaya:', 310, y, fontR, 9);
txt(val(data.wilayaNaissance), 348, y, fontB, 9, blue);

// ── Row 3: date + nom ────────────────────────────────────────────────────
y -= 18;
txt('Date:', 50, y, fontR, 9);
txt(formatDate(data.dateNaissance), 80, y, fontB, 9);
txt('Al-musamm(a/at) (Nomme(e)):', 180, y, fontR, 9);
txt(val(data.fullName), 330, y, fontB, 10, blue);
dots(330 + fontB.widthOfTextAtSize(val(data.fullName), 10) + 4, width - 50, y - 1);

// ── Row 4: sexe ──────────────────────────────────────────────────────────
y -= 18;
txt('Al-sinn (Sexe):', 50, y, fontR, 9);
const sexeTxt = data.sexe === 'M' ? 'Masculin (Dhakar)' : data.sexe === 'F' ? 'Feminin (Untha)' : '......';
txt(sexeTxt, 135, y, fontB, 9);
dots(135 + fontB.widthOfTextAtSize(sexeTxt, 9) + 4, width - 50, y - 1);

// ── Row 5: père nom + age ────────────────────────────────────────────────
y -= 18;
txt('Ibn(at) / Pere:', 50, y, fontR, 9);
txt(val(data.pereNomPrenom), 130, y, fontB, 9);
dots(130 + fontB.widthOfTextAtSize(val(data.pereNomPrenom), 9) + 4, 310, y - 1);
txt("'Omrohu (Age):", 315, y, fontR, 9);
txt(val(data.pereAge), 395, y, fontB, 9);
dots(395 + 20, width - 50, y - 1);

// ── Row 6: père métier ───────────────────────────────────────────────────
y -= 18;
txt('Mihnatohu (Profession pere):', 50, y, fontR, 9);
txt(val(data.pereMetier), 210, y, fontB, 9);
dots(210 + fontB.widthOfTextAtSize(val(data.pereMetier), 9) + 4, width - 50, y - 1);

// ── Row 7: mère nom + age ────────────────────────────────────────────────
y -= 18;
txt('Wa / Mere:', 50, y, fontR, 9);
txt(val(data.mereNomPrenom), 115, y, fontB, 9);
dots(115 + fontB.widthOfTextAtSize(val(data.mereNomPrenom), 9) + 4, 310, y - 1);
txt("'Omroha (Age):", 315, y, fontR, 9);
txt(val(data.mereAge), 395, y, fontB, 9);
dots(395 + 20, width - 50, y - 1);

// ── Row 8: mère métier ───────────────────────────────────────────────────
y -= 18;
txt('Mihnatoha (Profession mere):', 50, y, fontR, 9);
txt(val(data.mereMetier), 210, y, fontB, 9);
dots(210 + fontB.widthOfTextAtSize(val(data.mereMetier), 9) + 4, width - 50, y - 1);

// ── Row 9: domicile ──────────────────────────────────────────────────────
y -= 18;
txt('Al-sakinin / Domicile:', 50, y, fontR, 9);
dots(175, 250, y - 1);
txt('Baladiya:', 255, y, fontR, 9);
txt(val(data.domicileCommune), 305, y, fontB, 9, blue);
txt('Wilaya:', 405, y, fontR, 9);
txt(val(data.domicileWilaya), 443, y, fontB, 9, blue);

// ── Row 10: rédigé ───────────────────────────────────────────────────────
y -= 18;
txt('Hurira fi (Redige le):', 50, y, fontR, 9);
dots(165, 270, y - 1);
txt("'Ala al-sa'a (Heure):", 275, y, fontR, 9);
txt(formatTime(data.heureRedaction), 385, y, fontB, 9);
dots(410, width - 50, y - 1);

// ── Row 11: déclaré par ──────────────────────────────────────────────────
y -= 18;
txt("I'lan (Declare par):", 50, y, fontR, 9);
txt(val(data.declarePar), 165, y, fontB, 9);
dots(165 + fontB.widthOfTextAtSize(val(data.declarePar), 9) + 4, width - 50, y - 1);

y -= 15;
dots(50, width - 50, y - 1);

// ── Row 12: officier ─────────────────────────────────────────────────────
y -= 18;
txt("Wa ba'da al-tilawa (Apres lecture):", 50, y, fontR, 8);
txt(val(data.officierEtatCivil), 240, y, fontB, 9);
dots(240 + fontB.widthOfTextAtSize(val(data.officierEtatCivil), 9) + 4, width - 195, y - 1);
txt('Dabitu al-hala al-madaniya', width - 190, y, fontR, 7, grey);

// ── Mentions marginales ───────────────────────────────────────────────────
y -= 20;
txt('Al-bayanat al-hamishiya (Mentions marginales):', 50, y, fontR, 9);
if (data.marginalNotes) txt(safe(data.marginalNotes).substring(0, 60), 310, y, fontR, 8);
dots(310, width - 50, y - 1);
y -= 14; dots(50, width - 50, y - 1);
y -= 14; dots(50, width - 50, y - 1);
y -= 14; dots(50, width - 50, y - 1);
y -= 14; dots(50, width - 50, y - 1);

// ── Date de délivrance ───────────────────────────────────────────────────
ln(50, y - 8, width - 50, y - 8, 0.3);
y -= 24;
txt(`Hurrira bi: ${val(data.redigeA, val(data.domicileCommune, 'Mostaganem'))}   fi / le:   ${today}`, 50, y, fontR, 9);

// ── Nom latin ────────────────────────────────────────────────────────────
y -= 22;
ln(50, y + 14, width - 50, y + 14, 0.3, grey);
txt('Al-kitaba al-latiniya / Ecriture en caracteres latins:', 80, y, fontB, 8);
y -= 16;
txt(val(data.fullName), 200, y, fontB, 11, blue);
dots(50, width - 50, y - 2);

// ── Notes ────────────────────────────────────────────────────────────────
y -= 22;
txt('1- Kamil al-huruf / Toutes les lettres', 50, y, fontR, 8, grey);
y -= 13;
txt('2- Ism wa laqab al-awlad / Nom et prenom des enfants', 50, y, fontR, 8, grey);

// ── Footer ───────────────────────────────────────────────────────────────
page.drawRectangle({ x: 0, y: 0, width, height: 28, color: green });
txt('Mustakhraj min Al-Sijil Al-Watani lil-Hala Al-Madaniya - Al-Marja\': J.M 7', 80, 9, fontR, 8, white);

const pdfBytes = await pdfDoc.save();
return Buffer.from(pdfBytes);
}

// ── Brevo Email Service ───────────────────────────────────────────────────────
export const emailService = {
  async sendValidationEmailWithPDF(citizenEmail, citizenFirstName, requestSubject, employeeName, comment, pdfBuffer) {
    const BREVO_API_KEY = process.env.BREVO_API_KEY || process.env.BREVO_SMTP_PASS;

    const payload = {
      sender: { name: 'Baladiya Digital', email: 'baladiyadigital27@gmail.com' },
      to: [{ email: citizenEmail, name: citizenFirstName }],
      subject: `Votre document est pret - ${requestSubject || 'Acte de Naissance'}`,
      htmlContent: `
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
      attachment: [{
        content: pdfBuffer.toString('base64'),
        name: 'acte_naissance.pdf',
      }],
    };

    const response = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'accept': 'application/json',
        'api-key': BREVO_API_KEY,
        'content-type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const result = await response.json();
    if (!response.ok) {
      console.error('❌ Brevo API Error:', result);
      throw new Error(result.message || 'Failed to send email via Brevo');
    }
    return { messageId: result.messageId };
  },
};