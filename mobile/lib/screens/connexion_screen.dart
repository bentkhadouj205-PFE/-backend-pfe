// ============================================================================
// CONNEXION SCREEN - Page ta3 login b biométrie + backend
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  
  // ============================================================================
  // 1. CLÉS & CONTROLLERS - Bach n9raw w nktbou f les champs
  // ============================================================================
  
  // Clé ta3 formulaire - bch nvalidiw les champs (email/password s7a7 wla la)
  final _formKey = GlobalKey<FormState>();
  
  // Controllers - bch n9raw text men les TextFields (email w password)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // FocusNodes - bch ncontroliw win ykun le curseur (clavier)
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // ============================================================================
  // 2. SERVICES - Les packages li nst3mlouh
  // ============================================================================
  
  // LocalAuth = Service ta3 biométrie (Face ID/Empreinte digitale)
  // Hadi ta3 telephone, ma tehtach internet
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // SecureStorage = Stockage sécurisé (email/password cryptés f telephone)
  // Hadi sécurisé bcp akther men SharedPreferences
  final _secureStorage = const FlutterSecureStorage();

  // ============================================================================
  // 3. STATE VARIABLES - Variables li ytbadlou (UI tban wla ma tban)
  // ============================================================================
  
  // Wach password chifré wla la (nekhouf les caractères wla ****)
  bool _obscurePassword = true;
  
  // Wach n'affichiw loading indicator wla la
  bool _isLoading = false;
  
  // Variables ta3 biométrie - Face ID wla Empreinte
  String _biometricLabel = 'Biométrie';  // Label li n'affichiw (Face ID wla Empreinte)
  IconData _biometricIcon = Icons.fingerprint;  // Icon li n'affichiw

  
  // ============================================================================
  // 4. INIT STATE - Ila page t7el, wch n3mlou?
  // ============================================================================
  
  @override
  void initState() {
    super.initState();
    
    // 4.1 Ndetectew anhi biométrie 3and telephone (Face ID wla Empreinte)
    _detectBiometricType();
    
    // 4.2 Nchouf ida kayn email m7foud men 9bel (connexion rapide)
    _checkSavedCredentials();
    
    // 4.3 NZID LISTENER - Bch nbliw password ila email khawi
    // Hadi bch ma y9derch ywsel l password ila email mazal khawi
    _passwordFocus.addListener(() {
      _checkEmailBeforePassword();
    });
  }

  // ============================================================================
  // 5. BLOCAGE NAVIGATION - Ila email khawi, ma y9derch ywsel l password
  // ============================================================================
  
  void _checkEmailBeforePassword() {
    // Ila password ybghi ywsel focus (yekteb fih)
    if (_passwordFocus.hasFocus) {
      // Nchouf ida email khawi
      if (_emailController.text.trim().isEmpty) {
        // Nrj3ou l email (ma nkhaliwich ywsel l password)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_emailFocus);
          
          // Nwariw message ta3 erreur
          _showErrorSnackbar('Veuillez d\'abord entrer votre Email');
        });
      }
    }
  }

  // ============================================================================
  // 6. DÉTECTION BIOMÉTRIE - Face ID wla Empreinte?
  // ============================================================================
  
  Future<void> _detectBiometricType() async {
    try {
      // Nchouf chnoua men biométrie disponible f telephone
      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();
      
      setState(() {
        // Ila Face ID disponible (iPhone)
        if (available.contains(BiometricType.face)) {
          _biometricLabel = 'Face ID';
          _biometricIcon = Icons.face_outlined;
        } 
        // Ila Empreinte disponible (Android/iPhone ancien)
        else if (available.contains(BiometricType.fingerprint) ||
                 available.contains(BiometricType.strong)) {
          _biometricLabel = 'Empreinte digitale';
          _biometricIcon = Icons.fingerprint;
        }
        // Ila walou disponible, yb9a default (Biométrie)
      });
    } catch (e) {
      print('Erreur detection biométrie: $e');
    }
  }

  // ============================================================================
  // 7. CONNEXION RAPIDE - Nchouf ida kayn credentials m7foudin
  // ============================================================================
  
  Future<void> _checkSavedCredentials() async {
    // N9raw email men SecureStorage (ila deja connecté men 9bel)
    final email = await _secureStorage.read(key: 'saved_email');
    
    // Ila kayn email, n7etouh f champ automatiquement
    if (email != null && mounted) {
      _emailController.text = email;
    }
  }

  // ============================================================================
  // 8. ÉTAPE 1: VÉRIFICATION BIOMÉTRIE (LOCAL - Telephone)
  // ============================================================================
  // HADI JAYA AWAL! Bch nchouf wach user howa bil7a9i9a (Face ID/Empreinte)
  // Ma tehtach internet, hadi local f telephone
  
  Future<bool> _verifierBiometrie() async {
    try {
      // 8.1 Nchouf ida device ysupporti biométrie
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        _showErrorSnackbar('Appareil non supporté pour biométrie');
        return false; // Khrouj, ma y9derch ykamel
      }

      // 8.2 Nchouf ida kayna biométrie configurée (Face ID wla Empreinte mregl)
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        _showErrorSnackbar(
          'Aucune biométrie configurée. Veuillez configurer $_biometricLabel.'
        );
        return false; // Khrouj, user ma 3andoch Face ID/Empreinte
      }

      // 8.3 Ndemendi l'utilisateur yverifi b Face ID / Empreinte
      // Hadi t'affichi l'écran ta3 Face ID wla Empreinte
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Vérifiez votre identité pour sécuriser la connexion',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Authentification requise',
            cancelButton: 'Annuler',
            biometricHint: 'Vérifiez votre identité',
            biometricNotRecognized: 'Non reconnu, réessayez',
            biometricSuccess: 'Authentifié avec succès',
            goToSettingsButton: 'Paramètres',
            goToSettingsDescription: 'Configurez une empreinte digitale',
          ),
          IOSAuthMessages(
            cancelButton: 'Annuler',
            goToSettingsButton: 'Paramètres',
            goToSettingsDescription: 'Configurez Face ID',
            lockOut: 'Veuillez réactiver Face ID',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,      // Ila n7ewlou l app wra, yb9a yverifi
          biometricOnly: true,   // Yaccepti ghir biométrie, ma yacceptich PIN
          useErrorDialogs: true, // Afficher dialogs ta3 erreur automatiquement
        ),
      );

      // Retourne true (najah) wla false (fich)
      return didAuthenticate;

    } on PlatformException catch (e) {
      // Gestion ta3 erreurs (LockedOut, NotEnrolled, etc.)
      String message;
      switch (e.code) {
        case 'NotAvailable':
          message = 'Biométrie non disponible';
          break;
        case 'NotEnrolled':
          message = 'Aucun $_biometricLabel configuré';
          break;
        case 'LockedOut':
          message = 'Trop de tentatives - réessayez plus tard';
          break;
        case 'PermanentlyLockedOut':
          message = 'Biométrie bloquée - déverrouillez depuis paramètres';
          break;
        default:
          message = 'Erreur biométrie: ${e.message ?? e.code}';
      }
      _showErrorSnackbar(message);
      return false;
    }
  }

  // ============================================================================
  // 9. ÉTAPE 2: VÉRIFICATION EMAIL/PASSWORD (BACKEND - Database)
  // ============================================================================
  // HADI TJI MEN BA3D L BIOMÉTRIE! Bch nchouw f base de données
  // Hadi tehtach internet, trawah l serveur
  
  Future<bool> _verifierEmailPassword() async {
    
    // 9.1 Validation locale - Form valide wela la (email format s7a7, etc.)
    if (!_formKey.currentState!.validate()) {
      return false; // Form ghalt, khrouj
    }

    // 9.2 Afficher loading indicator (n'affichiw cercle li ydour)
    setState(() => _isLoading = true);

    try {
      // 9.3 🔴🔴🔴 HNA YROU L BACKEND YCHOUF F BASE DE DONNÉES 🔴🔴🔴
      // Hadi trawah l serveur Node.js, tchouf ida email/password s7a7
      final result = await ApiService.login(
        email: _emailController.text.trim(),  // Email men champ
        password: _passwordController.text,   // Password men champ
      );

      // 9.4 Traitement ta3 résultat men backend
      if (result['success'] == true) {
        // ✅ SUCCESS - Email w password s7a7 f la base de données
        
        final user = result['user'];  // Données ta3 user men backend
        
        // Sauvegarde data f SharedPreferences (non-crypté, bch n'affichiw f app)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_nom', user['nom'] ?? '');
        await prefs.setString('user_prenom', user['prenom'] ?? '');
        await prefs.setString('user_email', user['email'] ?? '');
        await prefs.setString('user_telephone', user['telephone'] ?? '');
        
        // Sauvegarde credentials f SecureStorage (crypté, sécurisé)
        // Hadi bch n'affichiw "Connexion rapide" men ba3d
        await _secureStorage.write(
          key: 'saved_email', 
          value: _emailController.text.trim()
        );
        await _secureStorage.write(
          key: 'saved_password', 
          value: _passwordController.text
        );
        
        return true; // Kol chay s7a7, n9der n'kamel
        
      } else {
        // ❌ ÉCHEC - Email wla password ghalt f la base de données
        
        String errorMsg = result['message'] ?? 'Erreur inconnue';
        
        // Ila email makaynach f base
        if (errorMsg.toLowerCase().contains('email') || 
            errorMsg.toLowerCase().contains('trouvé') ||
            result['status'] == 404) {
          _showErrorSnackbar(
            'Email non trouvé. Veuillez créer un compte.',
            action: SnackBarAction(
              label: 'Créer',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/creation');
              },
            ),
          );
        }
        // Ila password ghalt
        else if (errorMsg.toLowerCase().contains('mot de passe') || 
                 errorMsg.toLowerCase().contains('password')) {
          _showErrorSnackbar('Mot de passe incorrect. Veuillez réessayer.');
        }
        // Erreur générale
        else {
          _showErrorSnackbar(errorMsg);
        }
        
        return false; // Ghalt, ma n9derch n'kamel
      }
      
    } catch (e) {
      // Erreur réseau (pas internet, serveur down, etc.)
      _showErrorSnackbar('Erreur de connexion. Vérifiez votre réseau.');
      return false;
      
    } finally {
      // 9.5 Cacher loading indicator (wakhet men wala)
      setState(() => _isLoading = false);
    }
  }

  // ============================================================================
  // 10. CONNEXION COMPLÈTE - Étape 1 + Étape 2 (L'ORDRE MOHIM!)
  // ============================================================================
  // HADI HIA LI T'APPUYE QUAND USER YEKTEB EMAIL/PASSWORD W YEDDI "CONNEXION"
  
  void _connexion() async {
    
    // 🔴 ÉTAPE 1: Vérifier Biométrie D'ABORD (local, rapide, ma tehtach internet)
    final biometrieValid = await _verifierBiometrie();
    if (!biometrieValid) {
      _showErrorSnackbar('$_biometricLabel requise pour continuer');
      return; // Khrouj hna, ma tekemelch
    }

    // 🟢 ÉTAPE 2: Ensuite vérifier Email + Password (backend, lent, tehtach internet)
    final emailPasswordValid = await _verifierEmailPassword();
    if (!emailPasswordValid) {
      return; // Khrouj hna, ma tekemelch
    }

    // ✅ SUCCESS KAMEL - Biométrie + Backend kol s7a7
    
    // Afficher message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Connexion sécurisée réussie !'),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    // Nstannou 2 secondes bch ychouf message
    await Future.delayed(const Duration(seconds: 2));
    
    // Ndiw l page Home
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // ============================================================================
  // 11. CONNEXION RAPIDE - Ila deja connecté men 9bel (biométrie seulement)
  // ============================================================================
  // Hadi t'affichi "Face ID" wla "Empreinte" lta7t, user yeddi 3liha direct
  
  void _connexionRapide() async {
    
    // 11.1 Nchouf ida kayn credentials m7foudin men connexion 9dima
    final email = await _secureStorage.read(key: 'saved_email');
    final password = await _secureStorage.read(key: 'saved_password');

    // Ila mazal ma connectach men 9bel, n'affichiw erreur
    if (email == null || password == null) {
      _showErrorSnackbar(
        'Veuillez d\'abord vous connecter avec email et mot de passe une première fois'
      );
      return;
    }

    // 11.2 Vérifier biométrie (Face ID/Empreinte)
    final biometrieValid = await _verifierBiometrie();
    if (!biometrieValid) return; // Khrouj ila biométrie raté

    // 11.3 Remplir les champs (bch yban l'utilisateur)
    _emailController.text = email;

    // 11.4 Connexion automatique b les credentials m7foudin
    setState(() => _isLoading = true);

    // Ndiw l backend b credentials m7foudin
    final result = await ApiService.login(email: email, password: password);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Success - Sauvegarder data w nroh l home
      final user = result['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nom', user['nom'] ?? '');
      await prefs.setString('user_prenom', user['prenom'] ?? '');
      await prefs.setString('user_email', user['email'] ?? '');
      await prefs.setString('user_telephone', user['telephone'] ?? '');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      
    } else {
      // Session expired - nsupprimi les credentials
      await _secureStorage.deleteAll();
      _emailController.clear();
      _passwordController.clear();
      _showErrorSnackbar('Session expirée. Veuillez vous reconnecter.');
    }
  }

  // ============================================================================
  // 12. SNACKBAR HELPER - Afficher message en bas d'écran
  // ============================================================================
  
  void _showErrorSnackbar(String message, {SnackBarAction? action}) {
    // Nsupprimi les anciens snackbars
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // N'affichiw jdid
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE53935), // Rouge
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
        action: action,
      ),
    );
  }

  // ============================================================================
  // 13. DISPOSE - Nettoyage quand page se ferme
  // ============================================================================
  
  @override
  void dispose() {
    // Nsupprimi les controllers bch ma yb9awch ydourou f background
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ============================================================================
  // 14. BUILD - UI (Interface utilisateur)
  // ============================================================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige clair
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey, // Clé ta3 validation
            child: Column(
              children: [
                
                const SizedBox(height: 15),

// ── FLECHE RETOUR ─────────────────────────────────────────────
Align(
  alignment: Alignment.centerLeft,
  child: GestureDetector(
    onTap: () {
      Navigator.pushReplacementNamed(context, '/bienvenue');
    },
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
                
                // 14.1 TITRE
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Connexion a votre compte',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // 14.2 CHAMP EMAIL
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  icon: Icons.email_outlined,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  nextFocus: _passwordFocus, // Quand yekteb Enter, yroh l password
                  validator: (value) {
                    // Validation email
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Email';
                    }
                    // Validation format email (regex)
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null; // S7a7
                  },
                ),
                
                const SizedBox(height: 15),
                
                // 14.3 CHAMP MOT DE PASSE
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  icon: Icons.lock_outline,
                  label: 'Mot de passe',
                  obscureText: _obscurePassword, // Chifré wla la (****)
                  isPassword: true, // Icône œil t'affichi
                  validator: (value) {
                    // Validation password
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Mot de passe trop court (min 6 caractères)';
                    }
                    return null; // S7a7
                  },
                ),
                
                const SizedBox(height: 30),
                
                // 14.4 SECTION BIOMÉTRIE (Connexion rapide)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), 
                        blurRadius: 10, 
                        spreadRadius: 1
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Icon ta3 biométrie (Face ID wla Empreinte)
                      Icon(_biometricIcon, size: 40, color: const Color(0xFF2E7D32)),
                      const SizedBox(height: 10),
                      
                      const Text(
                        'Connexion rapide',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600, 
                          color: Color(0xFF666666)
                        ),
                      ),
                      const SizedBox(height: 5),
                      
                      Text(
                        'Utilisez $_biometricLabel si déjà connecté',
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey.shade600
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      
                      // Bouton biométrie (Face ID/Empreinte)
                      GestureDetector(
                        onTap: _isLoading ? null : _connexionRapide, // Ila loading, ma y9derch yeddi
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_biometricIcon, color: const Color(0xFF2E7D32), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '$_biometricLabel',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32), 
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 14.5 BOUTON CONNEXION PRINCIPAL
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.4), 
                        blurRadius: 15, 
                        spreadRadius: 1, 
                        offset: const Offset(0, 5)
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _isLoading ? null : _connexion, // Ila loading, ma y9derch yeddi
                      child: Center(
                        child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white) // Loading
                          : const Text(
                              'Connexion',
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                letterSpacing: 1
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 15. WIDGET HELPER - Bch nbniw les champs de texte
  // ============================================================================
  
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isPassword = false,
    FocusNode? nextFocus,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            spreadRadius: 1
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText, // Ila true, y'affichi ****
        textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
        validator: validator, // Fonction ta3 validation
        onFieldSubmitted: (v) {
          // Quand yekteb Enter, yroh l champ suivant
          if (nextFocus != null && v.trim().isNotEmpty) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          // Icône œil (visible/invisible) pour password
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility, 
                    color: const Color(0xFF2E7D32)
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF666666)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide.none
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }
}