
// ==========================================
// core/constants.dart
// Constantes globais do aplicativo
// ==========================================

class AppConstants {
  // ========== Firebase Collections ==========
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String accountsCollection = 'accounts';
  static const String categoriesCollection = 'categories';

  // ========== Cloud Functions Endpoints ==========
  static const String baseCloudFunctionsUrl = 
      'https://us-central1-finanmaster-mobile.cloudfunctions.net';
  
  static const String exchangeRatesEndpoint = '$baseCloudFunctionsUrl/getExchangeRates';
  static const String newsEndpoint = '$baseCloudFunctionsUrl/getNews';

  // ========== Hive Box Names ==========
  static const String transactionsBox = 'transactions';
  static const String dashboardBox = 'dashboard';
  static const String settingsBox = 'settings';

  // ========== Categorias de Transação ==========
  static const List<String> expenseCategories = [
    'Conta Fixa',
    'Conta Variável',
    'Conta Aleatória',
    'Alimentação',
    'Transporte',
    'Saúde',
    'Educação',
    'Lazer',
    'Outros',
  ];

  static const List<String> incomeCategories = [
    'Salário',
    'Benefício',
    'Freelance',
    'Investimento',
    'Outro',
  ];

  // ========== Limites e Paginação ==========
  static const int transactionsPageSize = 20;
  static const int maxCacheAge = 3600; // 1 hora em segundos

  // ========== Formatação ==========
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String currencySymbol = 'R\$';
}
