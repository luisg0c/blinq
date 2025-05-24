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
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/BRL';
  
  Future<List<ExchangeRate>> getExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
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
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}