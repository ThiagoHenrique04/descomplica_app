// ==========================================
// features/transactions/data/transaction_datasource.dart
// Fonte de dados para transações (com runTransaction)
// ==========================================

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/transaction_model.dart';
import '../../../models/account_model.dart';

/// Interface para o DataSource de transações
abstract class TransactionDataSource {
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String userId, String transactionId);
  Future<List<TransactionModel>> getTransactions(String userId, {int limit = 20});
  Future<TransactionModel?> getTransactionById(String userId, String transactionId);
  Future<Map<String, double>> getSummary(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Implementação do TransactionDataSource
class TransactionDataSourceImpl implements TransactionDataSource {
  final FirebaseFirestore firestore;

  TransactionDataSourceImpl({required this.firestore});

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      // IMPORTANTE: Usa runTransaction() para garantir atomicidade e consistência
      // Esta é a forma CORRETA de atualizar saldo e criar transação simultaneamente
      await firestore.runTransaction((txn) async {
        // 1. Referência para a conta que será afetada
        final accountRef = firestore
            .collection('users')
            .doc(transaction.userId)
            .collection('accounts')
            .doc(transaction.accountId);

        // 2. LÊ o documento da conta dentro da transação
        // IMPORTANTE: A leitura deve vir ANTES de qualquer escrita
        final accountSnapshot = await txn.get(accountRef);

        if (!accountSnapshot.exists) {
          throw Exception('Conta não encontrada');
        }

        // 3. Converte o snapshot para o modelo de conta
        final account = AccountModel.fromFirestore(accountSnapshot);

        // 4. Calcula o novo saldo baseado no tipo de transação
        double newBalance = account.currentBalance;
        
        if (transaction.type == TransactionType.income) {
          // Entrada: adiciona ao saldo
          newBalance += transaction.amount;
        } else {
          // Saída: subtrai do saldo
          newBalance -= transaction.amount;
        }

        // 5. Validação: verifica se o saldo ficará negativo (opcional)
        // Você pode comentar esta validação se quiser permitir saldo negativo
        if (newBalance < 0) {
          throw Exception('Saldo insuficiente para realizar esta transação');
        }

        // 6. Referência para a nova transação
        final transactionRef = firestore
            .collection('users')
            .doc(transaction.userId)
            .collection('transactions')
            .doc(); // Gera um ID automático

        // 7. ESCREVE a transação dentro da transaction do Firestore
        txn.set(transactionRef, transaction.copyWith(
          id: transactionRef.id,
        ).toFirestore());

        // 8. ATUALIZA o saldo da conta dentro da transaction
        txn.update(accountRef, {
          'currentBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // OBSERVAÇÃO IMPORTANTE:
        // O Firestore garante que TODAS essas operações serão executadas
        // atomicamente. Se qualquer operação falhar, NENHUMA será aplicada.
        // Além disso, se houver conflito (outra transação modificando os
        // mesmos dados), o Firestore automaticamente faz RETRY desta função.
      });

  developer.log('✅ Transação criada com sucesso de forma atômica', name: 'transaction_datasource');
    } on FirebaseException catch (e) {
      // Erros específicos do Firestore
      if (e.code == 'aborted') {
        throw Exception('Transação abortada devido a conflito. Tente novamente.');
      }
      throw Exception('Erro do Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao criar transação: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      // Para atualizar uma transação, também usamos runTransaction()
      // pois precisamos recalcular o saldo
      await firestore.runTransaction((txn) async {
        // 1. Busca a transação antiga
        final oldTransactionRef = firestore
            .collection('users')
            .doc(transaction.userId)
            .collection('transactions')
            .doc(transaction.id);

        final oldTransactionSnapshot = await txn.get(oldTransactionRef);
        
        if (!oldTransactionSnapshot.exists) {
          throw Exception('Transação não encontrada');
        }

        final oldTransaction = TransactionModel.fromFirestore(oldTransactionSnapshot);

        // 2. Busca a conta
        final accountRef = firestore
            .collection('users')
            .doc(transaction.userId)
            .collection('accounts')
            .doc(transaction.accountId);

        final accountSnapshot = await txn.get(accountRef);
        
        if (!accountSnapshot.exists) {
          throw Exception('Conta não encontrada');
        }

        final account = AccountModel.fromFirestore(accountSnapshot);

        // 3. Reverte o efeito da transação antiga no saldo
        double newBalance = account.currentBalance;
        
        if (oldTransaction.type == TransactionType.income) {
          newBalance -= oldTransaction.amount;
        } else {
          newBalance += oldTransaction.amount;
        }

        // 4. Aplica o efeito da nova transação
        if (transaction.type == TransactionType.income) {
          newBalance += transaction.amount;
        } else {
          newBalance -= transaction.amount;
        }

        // 5. Validação de saldo
        if (newBalance < 0) {
          throw Exception('Saldo insuficiente após atualização');
        }

        // 6. Atualiza a transação
        txn.update(oldTransactionRef, transaction.toFirestore());

        // 7. Atualiza o saldo da conta
        txn.update(accountRef, {
          'currentBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Erro ao atualizar transação: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await firestore.runTransaction((txn) async {
        // 1. Busca a transação a ser deletada
        final transactionRef = firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transactionId);

        final transactionSnapshot = await txn.get(transactionRef);
        
        if (!transactionSnapshot.exists) {
          throw Exception('Transação não encontrada');
        }

        final transaction = TransactionModel.fromFirestore(transactionSnapshot);

        // 2. Busca a conta
        final accountRef = firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc(transaction.accountId);

        final accountSnapshot = await txn.get(accountRef);
        
        if (!accountSnapshot.exists) {
          throw Exception('Conta não encontrada');
        }

        final account = AccountModel.fromFirestore(accountSnapshot);

        // 3. Reverte o efeito da transação no saldo
        double newBalance = account.currentBalance;
        
        if (transaction.type == TransactionType.income) {
          newBalance -= transaction.amount;
        } else {
          newBalance += transaction.amount;
        }

        // 4. Deleta a transação
        txn.delete(transactionRef);

        // 5. Atualiza o saldo da conta
        txn.update(accountRef, {
          'currentBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Erro ao deletar transação: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações: $e');
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(
    String userId,
    String transactionId,
  ) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar transação: $e');
    }
  }

  /// Busca o total de receitas e despesas de um período
  @override
  Future<Map<String, double>> getSummary(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore
          .collection('users')
          .doc(userId)
          .collection('transactions');

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      
      double totalIncome = 0;
      double totalExpense = 0;

      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    } catch (e) {
      throw Exception('Erro ao buscar resumo: $e');
    }
  }
}
