import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://172.17.77.6:5000/api';  // ←  l-IP

  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String nin,          
    required String email,
    required String telephone,
    required String adresse,
    required String codePostal,    
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'nin': nin,                
          'email': email,
          'telephone': telephone,
          'adresse': adresse,
          'codePostal': codePostal,   
          'password': password,
        }),
      );
      
      print('Response: ${response.body}');  // ← Debug
      return jsonDecode(response.body);
      
    } catch (e) {
      print('Error: $e');  // ← Debug
      return {'message': 'Erreur connexion: $e'};
    }
  }


  // CONNEXION
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      print('Login response: ${response.statusCode} - ${response.body}');
      return jsonDecode(response.body);
      
    } catch (e) {
      print('Login error: $e');
      return {'message': 'Erreur connexion: $e'};
    }
  }
}