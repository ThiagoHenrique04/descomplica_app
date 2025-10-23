// ==========================================
// screens/home/home_screen.dart
// Dashboard principal com gráficos e resumo
// ==========================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../widgets/card_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dados de demonstração
  final double totalBalance = 15420.50;
  final double monthIncome = 8500.00;
  final double monthExpense = 4320.80;
  
  // Cotações (simuladas)
  final Map<String, double> exchangeRates = {
    'USD': 5.45,
    'EUR': 6.12,
    'GBP': 7.03,
  };

  @override
  Widget build(BuildContext context) {
    // balance is calculated within _buildBalanceCard(); no need to compute it here
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navegar para notificações
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navegar para configurações
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implementar refresh
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saldo geral (destaque)
              _buildBalanceCard(),
              
              const SizedBox(height: 24),

              // Cards de receitas e despesas
              Row(
                children: [
                  Expanded(
                    child: CardInfo(
                      title: 'Receitas',
                      value: monthIncome,
                      icon: Icons.arrow_upward,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CardInfo(
                      title: 'Despesas',
                      value: monthExpense,
                      icon: Icons.arrow_downward,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Gráfico de pizza (distribuição de despesas)
              Text(
                'Distribuição de Despesas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildExpenseChart(),

              const SizedBox(height: 24),

              // Cotações de moedas
              Text(
                'Cotações',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildExchangeRatesCard(),

              const SizedBox(height: 24),

              // Próximas contas
              Text(
                'Próximas Contas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildUpcomingBills(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navegar para formulário de nova transação
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
      ),
    );
  }

  /// Card de saldo geral com gradiente
  Widget _buildBalanceCard() {
    final balance = monthIncome - monthExpense;
    final isPositive = balance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha((0.3 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Geral',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${AppConstants.currencySymbol} ${totalBalance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.success : AppColors.error,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo do mês: ${AppConstants.currencySymbol} ${balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Gráfico de pizza com distribuição de despesas
  Widget _buildExpenseChart() {
    // Dados de exemplo
    final expenseData = {
      'Alimentação': 1200.00,
      'Transporte': 450.00,
      'Moradia': 1800.00,
      'Lazer': 380.50,
      'Outros': 490.30,
    };

    final total = expenseData.values.reduce((a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: expenseData.entries.map((entry) {
                final percentage = (entry.value / total * 100);
                return PieChartSectionData(
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: _getCategoryColor(entry.key),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Retorna cor baseada na categoria
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Alimentação':
        return Colors.orange;
      case 'Transporte':
        return Colors.blue;
      case 'Moradia':
        return Colors.red;
      case 'Lazer':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Card de cotações de moedas
  Widget _buildExchangeRatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: exchangeRates.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'R\$ ${entry.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.grey400,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Lista de próximas contas a vencer
  Widget _buildUpcomingBills() {
    // Dados de exemplo
    final upcomingBills = [
      {'title': 'Aluguel', 'date': '05/11', 'amount': 1800.00},
      {'title': 'Conta de Luz', 'date': '10/11', 'amount': 180.50},
      {'title': 'Internet', 'date': '15/11', 'amount': 120.00},
    ];

    return Column(
      children: upcomingBills.map((bill) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.warning,
              child: Icon(Icons.calendar_today, color: Colors.white),
            ),
            title: Text(bill['title'] as String),
            subtitle: Text('Vencimento: ${bill['date']}'),
            trailing: Text(
              'R\$ ${(bill['amount'] as double).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}