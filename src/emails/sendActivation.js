import transporter from '../config/email.js';
import dotenv from 'dotenv';

dotenv.config();

const sendActivationEmail = async (to, firstName, token) => {
  const frontendUrl = (process.env.FRONTEND_URL || 'http://localhost:5173').replace(/\/$/, '');
  const verificationLink = `${frontendUrl}/verification-success?token=${token}`;

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📧 [EMAIL] Generating Activation Link...');
  console.log(`🔗 Link: ${verificationLink}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  const mailOptions = {
    from: `"Baladiya Support" <${process.env.EMAIL_FROM || 'noreply@baladiya.dz'}>`,
    to,
    subject: 'Vérification de votre compte - Baladiya',
    html: `
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
        <h2 style="color: #10b981;">Baladiya Digital</h2>
        <p>Bonjour <strong>${firstName}</strong>,</p>
        <p>Félicitations ! Votre demande d'inscription a été validée par nos services.</p>
        <p>Cliquez sur le bouton ci-dessous pour activer votre compte :</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${verificationLink}" style="background-color: #10b981; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold;">Activer mon compte</a>
        </div>
        <p style="color: #666; font-size: 14px;">Si le bouton ne fonctionne pas, copiez ce lien :<br>${verificationLink}</p>
        <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;" />
        <p style="color: #999; font-size: 12px; text-align: center;">© 2026 Baladiya - Support Municipal</p>
      </div>
    `,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log(`✅ Activation email sent to ${to} (ID: ${info.messageId})`);
  } catch (error) {
    console.error('❌ Email Error (Activation):', error.message);
    throw error;
  }
};

export default sendActivationEmail;
