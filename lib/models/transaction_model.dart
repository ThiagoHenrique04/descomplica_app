// ==========================================
// models/transaction_model.dart
// Modelo de dados de transação
// ==========================================

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  income,  // Entrada
  expense, // Saída
}

class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final String accountId;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final int? installments; // Número de parcelas (opcional)
  final String? receiptUrl; // URL do comprovante no Storage
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.installments,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria um TransactionModel a partir de um documento do Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      accountId: data['accountId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      installments: data['installments'],
      receiptUrl: data['receiptUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converte o TransactionModel para um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'accountId': accountId,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category': category,
      'date': Timestamp.fromDate(date),
      'installments': installments,
      'receiptUrl': receiptUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Cria uma cópia do TransactionModel com campos atualizados
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? title,
    String? description,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    int? installments,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      installments: installments ?? this.installments,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        accountId,
        title,
        description,
        amount,
        type,
        category,
        date,
        installments,
        receiptUrl,
        createdAt,
        updatedAt,
      ];
}
 