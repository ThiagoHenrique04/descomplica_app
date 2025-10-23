// ==========================================
// features/transactions/presentation/transaction_states.dart
// Estados do Cubit de transações
// ==========================================

import 'package:equatable/equatable.dart';
import '../../../models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TransactionInitial extends TransactionState {}

/// Estado de carregamento
class TransactionLoading extends TransactionState {}

/// Estado de sucesso ao criar/atualizar/deletar
class TransactionSuccess extends TransactionState {
  final String message;

  const TransactionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado com lista de transações carregadas
class TransactionsLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final Map<String, double> summary;

  const TransactionsLoaded({
    required this.transactions,
    required this.summary,
  });

  @override
  List<Object?> get props => [transactions, summary];
}

/// Estado de erro
class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
