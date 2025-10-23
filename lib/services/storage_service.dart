// ==========================================
// services/storage_service.dart
// Gerenciamento de cache local com Hive
// ==========================================

import 'package:hive/hive.dart';
import '../core/constants.dart';

/// Serviço para gerenciar cache local usando Hive
/// Permite funcionamento offline e melhora performance
class StorageService {
  // ========== Boxes do Hive ==========

  Box get _transactionsBox => Hive.box(AppConstants.transactionsBox);
  Box get _dashboardBox => Hive.box(AppConstants.dashboardBox);
  Box get _settingsBox => Hive.box(AppConstants.settingsBox);

  // ========== Cache de Transações ==========

  /// Salva lista de transações no cache
  Future<void> cacheTransactions(List<Map<String, dynamic>> transactions) async {
    await _transactionsBox.put('latest', transactions);
    await _transactionsBox.put('lastUpdated', DateTime.now().toIso8601String());
  }

  /// Busca transações do cache
  List<Map<String, dynamic>>? getCachedTransactions() {
    final data = _transactionsBox.get('latest');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return null;
  }

  /// Verifica se o cache de transações está válido (não expirado)
  bool isTransactionsCacheValid() {
    final lastUpdated = _transactionsBox.get('lastUpdated');
    if (lastUpdated == null) return false;

    final cacheTime = DateTime.parse(lastUpdated);
    final now = DateTime.now();
    final difference = now.difference(cacheTime).inSeconds;

    // Cache válido por 1 hora (configurado em AppConstants)
    return difference < AppConstants.maxCacheAge;
  }

  // ========== Cache do Dashboard ==========

  /// Salva resumo do dashboard no cache
  Future<void> cacheDashboardSummary(Map<String, dynamic> summary) async {
    await _dashboardBox.put('summary', summary);
    await _dashboardBox.put('lastUpdated', DateTime.now().toIso8601String());
  }

  /// Busca resumo do dashboard do cache
  Map<String, dynamic>? getCachedDashboardSummary() {
    return _dashboardBox.get('summary');
  }

  /// Verifica se o cache do dashboard está válido
  bool isDashboardCacheValid() {
    final lastUpdated = _dashboardBox.get('lastUpdated');
    if (lastUpdated == null) return false;

    final cacheTime = DateTime.parse(lastUpdated);
    final now = DateTime.now();
    final difference = now.difference(cacheTime).inSeconds;

    return difference < AppConstants.maxCacheAge;
  }

  // ========== Configurações do App ==========

  /// Salva uma configuração
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Busca uma configuração
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Remove uma configuração
  Future<void> removeSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // ========== Limpar Cache ==========

  /// Limpa todo o cache de transações
  Future<void> clearTransactionsCache() async {
    await _transactionsBox.clear();
  }

  /// Limpa todo o cache do dashboard
  Future<void> clearDashboardCache() async {
    await _dashboardBox.clear();
  }

  /// Limpa todos os caches (útil no logout)
  Future<void> clearAllCache() async {
    await _transactionsBox.clear();
    await _dashboardBox.clear();
    // Mantém as configurações mesmo após logout
  }

  // ========== Informações do Cache ==========

  /// Retorna o tamanho do cache em KB
  int getCacheSize() {
    int totalSize = 0;
    totalSize += _transactionsBox.length;
    totalSize += _dashboardBox.length;
    totalSize += _settingsBox.length;
    return totalSize;
  }

  /// Retorna quando foi a última sincronização de transações
  DateTime? getLastTransactionsSync() {
    final lastUpdated = _transactionsBox.get('lastUpdated');
    if (lastUpdated != null) {
      return DateTime.parse(lastUpdated);
    }
    return null;
  }
}