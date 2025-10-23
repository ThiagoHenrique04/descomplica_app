// ==========================================
// widgets/transaction_card.dart
// Card para exibir transação na lista
// ==========================================

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.error;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone da categoria
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).toInt()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category, isIncome),
                  color: color,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Informações da transação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Categoria e data
                    Row(
                      children: [
                        Text(
                          transaction.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey600,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(color: AppColors.grey600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(transaction.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Valor
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} ${AppConstants.currencySymbol} ${transaction.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  
                  // Menu de ações
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Excluir', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retorna o ícone apropriado para a categoria
  IconData _getCategoryIcon(String category, bool isIncome) {
    if (isIncome) {
      switch (category.toLowerCase()) {
        case 'salário':
          return Icons.work;
        case 'benefício':
          return Icons.card_giftcard;
        case 'freelance':
          return Icons.laptop;
        case 'investimento':
          return Icons.trending_up;
        default:
          return Icons.attach_money;
      }
    } else {
      switch (category.toLowerCase()) {
        case 'alimentação':
          return Icons.restaurant;
        case 'transporte':
          return Icons.directions_car;
        case 'moradia':
          return Icons.home;
        case 'saúde':
          return Icons.local_hospital;
        case 'educação':
          return Icons.school;
        case 'lazer':
          return Icons.movie;
        case 'conta fixa':
          return Icons.receipt;
        case 'conta variável':
          return Icons.receipt_long;
        default:
          return Icons.shopping_bag;
      }
    }
  }

  /// Formata a data para exibição
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
