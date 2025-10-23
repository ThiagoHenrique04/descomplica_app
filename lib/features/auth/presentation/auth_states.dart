// ==========================================
// features/auth/presentation/auth_states.dart
// Estados do Cubit de autenticação
// ==========================================

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Estados possíveis da autenticação
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial (verificando autenticação)
class AuthInitial extends AuthState {}

/// Estado de carregamento (processando login/registro)
class AuthLoading extends AuthState {}

/// Estado de autenticado (usuário logado)
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado de não autenticado (usuário deslogado)
class AuthUnauthenticated extends AuthState {}

/// Estado de erro
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
