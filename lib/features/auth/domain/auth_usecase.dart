// ==========================================
// features/auth/domain/auth_usecase.dart
// Casos de uso de autenticação (lógica de negócio)
// ==========================================

import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_datasource.dart';

/// Use Case para login com email e senha
class AuthSignInUseCase {
  final AuthDataSource dataSource;

  AuthSignInUseCase({required this.dataSource});

  /// Executa o login com validações
  Future<User> call({
    required String email,
    required String password,
  }) async {
    // Validação: email não pode estar vazio
    if (email.trim().isEmpty) {
      throw Exception('Email não pode estar vazio');
    }

    // Validação: formato de email básico
    if (!_isValidEmail(email)) {
      throw Exception('Formato de email inválido');
    }

    // Validação: senha não pode estar vazia
    if (password.isEmpty) {
      throw Exception('Senha não pode estar vazia');
    }

    // Validação: senha deve ter pelo menos 6 caracteres
    if (password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    // Executa o login
    return await dataSource.signInWithEmail(email, password);
  }

  /// Validação simples de formato de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Use Case para registro de novo usuário
class AuthSignUpUseCase {
  final AuthDataSource dataSource;

  AuthSignUpUseCase({required this.dataSource});

  /// Executa o registro com validações
  Future<User> call({
    required String email,
    required String password,
    required String name,
  }) async {
    // Validação: nome não pode estar vazio
    if (name.trim().isEmpty) {
      throw Exception('Nome não pode estar vazio');
    }

    // Validação: nome deve ter pelo menos 3 caracteres
    if (name.trim().length < 3) {
      throw Exception('Nome deve ter pelo menos 3 caracteres');
    }

    // Validação: email
    if (email.trim().isEmpty) {
      throw Exception('Email não pode estar vazio');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Formato de email inválido');
    }

    // Validação: senha
    if (password.isEmpty) {
      throw Exception('Senha não pode estar vazia');
    }

    if (password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    // Validação: senha deve conter pelo menos uma letra e um número
    if (!_isStrongPassword(password)) {
      throw Exception('Senha deve conter letras e números');
    }

    // Executa o registro
    return await dataSource.signUpWithEmail(email, password, name.trim());
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    // Verifica se tem pelo menos uma letra e um número
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return hasLetter && hasNumber;
  }
}

/// Use Case para login com Google
class AuthGoogleSignInUseCase {
  final AuthDataSource dataSource;

  AuthGoogleSignInUseCase({required this.dataSource});

  Future<User> call() async {
    return await dataSource.signInWithGoogle();
  }
}

/// Use Case para logout
class AuthSignOutUseCase {
  final AuthDataSource dataSource;

  AuthSignOutUseCase({required this.dataSource});

  Future<void> call() async {
    await dataSource.signOut();
  }
}