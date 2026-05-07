// Autor: Alinne Monteiro de Melo 
// RA: 24801649

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  
  // cadastro — direto no Firebase Auth + Firestore
  static Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String telefone,
  }) async {
    try {
      // 1. Cria o usuário no Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      // 2. Salva os dados extras no Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'createdAt': FieldValue.serverTimestamp(),
      });

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [createUser]: code=${e.code}, message=${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Unhandled Exception [createUser]: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  // login — direto no Firebase Auth + busca no Firestore
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Faz login no Firebase Auth
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      // 2. Busca os dados do usuário no Firestore
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

  // recuperação de senha — o Firebase Auth já faz isso nativo, sem Functions!
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