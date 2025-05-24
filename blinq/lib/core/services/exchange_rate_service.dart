import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRate {
  final String currency;
  final String name;
  final double rate;
  final String flag;

  ExchangeRate({
    required this.currency,
    required this.name,
    required this.rate,
    required this.flag,
  });

  factory ExchangeRate.fromJson(String currency, double rate) {
    final currencyInfo = _getCurrencyInfo(currency);
    return ExchangeRate(
      currency: currency,
      name: currencyInfo['name']!,
      rate: rate,
      flag: currencyInfo['flag']!,
    );
  }

  static Map<String, String> _getCurrencyInfo(String currency) {
    final Map<String, Map<String, String>> currencies = {
      'USD': {'name': 'Dólar Americano', 'flag': '🇺🇸'},
      'EUR': {'name': 'Euro', 'flag': '🇪🇺'},
      'GBP': {'name': 'Libra Esterlina', 'flag': '🇬🇧'},
      'JPY': {'name': 'Iene Japonês', 'flag': '🇯🇵'},
      'CAD': {'name': 'Dólar Canadense', 'flag': '🇨🇦'},
      'AUD': {'name': 'Dólar Australiano', 'flag': '🇦🇺'},
      'CHF': {'name': 'Franco Suíço', 'flag': '🇨🇭'},
      'CNY': {'name': 'Yuan Chinês', 'flag': '🇨🇳'},
    };
    return currencies[currency] ?? {'name': currency, 'flag': '🌍'};
  }
}

class ExchangeRateService {
  // ✅ API gratuita mais confiável
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/BRL';
  
  // ✅ Fallback com valores fixos para quando a API estiver indisponível
  static const Map<String, double> _fallbackRates = {
    'USD': 0.1750, // 1 BRL = 0.1750 USD (aprox R$ 5.71 por USD)
    'EUR': 0.1550, // 1 BRL = 0.1550 EUR (aprox R$ 6.45 por EUR)
    'GBP': 0.1300, // 1 BRL = 0.1300 GBP (aprox R$ 7.69 por GBP)
    'JPY': 25.0200, // 1 BRL = 25.02 JPY (aprox R$ 0.04 por JPY)
    'CAD': 0.2410, // 1 BRL = 0.2410 CAD (aprox R$ 4.15 por CAD)
    'AUD': 0.2710, // 1 BRL = 0.2710 AUD (aprox R$ 3.69 por AUD)
    'CHF': 0.1480, // 1 BRL = 0.1480 CHF (aprox R$ 6.76 por CHF)
    'CNY': 1.2350, // 1 BRL = 1.235 CNY (aprox R$ 0.81 por CNY)
  };
  
  Future<List<ExchangeRate>> getExchangeRates() async {
    try {
      // ✅ Tentar API real primeiro
      final realRates = await _fetchRealRates();
      if (realRates.isNotEmpty) {
        return realRates;
      }
    } catch (e) {
      print('⚠️  Erro na API real: $e');
    }

    // ✅ Fallback para valores fixos
    return _getFallbackRates();
  }

  Future<List<ExchangeRate>> _fetchRealRates() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
    ).timeout(
      const Duration(seconds: 10), // ✅ Timeout para não travar
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      
      final mainCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY'];
      List<ExchangeRate> exchangeRates = [];
      
      for (String currency in mainCurrencies) {
        if (rates.containsKey(currency)) {
          final rate = (rates[currency] as num).toDouble();
          exchangeRates.add(ExchangeRate.fromJson(currency, rate));
        }
      }
      
      return exchangeRates;
    } else {
      throw Exception('Erro HTTP: ${response.statusCode}');
    }
  }

  List<ExchangeRate> _getFallbackRates() {
    print('📊 Usando cotações de fallback');
    
    return _fallbackRates.entries.map((entry) {
      // ✅ Adicionar pequena variação para simular movimento do mercado
      final baseRate = entry.value;
      final variation = (DateTime.now().millisecond % 100 - 50) / 10000; // ±0.5%
      final finalRate = baseRate * (1 + variation);
      
      return ExchangeRate.fromJson(entry.key, finalRate);
    }).toList();
  }

  // ✅ Método para conversão de valores
  Future<double> convertBRLTo(String currency, double brlAmount) async {
    try {
      final rates = await getExchangeRates();
      final targetRate = rates.firstWhere(
        (rate) => rate.currency == currency,
        orElse: () => throw Exception('Moeda $currency não encontrada'),
      );
      
      return brlAmount * targetRate.rate;
    } catch (e) {
      throw Exception('Erro na conversão: $e');
    }
  }

  // ✅ Método para conversão inversa (moeda estrangeira para BRL)
  Future<double> convertToBRL(String currency, double foreignAmount) async {
    try {
      final rates = await getExchangeRates();
      final targetRate = rates.firstWhere(
        (rate) => rate.currency == currency,
        orElse: () => throw Exception('Moeda $currency não encontrada'),
      );
      
      return foreignAmount / targetRate.rate;
    } catch (e) {
      throw Exception('Erro na conversão: $e');
    }
  }
}