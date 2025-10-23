// ==========================================
// test/mocks/mock_datasources.dart
// Helpers para criar mocks mais complexos
// ==========================================

import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper para criar mocks de DocumentSnapshot
/// NOTE: `DocumentSnapshot` is a sealed class in newer firestore versions,
/// so we avoid implementing it directly. Use this Mock to stub behaviors
/// or wrap a real DocumentSnapshot in tests.
class MockDocumentSnapshot extends Mock {}

/// Helper para criar mocks de QuerySnapshot
/// Avoid implementing the sealed `QuerySnapshot` type directly.
class MockQuerySnapshot extends Mock {}

/// Helper para criar dados de teste
class TestData {
  static Map<String, dynamic> get validTransactionData => {
    'userId': 'user-123',
    'accountId': 'account-456',
    'title': 'Teste',
    'description': 'Descrição de teste',
    'amount': 100.00,
    'type': 'expense',
    'category': 'Outros',
    'date': Timestamp.now(),
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };

  static Map<String, dynamic> get validUserData => {
    'email': 'teste@exemplo.com',
    'name': 'Usuário Teste',
    'photoUrl': null,
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };

  static Map<String, dynamic> get validAccountData => {
    'userId': 'user-123',
    'name': 'Conta Corrente',
    'type': 'checking',
    'currentBalance': 1000.00,
    'currency': 'BRL',
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };
}