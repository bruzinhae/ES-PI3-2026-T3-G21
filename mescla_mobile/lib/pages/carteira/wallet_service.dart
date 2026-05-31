// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';


class WalletService {
  static final _functions = FirebaseFunctions.instance;

  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static DocumentReference get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

  static CollectionReference get _assetsCol =>
      _userDoc.collection('assets');



  // saldo do usuário em tempo real
  static Stream<DocumentSnapshot> saldoStream() => _userDoc.snapshots();

  // tokens do usuário em tempo real
  static Stream<QuerySnapshot> assetsStream() => _assetsCol.snapshots();

  

  // deposita saldo e retorna em centavos
  static Future<int> depositar(double valorReais) async {
    final amountCents = (valorReais * 100).toInt();
    final result = await _functions
        .httpsCallable('depositToUserWallet')
        .call({'amountCents': amountCents});
    return (result.data['data']['balanceCents'] as num).toInt();
  }

  // lista as transações
  static Future<List<Map<String, dynamic>>> listarTransacoes() async {
    final result = await _functions
        .httpsCallable('listUserTransactions')
        .call();
    final list = result.data['data'] as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}