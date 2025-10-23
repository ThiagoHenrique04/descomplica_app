// Ponto de entrada do aplicativo
// ===============================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'features/auth/presentation/auth_cubit.dart';

void main() async {
  // Garante que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as configurações geradas pelo FlutterFire
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Se já foi inicializado, apenas continua
    print('Firebase já inicializado: $e');
  }

  // Inicializa o Hive para cache local
  await Hive.initFlutter();
  
  // Abre as boxes necessárias para cache
  await Hive.openBox('transactions'); // Cache de transações
  await Hive.openBox('dashboard'); // Cache de dados do dashboard
  await Hive.openBox('settings'); // Configurações do usuário

  // Configura a injeção de dependência
  setupDependencies();

  runApp(const FinanMasterApp());
}

class FinanMasterApp extends StatelessWidget {
  const FinanMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Fornece o AuthCubit para toda a árvore de widgets
      create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
      child: MaterialApp(
        title: 'FinanMaster Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que decide qual tela mostrar baseado no estado de autenticação
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Se está verificando o estado inicial
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Se está autenticado, mostra o home
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        
        // Caso contrário, mostra a tela de login
        return const LoginScreen();
      },
    );
  }
}
