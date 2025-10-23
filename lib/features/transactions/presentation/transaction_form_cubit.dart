// ==========================================
// features/transactions/presentation/transaction_form_cubit.dart
// Cubit para gerenciar formulário de transação
// ==========================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_states.dart';
import '../../../models/transaction_model.dart';
import '../domain/create_transaction_usecase.dart';
import '../data/transaction_datasource.dart';

/// Cubit para gerenciar o formulário de criação/edição de transação
class TransactionFormCubit extends Cubit<TransactionState> {
  final CreateTransactionUseCase createTransactionUseCase;
  final TransactionDataSource dataSource;

  TransactionFormCubit({
    required this.createTransactionUseCase,
    required this.dataSource,
  }) : super(TransactionInitial());

  /// Cria uma nova transação
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      emit(TransactionLoading());

      // Chama o use case que contém as validações de negócio
      await createTransactionUseCase(transaction);

      emit(const TransactionSuccess('Transação criada com sucesso!'));
    } catch (e) {
      emit(TransactionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Atualiza uma transação existente
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      emit(TransactionLoading());
      
      await dataSource.updateTransaction(transaction);
      
      emit(const TransactionSuccess('Transação atualizada com sucesso!'));
    } catch (e) {
      emit(TransactionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Deleta uma transação
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      emit(TransactionLoading());
      
      await dataSource.deleteTransaction(userId, transactionId);
      
      emit(const TransactionSuccess('Transação deletada com sucesso!'));
    } catch (e) {
      emit(TransactionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Carrega a lista de transações
  Future<void> loadTransactions(String userId, {int limit = 20}) async {
    try {
      emit(TransactionLoading());

      // Carrega as transações
      final transactions = await dataSource.getTransactions(userId, limit: limit);

      // Carrega o resumo do mês atual
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final summary = await dataSource.getSummary(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      emit(TransactionsLoaded(
        transactions: transactions,
        summary: summary,
      ));
    } catch (e) {
      emit(TransactionError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}