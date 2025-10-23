// ==========================================
// core/di.dart
// Injeção de Dependência com GetIt
// ==========================================

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../services/firebase_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../features/auth/data/auth_datasource.dart';
import '../features/auth/domain/auth_usecase.dart';
import '../features/auth/presentation/auth_cubit.dart';
import '../features/transactions/data/transaction_datasource.dart';
import '../features/transactions/domain/create_transaction_usecase.dart';

// Instância global do GetIt
final getIt = GetIt.instance;

/// Configura todas as dependências do aplicativo
/// Deve ser chamado no main() antes de runApp()
void setupDependencies() {
  // ========== Serviços do Firebase ==========
  
  // Registra as instâncias singleton do Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Wrapper personalizado do Firebase
  getIt.registerLazySingleton<FirebaseService>(
    () => FirebaseService(
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),
    ),
  );

  // ========== Serviços de API e Storage ==========
  
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<StorageService>(() => StorageService());

  // ========== Feature: Autenticação ==========
  
  // Data Source
  getIt.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<AuthSignInUseCase>(
    () => AuthSignInUseCase(dataSource: getIt<AuthDataSource>()),
  );
  
  getIt.registerLazySingleton<AuthSignUpUseCase>(
    () => AuthSignUpUseCase(dataSource: getIt<AuthDataSource>()),
  );

  // Presentation (Cubit)
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      signInUseCase: getIt<AuthSignInUseCase>(),
      signUpUseCase: getIt<AuthSignUpUseCase>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // ========== Feature: Transações ==========
  
  // Data Source
  getIt.registerLazySingleton<TransactionDataSource>(
    () => TransactionDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<CreateTransactionUseCase>(
    () => CreateTransactionUseCase(
      dataSource: getIt<TransactionDataSource>(),
    ),
  );
}