// ==========================================
// test/auth_signin_usecase_test.dart
// Testes do use case de login
// ==========================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:descomplica_app/features/auth/data/auth_datasource.dart';
import 'package:descomplica_app/features/auth/domain/auth_usecase.dart';

// Gera mocks
@GenerateMocks([AuthDataSource, User])
import 'auth_signin_usecase_test.mocks.dart';

void main() {
  late AuthSignInUseCase useCase;
  late MockAuthDataSource mockDataSource;
  late MockUser mockUser;

  setUp(() {
    mockDataSource = MockAuthDataSource();
    mockUser = MockUser();
    useCase = AuthSignInUseCase(dataSource: mockDataSource);
  });

  group('AuthSignInUseCase - Testes de Sucesso', () {
    test('Deve fazer login com sucesso quando credenciais são válidas', () async {
      // Arrange
      const email = 'usuario@exemplo.com';
      const password = 'senha123';

      // Configura o mock para retornar um usuário
      when(mockDataSource.signInWithEmail(email, password))
          .thenAnswer((_) async => mockUser);

      // Act
      final result = await useCase(email: email, password: password);

      // Assert
      expect(result, equals(mockUser));
      verify(mockDataSource.signInWithEmail(email, password)).called(1);
    });

    test('Deve aceitar email com espaços nas extremidades (trim)', () async {
      // Arrange
      const email = '  usuario@exemplo.com  '; // Com espaços
      const emailTrimmed = 'usuario@exemplo.com';
      const password = 'senha123';

      when(mockDataSource.signInWithEmail(emailTrimmed, password))
          .thenAnswer((_) async => mockUser);

      // Act
      final result = await useCase(email: email, password: password);

      // Assert
      expect(result, equals(mockUser));
      // Verifica que foi chamado com email sem espaços
      verify(mockDataSource.signInWithEmail(emailTrimmed, password)).called(1);
    });
  });

  group('AuthSignInUseCase - Testes de Validação', () {
    test('Deve lançar exceção quando email está vazio', () async {
      // Arrange
      const email = '';
      const password = 'senha123';

      // Act & Assert
      expect(
        () => useCase(email: email, password: password),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Email não pode estar vazio'))),
      );

      // Verifica que o dataSource NÃO foi chamado
      verifyNever(mockDataSource.signInWithEmail(any, any));
    });

    test('Deve lançar exceção quando email é inválido', () async {
      // Arrange
      const invalidEmails = [
        'emailsemarroba.com',
        'email@',
        '@exemplo.com',
        'email@exemplo',
      ];
      const password = 'senha123';

      // Act & Assert
      for (final email in invalidEmails) {
        expect(
          () => useCase(email: email, password: password),
          throwsA(predicate((e) =>
              e is Exception &&
              e.toString().contains('Formato de email inválido'))),
          reason: 'Falhou para email: $email',
        );
      }
    });

    test('Deve lançar exceção quando senha está vazia', () async {
      // Arrange
      const email = 'usuario@exemplo.com';
      const password = '';

      // Act & Assert
      expect(
        () => useCase(email: email, password: password),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Senha não pode estar vazia'))),
      );
    });

    test('Deve lançar exceção quando senha tem menos de 6 caracteres', () async {
      // Arrange
      const email = 'usuario@exemplo.com';
      const password = '12345'; // 5 caracteres

      // Act & Assert
      expect(
        () => useCase(email: email, password: password),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Senha deve ter pelo menos 6 caracteres'))),
      );
    });
  });

  group('AuthSignInUseCase - Testes de Falha', () {
    test('Deve propagar exceção quando credenciais são inválidas', () async {
      // Arrange
      const email = 'usuario@exemplo.com';
      const password = 'senhaerrada';

      // Simula erro de credenciais inválidas
      when(mockDataSource.signInWithEmail(email, password))
          .thenThrow(Exception('Senha incorreta'));

      // Act & Assert
      expect(
        () => useCase(email: email, password: password),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Senha incorreta'))),
      );

      verify(mockDataSource.signInWithEmail(email, password)).called(1);
    });

    test('Deve propagar exceção quando usuário não encontrado', () async {
      // Arrange
      const email = 'naoexiste@exemplo.com';
      const password = 'senha123';

      when(mockDataSource.signInWithEmail(email, password))
          .thenThrow(Exception('Usuário não encontrado'));

      // Act & Assert
      expect(
        () => useCase(email: email, password: password),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Usuário não encontrado'))),
      );
    });

    test('Deve propagar exceção quando conta está desabilitada', () async {
      // Arrange
      const email = 'desabilitado@exemplo.com';
      const password = 'senha123';

      when(mockDataSource.signInWithEmail(email, password))
          .thenThrow(Exception('Usuário desabilitado'));

      // Act & Assert
      expect(
        () => useCase(email: email, password: password),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Usuário desabilitado'))),
      );
    });
  });
}
