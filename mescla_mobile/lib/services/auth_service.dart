// Autor: Alinne Monteiro de Melo 
// RA: 24801649

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //cadastro
  static Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String telefone,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('createUser');

      await callable.call({
        "name": name,
        "email": email,
        "password": password,
        "cpf": cpf,
        "telefone": telefone,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // login no Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // chama o back (getMe)
      final callable =
          FirebaseFunctions.instance.httpsCallable('getMe');

      final result = await callable.call();

      return Map<String, dynamic>.from(result.data['user']);
    } catch (e) {
      throw Exception("Erro no login: ${e.toString()}");
    }
  }

  // recuperação de senha
  static Future<void> requestPasswordResetEmail({
  required String email,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'requestPasswordResetEmail',
      );

      await callable.call({
        'email': email,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
}

}