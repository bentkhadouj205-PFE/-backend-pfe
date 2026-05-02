import http from 'http';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function getNgrokUrl() {
  return new Promise((resolve, reject) => {
    http.get('http://localhost:4040/api/tunnels', (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const tunnels = JSON.parse(data).tunnels;
          // Find the tunnel pointing to 5173 (your frontend)
          const tunnel = tunnels.find((t) => t.config.addr.includes('5173'));
          if (tunnel) {
            resolve(tunnel.public_url);
          } else {
            // Fallback to the first https tunnel
            const https = tunnels.find((t) => t.proto === 'https');
            resolve(https?.public_url);
          }
        } catch {
          reject('Could not parse ngrok response');
        }
      });
    }).on('error', () => reject('ngrok is not running on port 4040 (Did you start it?)'));
  });
}

function updateEnv(ngrokUrl) {
  if (!ngrokUrl) {
    console.warn('⚠️ No ngrok URL found. Skipping .env update.');
    return;
  }

  const envPath = path.join(__dirname, '.env');
  let content = '';
  
  if (fs.existsSync(envPath)) {
    content = fs.readFileSync(envPath, 'utf8');
  }

  if (content.includes('FRONTEND_URL=')) {
    content = content.replace(/FRONTEND_URL=.*/, `FRONTEND_URL="${ngrokUrl}"`);
  } else {
    content += `\nFRONTEND_URL="${ngrokUrl}"`;
  }

  fs.writeFileSync(envPath, content);
  console.log(`✅ FRONTEND_URL updated in .env to: ${ngrokUrl}`);
}

console.log('🔍 Detecting ngrok tunnel...');
getNgrokUrl()
  .then(updateEnv)
  .catch((err) => {
    console.error('❌ Error:', err);
    console.log('💡 Tip: Make sure ngrok is running before starting the server.');
  });
