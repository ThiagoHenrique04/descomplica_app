// ==========================================
// services/firebase_service.dart
// Wrapper para serviços do Firebase
// ==========================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Serviço centralizado para todas as operações do Firebase
/// Facilita testes e manutenção ao encapsular as chamadas diretas
class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirebaseService({
    required this.auth,
    required this.firestore,
    required this.storage,
  });

  // ========== Autenticação ==========

  /// Retorna o usuário autenticado atual
  User? get currentUser => auth.currentUser;

  /// Retorna o ID do usuário autenticado
  String? get currentUserId => currentUser?.uid;

  /// Stream de mudanças no estado de autenticação
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Login com email e senha
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registro de novo usuário
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Logout
  Future<void> signOut() async {
    await auth.signOut();
  }

  // ========== Firestore - Operações Genéricas ==========

  /// Referência para coleção de usuários
  CollectionReference get usersCollection => 
      firestore.collection('users');

  /// Referência para subcoleção de transações de um usuário
  CollectionReference transactionsCollection(String userId) =>
      usersCollection.doc(userId).collection('transactions');

  /// Referência para subcoleção de contas de um usuário
  CollectionReference accountsCollection(String userId) =>
      usersCollection.doc(userId).collection('accounts');

  /// Cria ou atualiza um documento
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await firestore
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  /// Busca um documento por ID
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await firestore.collection(collection).doc(docId).get();
  }

  /// Deleta um documento
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await firestore.collection(collection).doc(docId).delete();
  }

  // ========== Storage ==========

  /// Upload de arquivo para o Firebase Storage
  /// Retorna a URL de download do arquivo
  Future<String> uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      final ref = storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload do arquivo: $e');
    }
  }

  /// Deleta um arquivo do Storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw Exception('Erro ao deletar arquivo: $e');
    }
  }

  /// Upload de comprovante de transação
  /// Retorna a URL do comprovante
  Future<String> uploadReceipt({
    required String userId,
    required String transactionId,
    required File file,
  }) async {
    final path = 'receipts/$userId/$transactionId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadFile(file: file, path: path);
  }
}