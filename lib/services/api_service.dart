// ==========================================
// services/api_service.dart
// Integração com APIs externas via Cloud Functions
// ==========================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

/// Serviço para consumir APIs externas através de Cloud Functions
/// IMPORTANTE: Todas as chamadas passam pelas Cloud Functions para
/// proteger as API keys e evitar exposição no código cliente
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ========== Cotações de Câmbio ==========

  /// Busca as cotações atualizadas de moedas (USD, EUR, GBP)
  /// Endpoint: Cloud Function getExchangeRates (proxy seguro)
  Future<Map<String, dynamic>> getExchangeRates() async {
    try {
      final response = await _client.get(
        Uri.parse(AppConstants.exchangeRatesEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          return data['rates'] as Map<String, dynamic>;
        } else {
          throw Exception(data['error'] ?? 'Erro ao buscar cotações');
        }
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao buscar cotações: ${_parseError(e)}');
    }
  }

  // ========== Notícias Econômicas ==========

  /// Busca notícias econômicas recentes
  /// Parâmetros:
  ///   - category: 'business', 'technology', etc.
  ///   - country: 'br', 'us', etc.
  ///   - pageSize: número de notícias (padrão: 10)
  Future<List<Map<String, dynamic>>> getNews({
    String category = 'business',
    String country = 'br',
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse(AppConstants.newsEndpoint).replace(
        queryParameters: {
          'category': category,
          'country': country,
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['articles'] ?? []);
        } else {
          throw Exception(data['error'] ?? 'Erro ao buscar notícias');
        }
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao buscar notícias: ${_parseError(e)}');
    }
  }

  // ========== Tratamento de Erros ==========

  /// Parseia erro da resposta da API
  String _parseError(dynamic error) {
    if (error is Map && error.containsKey('message')) {
      return error['message'];
    }
    return error.toString();
  }

  /// Cleanup - fechar o client quando o serviço não for mais usado
  void dispose() {
    _client.close();
  }
}