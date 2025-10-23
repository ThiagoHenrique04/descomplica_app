// ==========================================
// features/auth/presentation/auth_cubit.dart
// Cubit para gerenciar estado de autenticação
// ==========================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_states.dart';
export 'auth_states.dart';
import '../domain/auth_usecase.dart';

/// Cubit responsável por gerenciar o estado de autenticação
class AuthCubit extends Cubit<AuthState> {
  final AuthSignInUseCase signInUseCase;
  final AuthSignUpUseCase signUpUseCase;
  final FirebaseAuth auth;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.auth,
  }) : super(AuthInitial());

  /// Verifica o estado de autenticação ao iniciar o app
  Future<void> checkAuthStatus() async {
    final user = auth.currentUser;
    
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  /// Realiza login com email e senha
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      // Chama o use case que contém as validações
      final user = await signInUseCase(
        email: email,
        password: password,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      // Volta para o estado de não autenticado após mostrar o erro
      emit(AuthUnauthenticated());
    }
  }

  /// Realiza registro de novo usuário
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      emit(AuthLoading());

      // Chama o use case que contém as validações
      final user = await signUpUseCase(
        email: email,
        password: password,
        name: name,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  /// Realiza login com Google
  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());

      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        emit(const AuthError('Login cancelado'));
        emit(AuthUnauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        throw Exception('Erro ao fazer login com Google');
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  /// Realiza logout
  Future<void> signOut() async {
    try {
      await auth.signOut();
      await GoogleSignIn().signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Erro ao fazer logout: $e'));
    }
  }
}
