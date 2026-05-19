import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'error': 'Sign in cancelled'};
      }

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? '';
      final String studentId = email.split('@')[0];

      if (!email.endsWith('@students.nsbm.ac.lk') && !email.endsWith('@gmail.com')) {
        await _googleSignIn.signOut();
        return {
          'success': false,
          'error': 'Only NSBM student emails are allowed.\nPlease use your @students.nsbm.ac.lk account.'
        };
      }

      final UserModel? user = await ApiService.registerUser(
        email: email,
        name: name,
        studentId: studentId,
      );

      if (user == null) {
        return {'success': false, 'error': 'Failed to connect to server. Email: $email'};
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      await prefs.setString('student_id', studentId);

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'error': 'Error: ${e.toString()}'};
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<String?> getSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }
}