import 'package:cloud_functions/cloud_functions.dart';

class UserDetails {
  final String uid;
  final String name;
  final String email;
  final String cpf;
  final String telefone;
  final bool mfaEnabled;
  final bool isAdmin;

  // Autor: Gabriel Padreca Nicoletti
  final String? profileImageUrl;

  UserDetails({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.mfaEnabled,
    required this.isAdmin,

    // Autor: Gabriel Padreca Nicoletti
    this.profileImageUrl,
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

      // Autor: Gabriel Padreca Nicoletti
      profileImageUrl: map['profileImageUrl'],
    );
  }

  UserDetails copyWith({
    String? profileImageUrl,
  }) {
    return UserDetails(
      uid: uid,
      name: name,
      email: email,
      cpf: cpf,
      telefone: telefone,
      mfaEnabled: mfaEnabled,
      isAdmin: isAdmin,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
  //
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

  // Autor: Gabriel Padreca Nicoletti
  Future<Map<String, dynamic>> updateUserProfileImage({
    required String profileImageUrl,
  }) async {
    final callable = _functions.httpsCallable('updateUserProfileImage');

    final result = await callable.call({
      'profileImageUrl': profileImageUrl,
    });

    return Map<String, dynamic>.from(result.data);
  }
  //

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