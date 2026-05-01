import express from 'express';
import crypto from 'crypto';
import { supabase } from '../supabaseClient.js';
import sendActivationEmail from '../emails/sendActivation.js';
import sendRejectionEmail from '../emails/sendRejection.js';
import dotenv from 'dotenv';

dotenv.config();

const router = express.Router();



const SUPABASE_URL = process.env.SUPABASE_URL || 'https://uvmruxcjpgovdrwvykyn.supabase.co';

// Helper to build public storage URL
const storageUrl = (bucket, path) => {
  if (!path) return null;
  if (path.startsWith('http')) return path;

  const baseUrl = process.env.SUPABASE_URL?.replace(/\/$/, '') || 'https://uvmruxcjpgovdrwvykyn.supabase.co';
  return `${baseUrl}/storage/v1/object/public/${bucket}/${path}`;
};

// ── GET all requests with registry comparison ─────────────────────────────
router.get('/', async (req, res) => {
  try {
    console.log(' [VALIDATION] Fetching registration requests...');
    const { data: requests, error } = await supabase
      .from('demandes_inscription')
      .select('*')
      .order('date_demande', { ascending: false });

    if (error) {
      console.error(' [VALIDATION] Supabase Query Error:', error.message);
      return res.status(500).json({ error: error.message });
    }

    console.log(`[VALIDATION] Successfully retrieved ${requests.length} requests.`);

    const enriched = await Promise.all(requests.map(async (r) => {
      // Find matching citizen by NIN (Registry check)
      const { data: citizen, error: citizenError } = await supabase
        .from('citizens')
        .select('*')
        .eq('nin', r.nin)
        .maybeSingle();

      if (citizenError) {
        console.warn(`[REGISTRY] Match failed for NIN ${r.nin}:`, citizenError.message);
      }

      return {
        id: r.id,
        firstName: r.prenom || r.firstName,
        lastName: r.nom || r.lastName,
        nin: r.nin,
        email: r.email,
        dob: r.date_demande || r.created_at,
        commune: r.commune,
        address: r.adresse || r.address,
        status: r.status,
        rejectionReason: r.commentaire || r.rejection_reason,
        cniScanPath: storageUrl('cni-scans', r.cni_recto_path || r.photo_cni_path),
        selfiePath: storageUrl('selfies', r.selfie_path || r.photo_domicile_path),
        reg: {
          firstName: citizen?.prenom ?? null,
          lastName: citizen?.nom ?? null,
          nin: citizen?.nin ?? null,
          dob: citizen?.date_naissance ?? null,
          commune: citizen?.commune ?? null,
        }
      };
    }));

    res.json({ data: enriched });
  } catch (err) {
    console.error(' [VALIDATION] Fatal error:', err);
    res.status(500).json({ error: err.message });
  }
});

// ── POST validate ─────────────────────────────────────────────────────────
router.post('/:id/validate', async (req, res) => {
  const { id } = req.params;
  
  // 🛡️ [AUTH] Check for Authorization header
  const authHeader = req.headers.authorization;
  console.log(`📡 [VALIDATE] Auth Header: ${authHeader ? '✅ Present' : '❌ MISSING'}`);

  if (!authHeader) {
    return res.status(401).json({ error: 'No authorization header provided' });
  }

  const adminToken = authHeader.split(' ')[1];
  try {
    // 🛡️ [AUTH] Verify Admin JWT (ensure it's an authorized agent)
    // const decoded = jwt.verify(adminToken, process.env.JWT_SECRET); 
    // console.log(`🛡️ [AUTH] Request by: ${decoded.email}`);

    console.log(`📡 [VALIDATE] Processing request ${id}...`);
    
    const { data: request, error: fetchErr } = await supabase
      .from('demandes_inscription')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchErr || !request) {
      console.error('❌ [VALIDATE] Fetch error:', fetchErr?.message);
      return res.status(404).json({ error: 'Request not found' });
    }

    // ✅ [TOKEN] Generate and define the activation token CLEARLY
    const generatedToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    const { error: updateErr } = await supabase
      .from('demandes_inscription')
      .update({ 
        status: 'termine',
        activation_token: generatedToken,
        commentaire: `EXPIRES:${expiresAt.toISOString()}` 
      })
      .eq('id', id);

    if (updateErr) {
      console.error('❌ [VALIDATE] Supabase Update Error:', updateErr);
      throw new Error(updateErr.message);
    }

    await sendActivationEmail(request.email, request.prenom, generatedToken);
    res.json({ success: true, message: 'Activation email sent' });
  } catch (err) {
    console.error('❌ [VALIDATE] error:', err.message);
    console.error('📜 [VALIDATE] stack:', err.stack);
    res.status(500).json({ error: err.message });
  }
});

// ── GET debug requests ───────────────────────────────────────────────────
router.get('/debug/requests', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('demandes_inscription')
      .select('id, email, prenom, status, activation_token, commentaire');
    
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST activate ─────────────────────────────────────────────────────────
router.post('/activate', async (req, res) => {
  const { token } = req.body;
  if (!token) return res.status(400).json({ error: 'Token missing' });

  try {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🔍 [ACTIVATE] Attempt for token: ${token.substring(0, 10)}...`);

    // 1. Find the request by token
    const { data: request, error: findErr } = await supabase
      .from('demandes_inscription')
      .select('*')
      .eq('activation_token', token)
      .single();

    if (findErr || !request) {
      console.error('❌ [ACTIVATE] No match found in DB for this token.');
      
      // Log some context - is there ANY token?
      const { data: others } = await supabase.from('demandes_inscription').select('email, activation_token').not('activation_token', 'is', null).limit(3);
      console.log('📝 [DEBUG] Other active tokens in DB:', others);

      return res.status(400).json({ error: 'Lien invalide ou déjà utilisé' });
    }

    console.log(`✅ [ACTIVATE] Match found! Email: ${request.email}`);

    // 2. Check Expiry (if stored in commentaire)
    if (request.commentaire && request.commentaire.startsWith('EXPIRES:')) {
      const expiryStr = request.commentaire.replace('EXPIRES:', '');
      const expiryDate = new Date(expiryStr);
      if (expiryDate < new Date()) {
        console.error('⏰ [ACTIVATE] Token expired');
        return res.status(400).json({ error: 'Lien expiré (valide 24h)' });
      }
    }

    // 2. Create the user account (or update if exists)
    // NOTE: In a real app, you'd move data to the 'users' table here
    console.log(`✅ [ACTIVATE] Activating user: ${request.email}`);

    const { error: activateErr } = await supabase
      .from('demandes_inscription')
      .update({ status: 'active', activation_token: null })
      .eq('id', request.id);

    if (activateErr) throw activateErr;

    res.json({ success: true, message: 'Compte activé avec succès' });
  } catch (err) {
    console.error(' [ACTIVATE] error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ── POST reject ───────────────────────────────────────────────────────────
router.post('/:id/reject', async (req, res) => {
  const { id } = req.params;
  const { reason } = req.body;
  if (!reason) return res.status(400).json({ error: 'Reason required' });

  try {
    const { data: request, error } = await supabase
      .from('demandes_inscription')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !request) return res.status(404).json({ error: 'Request not found' });
    if (request.status !== 'pending' && request.status !== 'en_attente') {
      return res.status(400).json({ error: 'Request already processed' });
    }

    const { error: updateErr } = await supabase
      .from('demandes_inscription')
      .update({ status: 'refuse', commentaire: reason })
      .eq('id', id);

    if (updateErr) throw updateErr;

    await sendRejectionEmail(request.email, request.prenom, reason);
    res.json({ success: true, message: 'Rejection email sent' });
  } catch (err) {
    console.error('Reject error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

export default router;
