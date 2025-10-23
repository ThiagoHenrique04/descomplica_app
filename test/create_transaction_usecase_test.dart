// ==========================================
// test/create_transaction_usecase_test.dart
// Testes do use case de criação de transação
// ==========================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:descomplica_app/models/transaction_model.dart';
import 'package:descomplica_app/features/transactions/data/transaction_datasource.dart';
import 'package:descomplica_app/features/transactions/domain/create_transaction_usecase.dart';

// Gera o mock com o build_runner
@GenerateMocks([TransactionDataSource])
import 'create_transaction_usecase_test.mocks.dart';

void main() {
  late CreateTransactionUseCase useCase;
  late MockTransactionDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockTransactionDataSource();
    useCase = CreateTransactionUseCase(dataSource: mockDataSource);
  });

  group('CreateTransactionUseCase - Testes de Sucesso', () {
    test('Deve criar transação com sucesso quando todos os dados são válidos', () async {
      // Arrange (Preparar)
      final transaction = TransactionModel(
        id: 'test-id',
        userId: 'user-123',
        accountId: 'account-456',
        title: 'Salário',
        description: 'Salário mensal',
        amount: 5000.00,
        type: TransactionType.income,
        category: 'Salário',
        date: DateTime(2025, 10, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Configura o mock para não lançar exceção
      when(mockDataSource.createTransaction(transaction))
          .thenAnswer((_) async => Future.value());

      // Act (Executar)
      await useCase(transaction);

      // Assert (Verificar)
      // Verifica se o método foi chamado exatamente 1 vez
      verify(mockDataSource.createTransaction(transaction)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('Deve criar transação de despesa com sucesso', () async {
      // Arrange
      final transaction = TransactionModel(
        id: 'test-id-2',
        userId: 'user-123',
        accountId: 'account-456',
        title: 'Compra no supermercado',
        description: 'Compras do mês',
        amount: 350.50,
        type: TransactionType.expense,
        category: 'Alimentação',
        date: DateTime(2025, 10, 18),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockDataSource.createTransaction(transaction))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase(transaction);

      // Assert
      verify(mockDataSource.createTransaction(transaction)).called(1);
    });
  });

  group('CreateTransactionUseCase - Testes de Validação', () {
    test('Deve lançar exceção quando título está vazio', () async {
      // Arrange
      final transaction = TransactionModel(
        id: 'test-id',
        userId: 'user-123',
        accountId: 'account-456',
        title: '', // Título vazio
        description: 'Descrição',
        amount: 100.00,
        type: TransactionType.expense,
        category: 'Outros',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => useCase(transaction),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('título da transação não pode estar vazio'))),
      );

      // Verifica que o dataSource NÃO foi chamado
      verifyNever(mockDataSource.createTransaction(any));
    });

    test('Deve lançar exceção quando valor é zero ou negativo', () async {
      // Arrange - valor zero
      final transactionZero = TransactionModel(
        id: 'test-id',
        userId: 'user-123',
        accountId: 'account-456',
        title: 'Teste',
        description: 'Descrição',
        amount: 0.0, // Valor zero
        type: TransactionType.expense,
        category: 'Outros',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => useCase(transactionZero),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('valor da transação deve ser maior que zero'))),
      );

      // Arrange - valor negativo
      final transactionNegative = transactionZero.copyWith(amount: -100.0);

      expect(
        () => useCase(transactionNegative),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('valor da transação deve ser maior que zero'))),
      );
    });

    test('Deve lançar exceção quando categoria está vazia', () async {
      // Arrange
      final transaction = TransactionModel(
        id: 'test-id',
        userId: 'user-123',
        accountId: 'account-456',
        title: 'Teste',
        description: 'Descrição',
        amount: 100.00,
        type: TransactionType.expense,
        category: '', // Categoria vazia
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => useCase(transaction),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('categoria da transação não pode estar vazia'))),
      );
    });

    test('Deve lançar exceção quando data é no futuro', () async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final transaction = TransactionModel(
        id: 'test-id',
        userId: 'user-123',
        accountId: 'account-456',
        title: 'Teste',
        description: 'Descrição',
        amount: 100.00,
        type: TransactionType.expense,
        category: 'Outros',
        date: futureDate, // Data futura
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => useCase(transaction),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('data futura'))),
      );
    });
  });

  group('CreateTransactionUseCase - Testes de Falha (Saldo Insuficiente)', () {
    test('Deve propagar exceção quando saldo é insuficiente', () async {
      // Arrange
      final transaction = TransactionModel(
        id: 'test-id',
        userId: 'user-123',
        accountId: 'account-456',
        title: 'Compra grande',
        description: 'Compra que excede o saldo',
        amount: 10000.00,
        type: TransactionType.expense,
        category: 'Outros',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simula exceção de saldo insuficiente do DataSource
      when(mockDataSource.createTransaction(transaction))
          .thenThrow(Exception('Saldo insuficiente para realizar esta transação'));

      // Act & Assert
      expect(
        () => useCase(transaction),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Saldo insuficiente'))),
      );

      // Verifica que o método foi chamado
      verify(mockDataSource.createTransaction(transaction)).called(1);
    });

    test('Deve propagar exceção de conflito de transação', () async {
      // Arrange
      final transaction = TransactionModel(
        id: 'test-id',
        userId: 'user-123',
        accountId: 'account-456',
        title: 'Teste conflito',
        description: 'Transação com conflito',
        amount: 100.00,
        type: TransactionType.expense,
        category: 'Outros',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simula erro de conflito do Firestore (quando há concorrência)
      when(mockDataSource.createTransaction(transaction))
          .thenThrow(Exception('Transação abortada devido a conflito. Tente novamente.'));

      // Act & Assert
      expect(
        () => useCase(transaction),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('conflito'))),
      );
    });
  });
}