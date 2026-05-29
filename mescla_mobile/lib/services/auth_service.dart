// Autor: Alinne Monteiro de Melo 
// RA: 24801649

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  
  // cadastro 
  static Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String telefone,
  }) async {
    try {
      
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('createUser');

      await callable.call({
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'telefone': telefone,
    });

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [createUser]: code=${e.code}, message=${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Unhandled Exception [createUser]: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  // login - direto no Firebase Auth + busca no Firestore
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
       String emailParaLogin = email;

      // se for CPF (só números), busca o e-mail no firestore
      final apenasNumeros = email.replaceAll(RegExp(r'\D'), '');
      if (apenasNumeros.length == 11) {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('cpf', isEqualTo: apenasNumeros)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('CPF não encontrado.');
        }

        emailParaLogin = query.docs.first.data()['email'] as String;
      }

      // faz login normal com email no Firebase Auth
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      // busca os dados do usuário no firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) throw Exception('Usuário não encontrado no banco.');

      return doc.data()!;

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [login]: code=${e.code}, message=${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Unhandled Exception [login]: ${e.toString()}');
      throw Exception("Erro no login: ${e.toString()}");
    }
  }

  // recuperação de senha 
  static Future<void> requestPasswordResetEmail({
    required String email,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [resetEmail]: code=${e.code}, message=${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Unhandled Exception [resetEmail]: ${e.toString()}');
      throw Exception(e.toString());
    }
  }
}