import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  static final String _apiKey = dotenv.env['EXCHANGE_API_KEY'] ?? '';
  static final String _baseUrl =
      'https://v6.exchangerate-api.com/v6/$_apiKey/latest/BRL';

  static const Map<String, double> _fallbackRates = {
    'USD': 0.1750,
    'EUR': 0.1550,
    'GBP': 0.1300,
    'JPY': 25.0200,
    'CAD': 0.2410,
    'AUD': 0.2710,
    'CHF': 0.1480,
    'CNY': 1.2350,
  };

  Future<List<ExchangeRate>> getExchangeRates() async {
    try {
      final realRates = await _fetchRealRates().timeout(const Duration(seconds: 5));
      if (realRates.isNotEmpty) return realRates;
    } catch (e) {
      print('⚠️  Erro na API real: $e');
    }

    return _getFallbackRates();
  }

  Future<List<ExchangeRate>> _fetchRealRates() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != 'success') {
        throw Exception('Erro na resposta da API: ${data['error-type']}');
      }

      final rates = data['conversion_rates'] as Map<String, dynamic>;
      final mainCurrencies = _fallbackRates.keys;
      return mainCurrencies
          .where((currency) => rates.containsKey(currency))
          .map((currency) => ExchangeRate.fromJson(currency, (rates[currency] as num).toDouble()))
          .toList();
    } else {
      throw Exception('Erro HTTP: ${response.statusCode}');
    }
  }

  List<ExchangeRate> _getFallbackRates() {
    print('📊 Usando cotações de fallback');

    return _fallbackRates.entries.map((entry) {
      final variation = ((entry.key.hashCode % 100) - 50) / 10000;
      final finalRate = entry.value * (1 + variation);
      return ExchangeRate.fromJson(entry.key, finalRate);
    }).toList();
  }

  Future<double> convertBRLTo(String currency, double brlAmount) async {
    final rates = await getExchangeRates();
    final targetRate = rates.firstWhere(
      (rate) => rate.currency == currency,
      orElse: () => throw Exception('Moeda $currency não encontrada'),
    );
    return brlAmount * targetRate.rate;
  }

  Future<double> convertToBRL(String currency, double foreignAmount) async {
    final rates = await getExchangeRates();
    final targetRate = rates.firstWhere(
      (rate) => rate.currency == currency,
      orElse: () => throw Exception('Moeda $currency não encontrada'),
    );
    return foreignAmount / targetRate.rate;
  }
}
