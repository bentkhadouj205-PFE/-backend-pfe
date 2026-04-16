// ============================================================================
// EXTRAIT DE NAISSANCE - Page pour demander extrait de naissance
// ============================================================================

import 'package:flutter/material.dart';
import 'dart:io';                    // Necessaire bach nkhadmo b files (images)
import 'dart:async';                 // Necessaire bach nkhadmo b Timer
import 'package:image_picker/image_picker.dart';    // Package bach nswiro wla nkhayro images
import 'package:http/http.dart' as http;            // Package bach nseftou requetes HTTP
import 'package:shared_preferences/shared_preferences.dart';  // Bach nstockiw data localement
import 'dart:convert';               // Bach nkhadmo b JSON
import 'package:local_auth/local_auth.dart';    // Package bach nkhadmo b empreinte/Face ID
import 'home_screen.dart';           // Bach n3rfou wach user rah yswar wla la

class ExtraitNaissanceScreen extends StatefulWidget {
  const ExtraitNaissanceScreen({super.key});

  @override
  State<ExtraitNaissanceScreen> createState() => _ExtraitNaissanceScreenState();
}

// ============================================================================
// CLASSE PRINCIPALE - Hna kayen koul l'logique
// ============================================================================

class _ExtraitNaissanceScreenState extends State<ExtraitNaissanceScreen> 
    with WidgetsBindingObserver {    // 🆕 WidgetsBindingObserver = bach nchouf wach app rah f background wla foreground
    
  // ==========================================================================
  // VARIABLES - Kolchi li lazem ytkhazan
  // ==========================================================================
  
  final ImagePicker _picker = ImagePicker();           // Object bach nkhayro images
  final LocalAuthentication _localAuth = LocalAuthentication();    // Object bach nkhadmo b biométrie
  
  File? _cniImage;                    // Image ta3 CNI li user yswarha (null = mazal ma swar walo)
  bool _isLoading = false;            // true = nseftou donnée l serveur, false = normal
  bool _isPickingImage = false;       // 🆕 true = user rah yswar, false = mazal
  
  // Variables ta3 session (bach n7arbo 15 minutes)
  Timer? _sessionTimer;               // Timer li y7seb 15 minutes
  DateTime? _lastActivity;            // Akher mara user dr activity
  static const int _sessionTimeoutMinutes = 15;    // 15 minutes timeout
  bool _isInBackground = false;       // true = app rah f background, false = foreground
  
  // Données ta3 user (njibouhom men SharedPreferences)
  String _userId = '';
  String _nom = '';
  String _prenom = '';
  String _nin = '';

  // ==========================================================================
  // INIT STATE - Ki l'page tban lawel mara
  // ==========================================================================
  
  @override
  void initState() {
    super.initState();
    
      HomeScreen.isShowingCamera = true;

    // 🆕 Nzidou app comme "observer" bach nchouf wach app tkhruj wla td5ol
    WidgetsBinding.instance.addObserver(this);
    
    // Nchargiw données ta3 user (nom, prenom, etc.)
    _loadUserData();
    
    // 🆕 Ndemarri l'timer ta3 15 minutes
    _startSessionTimer();
  }

  // ==========================================================================
  // DISPOSE - Ki l'page ttmasek (cleanup)
  // ==========================================================================
  
  @override
  void dispose() {

 HomeScreen.isShowingCamera = false;
  

    // 🆕 N7aydou app men "observers" bach ma yb9ach ychouf f'ha
    WidgetsBinding.instance.removeObserver(this);
    
    // N7aydou l'timer bach ma yb9ach ykhdem f background
    _sessionTimer?.cancel();
    
    super.dispose();
  }

  // ==========================================================================
  // 🆕 OBSERVER - Ki l'app tkhruj wla td5ol (très important!)
  // ==========================================================================
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 🟡 CAS 1: App rah tkhruj l background (user khrj men app)
    if (state == AppLifecycleState.paused) {
      _isInBackground = true;
      
      // 🆕 Si user MA YSWARCH (normal) → nsauvegarder l'heure
      // Si user YSWAR (camera) → ma nsauvegarder walo (bach ma ykhrjch)
      if (!_isPickingImage) {
        _lastActivity = DateTime.now();    // Sauvegarder: "khrjna l'heure X"
      }
    }
    
    // 🟢 CAS 2: App rah trje3 l foreground (user rja3 l'app)
    else if (state == AppLifecycleState.resumed) {
      if (_isInBackground) {
        _isInBackground = false;
        
        // 🆕 Si user KAN YSWAR (camera) → ma ndirouch logout
        if (_isPickingImage) {
          _isPickingImage = false;    // Rja3 l'normal
          _updateActivity();          // Mettre à jour l'activité
          return;                     // 🚫 MA NDROUCH LOGOUT
        }
        
        // Si user KHRJ NORMALEMENT → vérifier 15 minutes
        _checkSessionTimeout();
      }
    }
  }

  // ==========================================================================
  // SESSION MANAGEMENT - 15 minutes logic
  // ==========================================================================
  
  // 🆕 Démarrer l'timer (ykhdem koul minute)
  void _startSessionTimer() {
    _lastActivity = DateTime.now();    // L'heure li dkhlena f'ha
    
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkSessionTimeout();    // Koul minute, nchouf wach 15 minutes t3adaw
    });
  }

  // 🆕 Mettre à jour l'activité (user dr chi haja)
  void _updateActivity() {
    _lastActivity = DateTime.now();    // "User rah ykhdem l'heure X"
  }

  // 🆕 Vérifier wach 15 minutes t3adaw
  void _checkSessionTimeout() {
    // Si mazal ma 3andnach lastActivity, wala user yswar → return
    if (_lastActivity == null || _isPickingImage) return;
    
    // N7seb wach 15 minutes t3adaw
    final diff = DateTime.now().difference(_lastActivity!);
    
    if (diff.inMinutes >= _sessionTimeoutMinutes) {
      // ⛔ 15 minutes t3adaw → LOGOUT
      _logout(auto: true, message: 'Session expirée. Veuillez vous reconnecter.');
    }
  }

  // 🆕 Logout - N7aydou session w nrj3ou l connexion
  Future<void> _logout({bool auto = false, String? message}) async {
    _sessionTimer?.cancel();    // N7aydou l'timer
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();        // N7aydou koul data locale
    
    if (mounted) {
      // Nro7 l page connexion
      Navigator.pushReplacementNamed(context, '/connexion');
      
      // Afficher message si automatique
      if (auto && message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: const Color(0xFFE53935)),
        );
      }
    }
  }

  // ==========================================================================
  // LOAD DATA - Nchargiw données ta3 user
  // ==========================================================================
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _userId = prefs.getString('user_id') ?? '';
      _nom = prefs.getString('user_nom') ?? '';
      _prenom = prefs.getString('user_prenom') ?? '';
      _nin = prefs.getString('user_nin') ?? '';
    });
  }

  // ==========================================================================
  // BIOMÉTRIE - Empreinte digitale wla Face ID
  // ==========================================================================
  
  Future<bool> _authenticateWithBiometrics() async {
    try {
      // Nchouf wach téléphone yadef biométrie
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      // Si téléphone ma yadefch → nkhali user ykamel (return true)
      if (!isAvailable || !isDeviceSupported) {
        return true;
      }

      // Ndemandiw empreinte wla Face ID
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Veuillez confirmer votre identité pour envoyer la demande',
        options: const AuthenticationOptions(
          useErrorDialogs: true,      // Afficher dialog si erreur
          stickyAuth: true,           // Ma ykhrjch si app tkhruj l background
          biometricOnly: false,       // Permettre PIN kima fallback
        ),
      );

      return didAuthenticate;    // true = auth réussie, false = échouée
      
    } catch (e) {
      print('Erreur biométrie: $e');
      return false;
    }
  }

  // ==========================================================================
  // CAMERA/GALERIE - Ki user ybghi yswar CNI
  // ==========================================================================
  
  Future<void> _takeCNIPhoto() async {
    // 🆕 TRÈS IMPORTANT: N7otou flag bach n3rfou anna user rah yswar
    // Hadi bach didChangeAppLifecycleState ma ydirch logout ki yweli
    setState(() => _isPickingImage = true);
    
    // Naffichiw bottom sheet: Caméra wla Galerie?
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // Option 1: Caméra
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);           // Nsakrou bottom sheet
                _pickImage(ImageSource.camera);   // N7ellou caméra
              },
            ),
            // Option 2: Galerie
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);           // Nsakrou bottom sheet
                _pickImage(ImageSource.gallery);  // N7ellou galerie
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      // Si user annule sans choisir, nresetou flag après 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isInBackground) {
          setState(() => _isPickingImage = false);
        }
      });
    });
  }

  // Nkhadmo l'image li user khayarha
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Nkhayro l'image
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );
      
      // Si user khayar image (ma annulach)
      if (photo != null) {
        setState(() => _cniImage = File(photo.path));
      }
      
      // 🆕 LE FLAG YTRESET AUTOMATIQUEMENT PAR didChangeAppLifecycleState
      // Ki user yweli l'app (resumed), _isPickingImage yweli false
      
    } catch (e) {
      // En cas d'erreur, nresetou flag bach ma nb9awch bloqués
      setState(() => _isPickingImage = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ==========================================================================
  // ENVOI DEMANDE - Ki user yclick "Envoyer"
  // ==========================================================================
  
  Future<void> _envoyerDemande() async {
    _updateActivity();    // Mettre à jour l'activité (user dr chi haja)
    
    // Vérifier wach user swar CNI
    if (_cniImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez prendre une photo de votre CNI'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 🆕 ÉTAPE 1: Vérification biométrique (empreinte/Face ID)
    final bool isAuthenticated = await _authenticateWithBiometrics();
    
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentification requise pour envoyer la demande'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🆕 ÉTAPE 2: Envoi l'serveur
    setState(() => _isLoading = true);    // Afficher loading

    try {
      // Nprépariw l'URL ta3 API
final uri = Uri.parse('http://172.17.77.6:5000/api/demandes/extrait-naissance');
      
      // Ncréiw requete multipart (bach nseftou image + text)
      final request = http.MultipartRequest('POST', uri);
      
      // Nzidou champs texte
      request.fields['user_id'] = _userId;
      request.fields['nom'] = _nom;
      request.fields['prenom'] = _prenom;
      request.fields['nin'] = _nin;
      request.fields['type_document'] = 'extrait_naissance';
      request.fields['date_demande'] = DateTime.now().toIso8601String();
      
      // Nzidou l'image
      request.files.add(await http.MultipartFile.fromPath('cni_photo', _cniImage!.path));
      
      // Nseftou requete
      final response = await request.send();
      
      // Si succès (200 = OK, 201 = Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showSuccessDialog();    // Afficher dialog succès
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
      
    } catch (e) {
      // En cas d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'envoi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);    // Cacher loading
    }
  }

  // ==========================================================================
  // DIALOG SUCCÈS - Ki demande tseft b'succès
  // ==========================================================================
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,    // Ma y9derch yfermih b click lbarra
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône succès
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
            ),
            const SizedBox(height: 20),
            
            // Titre
            const Text(
              'Demande envoyée !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 10),
            
            // Description
            const Text(
              'Votre demande d\'extrait de naissance a été reçue. Vous recevrez une notification une fois le document prêt.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Bouton retour
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);      // Fermer dialog
                  Navigator.pop(context);      // Retour à Home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retour à l\'accueil', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD - UI ta3 l'page
  // ==========================================================================
  
  @override
  Widget build(BuildContext context) {
    _updateActivity();    // Mettre à jour à chaque build
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ── FLECHE RETOUR ─────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),    // Retour à Home
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ── TITRE ─────────────────────────────────────────────────────
              const Text(
                'Extrait de Naissance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 25),

              // 📝 ÉTAPE 1: Instructions
              _buildSectionTitle('1. Comment obtenir votre extrait ?'),
              const SizedBox(height: 15),
              
              _buildInstructionCard(
                number: '1',
                title: 'Vérification d\'identité',
                description: 'Prenez une photo claire de votre Carte Nationale d\'Identité (CNI) recto.',
                icon: Icons.verified_user_outlined,
              ),
              
              _buildInstructionCard(
                number: '2',
                title: 'Traitement de la demande',
                description: 'L\'administration vérifiera vos informations dans la base de données de l\'état civil.',
                icon: Icons.access_time,
              ),
              
              _buildInstructionCard(
                number: '3',
                title: 'Réception du document',
                description: 'Vous recevrez une notification dès que votre extrait sera prêt au téléchargement.',
                icon: Icons.download_done,
              ),

              const SizedBox(height: 30),

              // 📸 ÉTAPE 2: Upload CNI
              _buildSectionTitle('2. Télécharger votre CNI'),
              const SizedBox(height: 15),
              
              // Zone cliquable pour photo
              GestureDetector(
                onTap: _isLoading ? null : _takeCNIPhoto,    // Ki loading = true, ma y9derch yclick
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _cniImage != null ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                      width: 2,
                      style: _cniImage != null ? BorderStyle.solid : BorderStyle.none,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                    ],
                  ),
                  child: _cniImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_cniImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 40, color: Color(0xFF4CAF50)),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Appuyez pour prendre une photo',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'de votre CNI (recto)',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
                ),
              ),

              // Bouton changer photo (si déjà prise)
              if (_cniImage != null)
                Center(
                  child: TextButton.icon(
                    onPressed: _takeCNIPhoto,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Changer la photo'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7D32)),
                  ),
                ),

              const SizedBox(height: 40),

              // 🚀 BOUTON ENVOYER
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _envoyerDemande,    // Ki loading = true, disable
                  icon: _isLoading 
                    ? const SizedBox.shrink()    // Cacher icône si loading
                    : const Icon(Icons.fingerprint, size: 20),
                  label: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Envoi en cours...', style: TextStyle(fontSize: 18)),
                        ],
                      )
                    : const Text(
                        'Envoyer la demande',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 5,
                    shadowColor: const Color(0xFF1B5E20).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              
              // ℹ️ Info biométrie
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 5),
                  Text(
                    'Authentification biométrique requise',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // WIDGETS AUXILIAIRES - UI helpers
  // ==========================================================================
  
  // Titre de section (ex: "1. Comment obtenir...")
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B5E20),
      ),
    );
  }

  // Card d'instruction (numéro, titre, description, icône)
  Widget _buildInstructionCard({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Cercle avec numéro
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          
          // Icône
          Icon(icon, color: const Color(0xFF4CAF50)),
        ],
      ),
    );
  }
}