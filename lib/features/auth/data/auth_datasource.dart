// ==========================================
// features/auth/data/auth_datasource.dart
// Fonte de dados para autenticação
// ==========================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface abstrata para o DataSource de autenticação
/// Facilita testes com mocks
abstract class AuthDataSource {
  Future<User> signInWithEmail(String email, String password);
  Future<User> signUpWithEmail(String email, String password, String name);
  Future<User> signInWithGoogle();
  Future<void> signOut();
  User? getCurrentUser();
}

/// Implementação concreta do AuthDataSource
class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthDataSourceImpl({
    required this.auth,
    required this.firestore,
  });

  @override
  User? getCurrentUser() {
    return auth.currentUser;
  }

  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Erro ao fazer login: usuário não encontrado');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros específicos do Firebase Auth
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuário não encontrado');
        case 'wrong-password':
          throw Exception('Senha incorreta');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'user-disabled':
          throw Exception('Usuário desabilitado');
        default:
          throw Exception('Erro ao fazer login: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao fazer login: $e');
    }
  }

  @override
  Future<User> signUpWithEmail(String email, String password, String name) async {
    try {
      // 1. Cria o usuário no Firebase Auth
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Erro ao criar usuário');
      }

      final user = userCredential.user!;

      // 2. Atualiza o displayName do usuário
      await user.updateDisplayName(name);

      // 3. Cria o documento do usuário no Firestore
      await firestore.collection('users').doc(user.uid).set({
        'email': email,
        'name': name,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Cria uma conta padrão inicial
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('accounts')
          .add({
        'name': 'Conta Principal',
        'type': 'checking',
        'currentBalance': 0.0,
        'currency': 'BRL',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros do Firebase Auth
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Este email já está cadastrado');
        case 'weak-password':
          throw Exception('Senha muito fraca. Use pelo menos 6 caracteres');
        case 'invalid-email':
          throw Exception('Email inválido');
        default:
          throw Exception('Erro ao criar conta: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao criar conta: $e');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      // 1. Inicia o fluxo de autenticação do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Login com Google cancelado');
      }

      // 2. Obtém os tokens de autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Cria a credencial do Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Faz login no Firebase com a credencial do Google
      final userCredential = await auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Erro ao fazer login com Google');
      }

      final user = userCredential.user!;

      // 5. Verifica se é o primeiro login (novo usuário)
      // Se for, cria o documento no Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Novo usuário - criar documento e conta padrão
        await firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName ?? 'Usuário',
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Cria conta padrão
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('accounts')
            .add({
          'name': 'Conta Principal',
          'type': 'checking',
          'currentBalance': 0.0,
          'currency': 'BRL',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Faz logout do Firebase e do Google
      await Future.wait([
        auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }
}
