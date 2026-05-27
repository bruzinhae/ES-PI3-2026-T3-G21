import 'package:cloud_functions/cloud_functions.dart';

class UserDetails {
  final String uid;
  final String name;
  final String email;
  final String cpf;
  final String telefone;
  final bool mfaEnabled;
  final bool isAdmin;

  UserDetails({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.mfaEnabled,
    required this.isAdmin,
  });

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      telefone: map['telefone'] ?? '',
      mfaEnabled: map['mfaEnabled'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
    );
  }
}

class UserService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  Future<UserDetails> getUserDetails() async {
    final callable = _functions.httpsCallable('getUserDetails');

    final result = await callable.call();

    final data = Map<String, dynamic>.from(result.data);

    return UserDetails.fromMap(data);
  }

  Future<Map<String, dynamic>> updateUserEmail({
    required String newEmail,
  }) async {
    final callable = _functions.httpsCallable('updateUserEmail');

    final result = await callable.call({
      'newEmail': newEmail,
    });

    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> sendMfaCodeByEmail() async {
    final callable = _functions.httpsCallable('sendMfaCodeByEmail');

    final result = await callable.call();

    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> enableMfa({
    required String code,
  }) async {
    final callable = _functions.httpsCallable('enableMfa');

    final result = await callable.call({
      'code': code,
    });

    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> disableMfa() async {
    final callable = _functions.httpsCallable('disableMfa');

    final result = await callable.call();

    return Map<String, dynamic>.from(result.data);
  }
}