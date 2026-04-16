// ============================================================================
// CREATION SCREEN - Page de création de compte
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

// ← IMPORT API SERVICE (backend)
import '../services/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';  // ← IMPORT SHARED PREFERENCES (bach nkhdmo session w nstockiw data localement)


class CreationScreen extends StatefulWidget {
  const CreationScreen({super.key});

  @override
  State<CreationScreen> createState() => _CreationScreenState();
}

class _CreationScreenState extends State<CreationScreen> {

  // ==========================================================================
  // CONTROLLERS - Bach n9raw w nktbou f kol field
  // ==========================================================================
  final _nomController             = TextEditingController();
  final _prenomController          = TextEditingController();
  final _ninController             = TextEditingController();
  final _adresseController         = TextEditingController();
  final _codePostalController      = TextEditingController();
  final _emailController           = TextEditingController();
  final _telephoneController       = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ==========================================================================
  // FOCUS NODES - Bach ncontroliw win ykun le curseur
  // ==========================================================================
  final _nomFocus        = FocusNode();
  final _prenomFocus     = FocusNode();
  final _ninFocus        = FocusNode();
  final _adresseFocus    = FocusNode();
  final _codePostalFocus = FocusNode();
  final _emailFocus      = FocusNode();
  final _telephoneFocus  = FocusNode();
  final _passwordFocus   = FocusNode();
  final _confirmFocus    = FocusNode();

  // ==========================================================================
  // LOCAL AUTH - Instance ta3 biométrie
  // ==========================================================================
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ==========================================================================
  // STATE VARIABLES
  // ==========================================================================
  bool _isBiometricEnabled = false; // Wash l-biométrie activée wela la
  bool _obscureNin         = true;  // Wash NIN mkhbi wela la
  bool _obscurePassword    = true;  // Wash password mkhbi wela la
  bool _obscureConfirm     = true;  // Wash confirm mkhbi wela la

  // Label w icon ta3 biométrie - ytbdel 7sb le téléphone
  String   _biometricLabel = 'Biométrie';
  IconData _biometricIcon  = Icons.fingerprint;

  // FORM KEY - Bach nvalidiw le formulaire
  final _formKey = GlobalKey<FormState>();

  // ORDRE TA3 FIELDS - Bach nblokiw navigation ida field khawi
  late final List<({FocusNode focus, TextEditingController ctrl, String label})> _fieldsOrder;

  // ==========================================================================
  // INIT STATE - Ydor ki l-screen tban lawel mara
  // ==========================================================================
  @override
  void initState() {
    super.initState();

    // Définir l'ordre exact ta3 fields
    _fieldsOrder = [
      (focus: _nomFocus,        ctrl: _nomController,             label: 'Nom'),
      (focus: _prenomFocus,     ctrl: _prenomController,          label: 'Prénom'),
      (focus: _ninFocus,        ctrl: _ninController,             label: 'NIN'),
      (focus: _adresseFocus,    ctrl: _adresseController,         label: 'Adresse'),
      (focus: _codePostalFocus, ctrl: _codePostalController,      label: 'Code postal'),
      (focus: _emailFocus,      ctrl: _emailController,           label: 'Email'),
      (focus: _telephoneFocus,  ctrl: _telephoneController,       label: 'Téléphone'),
      (focus: _passwordFocus,   ctrl: _passwordController,        label: 'Mot de passe'),
      (focus: _confirmFocus,    ctrl: _confirmPasswordController, label: 'Confirmation mot de passe'),
    ];

    // Zid listener l-kol field (men index 1, l-awel ma 3andou 9blo walou)
    for (int i = 1; i < _fieldsOrder.length; i++) {
      final currentIndex = i;
      _fieldsOrder[i].focus.addListener(() {
        _checkPreviousFields(currentIndex);
      });
    }

    // Detect anhi biométrie 3and le téléphone
    _detectBiometricType();
  }

  // ==========================================================================
  // DETECT BIOMETRIC TYPE
  // ==========================================================================
  Future<void> _detectBiometricType() async {
    try {
      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();

      setState(() {
        // iOS → Face ID
        if (available.contains(BiometricType.face)) {
          _biometricLabel = 'Face ID';
          _biometricIcon  = Icons.face_outlined;
        }
        // Android → Empreinte digitale
        else if (available.contains(BiometricType.fingerprint) ||
                 available.contains(BiometricType.strong)) {
          _biometricLabel = 'Empreinte digitale';
          _biometricIcon  = Icons.fingerprint;
        }
      });
    } catch (_) {}
  }

  // ==========================================================================
  // CHECK PREVIOUS FIELDS - Ida wa7ed khawi nrj3ou llih
  // ==========================================================================
  void _checkPreviousFields(int currentIndex) {
    if (!_fieldsOrder[currentIndex].focus.hasFocus) return;

    for (int i = 0; i < currentIndex; i++) {
      if (_fieldsOrder[i].ctrl.text.trim().isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_fieldsOrder[i].focus);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Veuillez remplir "${_fieldsOrder[i].label}" d\'abord',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        });
        return;
      }
    }
  }

  // ==========================================================================
  // DISPOSE - Ntemsiw memory bch ma ykounch leak
  // ==========================================================================
  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _ninController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nomFocus.dispose();
    _prenomFocus.dispose();
    _ninFocus.dispose();
    _adresseFocus.dispose();
    _codePostalFocus.dispose();
    _emailFocus.dispose();
    _telephoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

    super.dispose();
  }

  // ==========================================================================
  // ACTIVER BIOMETRIE
  // ==========================================================================
  Future<void> _activerBiometrie() async {
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        if (!mounted) return;
        _showErrorSnackbar('Appareil non supporté');
        return;
      }

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        if (!mounted) return;
        _showErrorSnackbar('Aucune biométrie configurée sur cet appareil');
        return;
      }

      if (!mounted) return;
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Activez la biométrie pour sécuriser votre compte',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Authentification biométrique',
            cancelButton: 'Annuler',
            biometricHint: 'Vérifiez votre identité',
            biometricNotRecognized: 'Non reconnu, réessayez',
            biometricSuccess: 'Authentifié',
            goToSettingsButton: 'Paramètres',
            goToSettingsDescription: 'Configurez une empreinte dans les paramètres',
          ),
          IOSAuthMessages(
            cancelButton: 'Annuler',
            goToSettingsButton: 'Paramètres',
            goToSettingsDescription: 'Configurez Face ID dans les paramètres',
            lockOut: 'Veuillez réactiver Face ID',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );

      if (!mounted) return;

      if (didAuthenticate) {
        setState(() => _isBiometricEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  '$_biometricLabel activé avec succès ✓',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

    } on PlatformException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'NotAvailable':
          message = 'Biométrie non disponible sur cet appareil';
          break;
        case 'NotEnrolled':
          message = 'Aucun $_biometricLabel configuré — allez dans Paramètres';
          break;
        case 'LockedOut':
          message = 'Trop de tentatives — réessayez plus tard';
          break;
        case 'PermanentlyLockedOut':
          message = 'Biometrie bloquée — déverrouillez depuis les paramètres';
          break;
        default:
          message = 'Erreur: ${e.message ?? e.code}';
      }
      _showErrorSnackbar(message);
    }
  }

  // ==========================================================================
  // HELPER - Wari snackbar حمراء
  // ==========================================================================
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================================================
  // VALIDER - HADI HYA LI TBADLET - Nzidou API CALL
  // ==========================================================================
  void _valider() async {
    print('=== VALIDER CLICKED ===');
    // ── STEP 1: Validation locale ───────────────────────────────────────────
    if (!_formKey.currentState!.validate()) {
       print('Form validation failed'); 
      return; // Form ma validach → nb9aw hna
    }
print('Form valid, calling API...');

    // ── STEP 2: Préparer data ──────────────────────────────────────────────
    // N7awlo adresse + code postal f string wahda
    final adresseComplete = '${_adresseController.text.trim()}, ${_codePostalController.text.trim()}';

    // ── STEP 3: Wariw loading (bch user yfhm anna chi haja tkhadem) ────────
    showDialog(
      context: context,
      barrierDismissible: false, // Ma y9derch yfermih b click lbarra
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
    );

    // ── STEP 4: Appel API - N3aytou l backend ──────────────────────────────
    final registerResult = await ApiService.register(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      nin: _ninController.text.trim(), 
      email: _emailController.text.trim(),
      telephone: _telephoneController.text.trim(),
      adresse: adresseComplete,
       codePostal: _codePostalController.text.trim(),
      password: _passwordController.text,
    );
print('API result: $registerResult');
    // ── STEP 5: Fermer loading ─────────────────────────────────────────────
    if (mounted) Navigator.pop(context);

    // ── STEP 6: Traiter résultat ───────────────────────────────────────────
    if (!mounted) return;
     if (registerResult['success'] != true && 
        registerResult['message'] != 'Compte créé avec succès') {
      
      String errorMsg = registerResult['message'] ?? 'Une erreur est survenue';
      if (errorMsg.contains('déjà utilisé')) {
        errorMsg = 'Cet email est déjà utilisé. Essayez de vous connecter.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // ── STEP 6: LOGIN AUTOMATIQUE ──────────────────────────────────────────
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
    );

    final loginResult = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) Navigator.pop(context);
    if (!mounted) return;

    // ── STEP 7: Vérifier login ─────────────────────────────────────────────
    if (loginResult['success'] == true) {

      // Stocker les infos de l'utilisateur dans SharedPreferences
final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_nom', _nomController.text.trim());
  await prefs.setString('user_prenom', _prenomController.text.trim());
  await prefs.setString('user_email', _emailController.text.trim());
  await prefs.setString('user_telephone', _telephoneController.text.trim());
  await prefs.setString('user_nin', _ninController.text.trim());
  final adresseComplete = '${_adresseController.text.trim()}, ${_codePostalController.text.trim()}';
  await prefs.setString('user_adresse', adresseComplete);

      // ✅ CRÉÉ + CONNECTÉ → HOME DIRECT
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Compte créé avec succès !'),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      // Nro7 l Home ba3d 2 secondes
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }

    } else {
      // Login échoué → Connexion manuelle
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé ! Veuillez vous connecter.'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      
      Navigator.pushReplacementNamed(context, '/connexion');
    }
  }

  // ==========================================================================
  // FIELD SUBMITTED - Ki ydos "Suivant" 3la clavier
  // ==========================================================================
  void _fieldSubmitted(String value, FocusNode nextFocus) {
    if (value.trim().isEmpty) return;
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // ==========================================================================
  // BUILD - UI dial screen
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
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

                // ── TITRE ─────────────────────────────────────────────────────
                Column(
  children: [
    ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ).createShader(bounds);
      },
      child: const Text(
        'Création de compte',
        style: TextStyle(
          fontSize: 29,
          fontWeight: FontWeight.w500,
          color: Colors.white,  // Changé à blanc pour le dégradé
        ),
      ),
    ),
    const SizedBox(height: 40),

                // ── NOM ───────────────────────────────────────────────────────
                _buildTextField(
                  controller: _nomController,
                  focusNode: _nomFocus,
                  icon: Icons.person_outline,
                  label: 'Nom',
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) => _fieldSubmitted(v, _prenomFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Nom';
                    }
                    if (value.trim().length <= 2) return 'Nom trop court';
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ── PRENOM ────────────────────────────────────────────────────
                _buildTextField(
                  controller: _prenomController,
                  focusNode: _prenomFocus,
                  icon: Icons.person_outline,
                  label: 'Prénom',
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) => _fieldSubmitted(v, _ninFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Prénom';
                    }
                    if (value.trim().length <= 2) return 'Prénom trop court';
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ── NIN ───────────────────────────────────────────────────────
                _buildTextField(
                  controller: _ninController,
                  focusNode: _ninFocus,
                  icon: Icons.badge_outlined,
                  label: 'NIN (Numéro d\'Identification National)',
                  keyboardType: TextInputType.number,
                  obscureText: _obscureNin,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) => _fieldSubmitted(v, _adresseFocus),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNin ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF2E7D32),
                    ),
                    onPressed: () => setState(() => _obscureNin = !_obscureNin),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre NIN';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'NIN doit contenir uniquement des chiffres';
                    }
                    if (value.length != 18) {
                      return 'NIN doit contenir 18 chiffres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ── ADRESSE ───────────────────────────────────────────────────
                _buildTextField(
                  controller: _adresseController,
                  focusNode: _adresseFocus,
                  icon: Icons.home_outlined,
                  label: 'Adresse (Ville/Commune)',
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) => _fieldSubmitted(v, _codePostalFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Adresse';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ── CODE POSTAL ───────────────────────────────────────────────
                _buildTextField(
                  controller: _codePostalController,
                  focusNode: _codePostalFocus,
                  icon: Icons.pin_outlined,
                  label: 'Code postal',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) => _fieldSubmitted(v, _emailFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Code postal';
                    }
                    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                      return 'Code postal invalide (5 chiffres)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ── EMAIL ─────────────────────────────────────────────────────
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  icon: Icons.email_outlined,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) => _fieldSubmitted(v, _telephoneFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ── TELEPHONE ─────────────────────────────────────────────────
                _buildTextField(
                  controller: _telephoneController,
                  focusNode: _telephoneFocus,
                  icon: Icons.phone_outlined,
                  label: 'Téléphone',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) => _fieldSubmitted(v, _passwordFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Numéro de téléphone';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Numéro doit contenir uniquement des chiffres';
                    }
                    if (value.length != 10) {
                      return 'Numéro doit contenir 10 chiffres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ── MOT DE PASSE ──────────────────────────────────────────────
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  icon: Icons.lock_outline,
                  label: 'Mot de passe',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) => _fieldSubmitted(v, _confirmFocus),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF2E7D32),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre Mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Mot de passe trop court (min 6 caractères)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ── CONFIRMER MOT DE PASSE ────────────────────────────────────
                _buildTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmFocus,
                  icon: Icons.lock_outline,
                  label: 'Confirmer le mot de passe',
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (v) {
                    if (v.trim().isNotEmpty) FocusScope.of(context).unfocus();
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF2E7D32),
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez confirmer votre Mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // ── BIOMETRIE CARD ────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _isBiometricEnabled ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isBiometricEnabled ? Icons.verified_user : _biometricIcon,
                        size: 40,
                        color: _isBiometricEnabled ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isBiometricEnabled ? '$_biometricLabel activé' : 'Sécurisez votre compte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isBiometricEnabled ? const Color(0xFF4CAF50) : const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _isBiometricEnabled
                            ? 'Votre compte est protégé'
                            : 'Activez $_biometricLabel pour plus de sécurité',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      if (!_isBiometricEnabled)
                        GestureDetector(
                          onTap: _activerBiometrie,
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
                                  'Activer $_biometricLabel',
                                  style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── BOUTON VALIDER ────────────────────────────────────────────
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
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _valider,  // ← HADI HYA LI TBDLET - Daba t3ayet l API
                      child: const Center(
                        child: Text(
                          'Valider',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
],)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // WIDGET HELPER - _buildTextField
  // ==========================================================================
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          suffixIcon: suffixIcon,
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF666666)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
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