// ============================================================================
// HOME SCREEN - Page principale après connexion
// ============================================================================
// 🆕 UPGRADES ZIDNAHOM:
//   ✅ 1. Welcome Banner b wave + search bar
//   ✅ 2. Avatar b initiales + cover wave f Profile
//   ✅ 3. Bottom Nav b 3 icons + animation
//   ✅ 4. Profile: Photo (Caméra+Galerie) + Email editable (API) + NIN 18 étoiles
// ============================================================================

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';                          // 🆕 AJOUTÉ - Pour File (image)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';    // 🆕 AJOUTÉ - Pour photo
import 'package:http/http.dart' as http;            // 🆕 AJOUTÉ - Pour API
import 'dart:convert';   
import 'naissance_screen.dart';                           // 🆕 AJOUTÉ - Pour json

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

   // 🆕 VARIABLE STATIQUE - Bach nchouf wach Naissance rah yswar
  // Static = variable partagée bain koul les instances ta3 HomeScreen
  static bool isShowingCamera = false;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // ==========================================================================
  // CONTROLLERS & STATE - INCHANGÉ (kima koun)
  // ==========================================================================
  late AnimationController _animationController;
  bool _isEtatCivilExpanded = false;
  int _currentNavIndex = 0;

  // User data - INCHANGÉ
  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _telephone = '';
  String _nin = '';
  String _adresse = '';
  String _codePostal = '';
  
  // 🆕 AJOUTÉ - User ID pour API (récupéré du login)
  String _userId = '';

  // Session timer - INCHANGÉ
  Timer? _sessionTimer;
  DateTime? _lastActivity;
  static const int _sessionTimeoutMinutes = 15;
  bool _isInBackground = false;

  // ==========================================================================
  // INIT STATE - INCHANGÉ
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _startSessionTimer();
  }

  // ==========================================================================
  // OBSERVER - INCHANGÉ
  // ==========================================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _isInBackground = true;
    } else if (state == AppLifecycleState.resumed) {
      if (_isInBackground) {
        _isInBackground = false;

        // 🆕 ZID HAD L'IF SEULEMENT
      if (HomeScreen.isShowingCamera) {
        return;  // Ma ndirch logout
      }

        _logout(auto: true, message: 'Veuillez vous reconnecter pour des raisons de sécurité');
      }
    }
  }

  // ==========================================================================
  // LOAD USER DATA - 🆕 MODIFIÉ (ajout de _userId)
  // ==========================================================================
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nom       = prefs.getString('user_nom')       ?? 'Utilisateur';
      _prenom    = prefs.getString('user_prenom')    ?? '';
      _email     = prefs.getString('user_email')     ?? '';
      _telephone = prefs.getString('user_telephone') ?? '';
      _nin       = prefs.getString('user_nin')       ?? '';
      _adresse   = prefs.getString('user_adresse')   ?? '';
      _codePostal = prefs.getString('user_codePostal') ?? '';
      _userId    = prefs.getString('user_id') ?? '';    // 🆕 AJOUTÉ - Pour API
    });
  }

  // ==========================================================================
  // SESSION MANAGEMENT - INCHANGÉ
  // ==========================================================================
  void _startSessionTimer() {
    _lastActivity = DateTime.now();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkSessionTimeout();
    });
  }

  void _updateActivity() {
    _lastActivity = DateTime.now();
  }

  void _checkSessionTimeout() {
    if (_lastActivity != null) {
      final diff = DateTime.now().difference(_lastActivity!);
      if (diff.inMinutes >= _sessionTimeoutMinutes) {
        _logout(auto: true, message: 'Session expirée. Veuillez vous reconnecter.');
      }
    }
  }

  // ==========================================================================
  // LOGOUT - INCHANGÉ
  // ==========================================================================
  Future<void> _logout({bool auto = false, String? message}) async {
    _sessionTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/connexion');
      if (auto && message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: const Color(0xFFE53935)),
        );
      }
    }
  }

  // ==========================================================================
  // DISPOSE - INCHANGÉ
  // ==========================================================================
  @override
  void dispose() {
    _animationController.dispose();
    _sessionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

 // ==========================================================================
  // 🆕 NAVIGATION - HADY HYA LI ZEDT
  // ==========================================================================
  void _navigateToService(String route) {
    if (route == '/extrait_naissance') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExtraitNaissanceScreen()),
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  // ==========================================================================
  // BUILD - INCHANGÉ (sauf _navigateToProfile)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    _updateActivity();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR - INCHANGÉ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/images/logoo.png', fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                        ).createShader(bounds),
                        child: const Text(
                          'BALADIYA DIGITALE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.notifications_outlined, color: Color(0xFF2E7D32), size: 24),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // MAIN CONTENT - INCHANGÉ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // WELCOME BANNER - INCHANGÉ
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 25),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -25,
                            top: -25,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 35,
                            bottom: -30,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -15,
                            bottom: -15,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.04),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('⭐ ', style: TextStyle(fontSize: 16)),
                                    Text(
                                      'Bienvenue,',
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: Colors.white.withOpacity(0.85),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_nom $_prenom',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TITRE SECTION - INCHANGÉ
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        ).createShader(bounds),
                        child: const Text(
                          'Nos services',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SERVICES - INCHANGÉS
                    _buildServiceCard(
                      icon: Icons.description_outlined,
                      title: 'État Civil',
                      isExpanded: _isEtatCivilExpanded,
                      onTap: () => setState(() => _isEtatCivilExpanded = !_isEtatCivilExpanded),
                      children: [
                        _buildSubService(
                          icon: Icons.baby_changing_station,
                          title: 'Extrait de naissance',
                          onTap: () => _navigateToService('/extrait_naissance'),
                        ),
                        _buildSubService(
                          icon: Icons.home_work_outlined,
                          title: 'Carte de séjour',
                          onTap: () => _navigateToService('/carte_sejour'),
                        ),
                        _buildSubService(
                          icon: Icons.home_outlined,
                          title: 'Certificat de résidence',
                          onTap: () => _navigateToService('/certificat_residence'),
                        ),
                        _buildSubService(
                          icon: Icons.favorite_border,
                          title: 'Contrat de mariage',
                          onTap: () => _navigateToService('/contrat_mariage'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildServiceCard(
                      icon: Icons.directions_car_outlined,
                      title: 'Carte Grise',
                      onTap: () => _navigateToService('/carte_grise'),
                    ),
                    const SizedBox(height: 15),
                    _buildServiceCard(
                      icon: Icons.construction_outlined,
                      title: 'Permis de Construction',
                      onTap: () => _navigateToService('/permis_construction'),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // BOTTOM NAVIGATION - INCHANGÉ
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Accueil',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.folder_outlined,
                      activeIcon: Icons.folder,
                      label: 'Demandes',
                      index: 1,
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profil',
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // WIDGETS AUXILIAIRES - INCHANGÉS
  // ==========================================================================
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = index);
        if (index == 2) _navigateToProfile();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)])
              : null,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : const Color(0xFF9E9E9E),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                color: isActive ? Colors.white : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    bool isExpanded = false,
    VoidCallback? onTap,
    List<Widget>? children,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  if (children != null)
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2E7D32), size: 28),
                    ),
                ],
              ),
            ),
          ),
          if (children != null && isExpanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5DC).withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    ...children,
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubService({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF2E7D32), size: 16),
          ],
        ),
      ),
    );
  }

  

  // ==========================================================================
  // NAVIGATION VERS PROFILE - 🆕 MODIFIÉ (ajout de userId et callback)
  // ==========================================================================
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          nom: _nom,
          prenom: _prenom,
          email: _email,
          telephone: _telephone,
          nin: _nin,
          adresse: _adresse,
          codePostal: _codePostal,
          userId: _userId,    // 🆕 AJOUTÉ - Pour API
          onLogout: () => _logout(),
          // 🆕 AJOUTÉ - Callback quand email change dans Profile
          onEmailChanged: (newEmail) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_email', newEmail);
            setState(() => _email = newEmail);
          },
        ),
      ),
    ).then((_) => setState(() => _currentNavIndex = 0));
  }
}

// ============================================================================
// PROFILE SCREEN - 🆕 COMPLÈTEMENT MODIFIÉ (StatefulWidget au lieu de Stateless)
// ============================================================================
// 🆕 CHANGEMENTS MAJEURS:
//   - StatelessWidget → StatefulWidget (pour gérer l'état d'édition)
//   - Photo: Caméra + Galerie cliquable
//   - Email: Éditable avec sauvegarde API
//   - NIN: 18 étoiles (masqué complet)
//   - Téléphone, Adresse, Code Postal: Read-only
// ============================================================================

class ProfileScreen extends StatefulWidget {
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String nin;
  final String adresse;
  final String codePostal;
  final String userId;    // 🆕 AJOUTÉ - Pour API
  final VoidCallback onLogout;
  final Function(String newEmail) onEmailChanged;    // 🆕 AJOUTÉ - Callback

  const ProfileScreen({
    super.key,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.nin,
    required this.adresse,
    required this.codePostal,
    required this.userId,    // 🆕 AJOUTÉ
    required this.onLogout,
    required this.onEmailChanged,    // 🆕 AJOUTÉ
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// 🆕 NOUVELLE CLASSE STATE (avant c'était juste Stateless)
class _ProfileScreenState extends State<ProfileScreen> {
  
  // 🆕 AJOUTÉ - Controllers pour champs éditables
  late TextEditingController _emailController;
  
  // 🆕 AJOUTÉ - État d'édition
  bool _isEditingEmail = false;
  bool _isLoading = false;    // Pour loader pendant API
  
  // 🆕 AJOUTÉ - Pour photo de profil
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  
  // 🆕 AJOUTÉ - URL de l'API (À MODIFIER AVEC TON URL)
  static const String _apiBaseUrl = 'https://votre-api.com/api';

  @override
  void initState() {
    super.initState();
    // 🆕 AJOUTÉ - Initialiser controller avec email actuel
    _emailController = TextEditingController(text: widget.email);
    _loadProfileImage();    // 🆕 AJOUTÉ - Charger photo si existe
  }

  // 🆕 AJOUTÉ - Charger photo sauvegardée localement
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _profileImagePath = prefs.getString('profile_image_path'));
  }

  // 🆕 AJOUTÉ - Dialog choix: Caméra ou Galerie
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // 🆕 OPTION 1: Caméra
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);    // 🆕 Appel caméra
              },
            ),
            // 🆕 OPTION 2: Galerie
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);    // 🆕 Appel galerie
              },
            ),
            // 🆕 OPTION 3: Supprimer (si photo existe)
            if (_profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  // 🆕 AJOUTÉ - Prendre ou choisir photo
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (photo != null) {
        // Sauvegarder localement
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', photo.path);
        
        setState(() => _profileImagePath = photo.path);
        
        // 🆕 Upload vers serveur (optionnel)
        await _uploadImageToServer(photo.path);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo mise à jour'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 🆕 AJOUTÉ - Supprimer photo
  Future<void> _deleteImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    setState(() => _profileImagePath = null);
  }

  // 🆕 AJOUTÉ - Upload image vers serveur (optionnel)
  Future<void> _uploadImageToServer(String imagePath) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/users/${widget.userId}/upload-photo');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      
      final response = await request.send();
      if (response.statusCode != 200) {
        print('Erreur upload photo: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur upload: $e');
    }
  }

  // 🆕 AJOUTÉ - Sauvegarder email vers API (BASE DE DONNÉES)
  Future<void> _saveEmail() async {
    final newEmail = _emailController.text.trim();
    
    // Validation email
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un email valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newEmail == widget.email) {
      setState(() => _isEditingEmail = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🆕 APPEL API PUT pour modifier email en base de données
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/users/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': newEmail}),
      );

      if (response.statusCode == 200) {
        // Sauvegarder localement
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', newEmail);
        
        // Notifier parent (HomeScreen)
        widget.onEmailChanged(newEmail);
        
        setState(() => _isEditingEmail = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email mis à jour avec succès'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de mise à jour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();    // 🆕 Nettoyer controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      
      // AppBar - INCHANGÉ (kima koun)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32), size: 20),
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
          ).createShader(bounds),
          child: const Text(
            'Mon Profil',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // =================================================================
            // HEADER AVEC AVATAR CLIQUABLE - 🆕 MODIFIÉ (ajout photo)
            // =================================================================
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Cover vert - INCHANGÉ
                Container(
                  width: double.infinity,
                  height: 155,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 60,
                        bottom: -10,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🆕 AVATAR CLIQUABLE - MODIFIÉ (GestureDetector ajouté)
                Positioned(
                  bottom: -45,
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,    // 🆕 CLIQUE = Ouvre dialog
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            // 🆕 CONDITION: Photo existe ? Affiche photo : Affiche initiales
                            child: _profileImagePath != null && File(_profileImagePath!).existsSync()
                              ? Image.file(
                                  File(_profileImagePath!),
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                )
                              : Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                                    ).createShader(bounds),
                                    child: Text(
                                      '${widget.prenom.isNotEmpty ? widget.prenom[0].toUpperCase() : '?'}'
                                      '${widget.nom.isNotEmpty ? widget.nom[0].toUpperCase() : '?'}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        
                        // 🆕 ICÔNE CAMÉRA (indicateur visuel)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // Nom - INCHANGÉ
            Text(
              '${widget.prenom} ${widget.nom}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            
            const SizedBox(height: 30),

            // =================================================================
            // INFO CARDS - 🆕 MODIFIÉ (Email éditable, autres read-only)
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 🆕 EMAIL ÉDITABLE - NOUVEAU WIDGET
                  _buildEditableEmailCard(),
                  
                  // TÉLÉPHONE - Read-only (inchangé)
                  _buildStaticInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Téléphone',
                    value: widget.telephone,
                  ),
                  
                  // 🆕 NIN - MODIFIÉ (18 étoiles au lieu de 4)
                  _buildStaticInfoCard(
                    icon: Icons.badge_outlined,
                    label: 'NIN',
                    value: _maskNINFull(widget.nin),    // 🆕 Fonction modifiée
                    isSensitive: true,
                  ),
                  
                  // ADRESSE - Read-only (inchangé)
                  _buildStaticInfoCard(
                    icon: Icons.home_outlined,
                    label: 'Adresse',
                    value: widget.adresse.isNotEmpty ? widget.adresse : 'Non renseignée',
                  ),
                  
                  // CODE POSTAL - Read-only (séparé de l'adresse)
                  _buildStaticInfoCard(
                    icon: Icons.local_post_office_outlined,
                    label: 'Code Postal',
                    value: widget.codePostal.isNotEmpty ? widget.codePostal : 'Non renseigné',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // BOUTON DÉCONNEXION - INCHANGÉ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFFE53935),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withOpacity(0.4),
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
                    onTap: widget.onLogout,
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Déconnexion',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 🆕 NOUVEAU WIDGET - Email Éditable
  // ==========================================================================
  Widget _buildEditableEmailCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
        ],
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.email_outlined, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                // 🆕 MODE ÉDITION
                _isEditingEmail
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF4CAF50)),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF1B5E20), width: 2),
                              ),
                              suffixIcon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : null,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        if (!_isLoading) ...[
                          // 🆕 BOUTON SAUVEGARDER
                          IconButton(
                            icon: const Icon(Icons.check, color: Color(0xFF4CAF50), size: 20),
                            onPressed: _saveEmail,    // Appel API
                          ),
                          // 🆕 BOUTON ANNULER
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                _isEditingEmail = false;
                                _emailController.text = widget.email;    // Reset
                              });
                            },
                          ),
                        ],
                      ],
                    )
                  // 🆕 MODE AFFICHAGE
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _emailController.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        // 🆕 BOUTON ÉDITER
                        GestureDetector(
                          onTap: () => setState(() => _isEditingEmail = true),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit, color: Color(0xFF4CAF50), size: 16),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // WIDGET - Info Card Statique (Read-only) - INCHANGÉ (kima koun)
  // ==========================================================================
  Widget _buildStaticInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isSensitive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
        ],
        border: isSensitive
            ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSensitive
                  ? Colors.orange.withOpacity(0.1)
                  : const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isSensitive ? Colors.orange : const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    if (isSensitive) ...[
                      const SizedBox(width: 5),
                      Icon(Icons.lock, size: 12, color: Colors.orange.withOpacity(0.7)),
                    ],
                  ],
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 🆕 MODIFIÉ - Masquer NIN avec 18 étoiles (au lieu de 4)
  // ==========================================================================
  String _maskNINFull(String nin) {
    // 🆕 Si NIN vide ou trop court, retourner tel quel
    if (nin.isEmpty) return 'Non renseigné';
    if (nin.length < 18) return '*' * nin.length;    // 🆕 Autant d'étoiles que de caractères
    
    // 🆕 Sinon 18 étoiles pour NIN algérien standard (18 chiffres)
    return '******************';
  }
}