
// ==========================================
// models/account_model.dart
// Modelo de dados de conta bancária
// ==========================================

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType {
  checking, // Conta corrente
  savings,  // Poupança
  credit,   // Cartão de crédito
  investment, // Investimento
}

class AccountModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double currentBalance;
  final String currency; // BRL, USD, EUR
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.currentBalance,
    this.currency = 'BRL',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria um AccountModel a partir de um documento do Firestore
  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AccountModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.toString() == 'AccountType.${data['type']}',
        orElse: () => AccountType.checking,
      ),
      currentBalance: (data['currentBalance'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'BRL',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converte o AccountModel para um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.toString().split('.').last,
      'currentBalance': currentBalance,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Cria uma cópia do AccountModel com campos atualizados
  AccountModel copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    double? currentBalance,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        currentBalance,
        currency,
        createdAt,
        updatedAt,
      ];
}