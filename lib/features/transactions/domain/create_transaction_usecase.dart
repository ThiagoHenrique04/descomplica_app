// ==========================================
// features/transactions/domain/create_transaction_usecase.dart
// Caso de uso para criar transação
// ==========================================

import '../../../models/transaction_model.dart';
import '../data/transaction_datasource.dart';
/// Use Case para criar uma nova transação
/// Contém validações de negócio antes de criar a transação
class CreateTransactionUseCase {
  final TransactionDataSource dataSource;

  CreateTransactionUseCase({required this.dataSource});

  /// Executa a criação da transação com validações
  Future<void> call(TransactionModel transaction) async {
    // Validação 1: Título não pode estar vazio
    if (transaction.title.trim().isEmpty) {
      throw Exception('O título da transação não pode estar vazio');
    }

    // Validação 2: Valor deve ser positivo
    if (transaction.amount <= 0) {
      throw Exception('O valor da transação deve ser maior que zero');
    }

    // Validação 3: Categoria não pode estar vazia
    if (transaction.category.trim().isEmpty) {
      throw Exception('A categoria da transação não pode estar vazia');
    }

    // Validação 4: Data não pode ser no futuro (regra de negócio)
    // Você pode remover esta validação se quiser permitir transações futuras
    if (transaction.date.isAfter(DateTime.now())) {
      throw Exception('Não é permitido criar transações com data futura');
    }

    // Validação 5: Se tiver parcelas, deve ser maior que 0
    if (transaction.installments != null && transaction.installments! <= 0) {
      throw Exception('Número de parcelas deve ser maior que zero');
    }

    // Se todas as validações passarem, cria a transação
    // O DataSource cuidará da lógica de runTransaction() e atualização de saldo
    await dataSource.createTransaction(transaction);
  }
}