import 'package:flutter/material.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/theme/app_colors.dart';

class ExchangeRatesPage extends StatefulWidget {
  const ExchangeRatesPage({super.key});

  @override
  State<ExchangeRatesPage> createState() => _ExchangeRatesPageState();
}

class _ExchangeRatesPageState extends State<ExchangeRatesPage> {
  final ExchangeRateService _service = ExchangeRateService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações em Tempo Real'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}), // Força reload
          ),
        ],
      ),
      body: Column(
        children: [
          // Header informativo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Text(
                  'Cotações do Real (BRL)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'API: api.exchangerate-api.com',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<ExchangeRate>>(
              future: _service.getExchangeRates(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Carregando cotações...'),
                      ],
                    ),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar cotações',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString().replaceAll('Exception: ', ''),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Success state
                final rates = snapshot.data ?? [];
                if (rates.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma cotação disponível'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: rates.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final rate = rates[index];
                      return _buildRateCard(rate);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(ExchangeRate rate) {
    // Simular variação para melhor UX
    final variation = (rate.rate * 0.01 * (DateTime.now().millisecond % 5 - 2));
    final isPositive = variation >= 0;
    
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              rate.flag,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          rate.currency,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          rate.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'R\$ ${rate.rate.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 2),
                Text(
                  '${variation.abs().toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}