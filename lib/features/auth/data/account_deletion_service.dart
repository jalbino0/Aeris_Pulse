import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletionException implements Exception {
  final String message;

  const AccountDeletionException(this.message);

  @override
  String toString() => message;
}

class AccountDeletionService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AccountDeletionService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw const AccountDeletionException(
        'Não existe uma conta autenticada para excluir.',
      );
    }

    final email = user.email;

    if (email == null || email.isEmpty) {
      throw const AccountDeletionException(
        'Não foi possível identificar o e-mail da conta.',
      );
    }

    if (password.isEmpty) {
      throw const AccountDeletionException(
        'Informe sua senha para confirmar a exclusão.',
      );
    }

    final usesPassword = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );

    if (!usesPassword) {
      throw const AccountDeletionException(
        'Esta forma de autenticação ainda não permite '
        'a exclusão diretamente pelo aplicativo.',
      );
    }

    final userId = user.uid;

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw AccountDeletionException(_authenticationErrorMessage(error.code));
    }

    if (_auth.currentUser?.uid != userId) {
      throw const AccountDeletionException(
        'A sessão mudou durante a confirmação. '
        'Entre novamente na sua conta.',
      );
    }

    final userDocument = _firestore.collection('users').doc(userId);

    try {
      await _firestore.waitForPendingWrites().timeout(
        const Duration(seconds: 30),
      );

      await _deleteCollection(userDocument.collection('favorites'));

      await _deleteCollection(userDocument.collection('preferences'));
    } on TimeoutException {
      throw const AccountDeletionException(
        'Não foi possível confirmar todas as exclusões '
        'no Firestore. Alguns dados podem ter sido removidos, '
        'mas sua conta continua ativa. '
        'Verifique a conexão e tente novamente.',
      );
    } on FirebaseException {
      throw const AccountDeletionException(
        'O Firebase não confirmou a remoção de todos os dados. '
        'Algumas preferências podem ter sido excluídas, '
        'mas sua conta continua ativa. '
        'Tente novamente com uma conexão estável.',
      );
    } catch (_) {
      throw const AccountDeletionException(
        'Ocorreu um problema ao remover as preferências. '
        'Sua conta continua ativa. '
        'Verifique os dados e tente novamente.',
      );
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      throw AccountDeletionException(
        'As preferências na nuvem foram removidas, '
        'mas não foi possível concluir a exclusão da conta. '
        '${_authenticationErrorMessage(error.code)}',
      );
    } catch (_) {
      throw const AccountDeletionException(
        'As preferências na nuvem foram removidas, '
        'mas a exclusão da conta não foi confirmada. '
        'Verifique sua conexão e tente novamente.',
      );
    }
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final snapshot = await collection
          .limit(200)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 30));

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit().timeout(const Duration(seconds: 30));
    }
  }

  String _authenticationErrorMessage(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Senha incorreta. Verifique e tente novamente.';
      case 'requires-recent-login':
        return 'É necessário confirmar sua identidade novamente.';
      case 'network-request-failed':
        return 'Não foi possível conectar ao Firebase. '
            'Verifique sua conexão.';
      case 'too-many-requests':
        return 'Muitas tentativas de autenticação. '
            'Tente novamente mais tarde.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
        return 'A conta não foi encontrada no Firebase.';
      case 'user-mismatch':
        return 'As credenciais não correspondem à conta atual.';
      default:
        return 'Não foi possível confirmar a operação. '
            'Código: $code';
    }
  }
}
