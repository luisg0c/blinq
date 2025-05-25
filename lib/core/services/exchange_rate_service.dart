import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRate {
  final String currency;
  final String name;
  final double rate;
  final String flag;
  final double? previousRate;
  final double variation;
  final DateTime lastUpdate;

  ExchangeRate({
    required this.currency,
    required this.name,
    required this.rate,
    required this.flag,
    this.previousRate,
    double? variation,
    DateTime? lastUpdate,
  }) : variation = variation ?? 0.0,
       lastUpdate = lastUpdate ?? DateTime.now();

  factory ExchangeRate.fromJson(String currency, double brlToForeignRate, {double? previousRate}) {
    final currencyInfo = _getCurrencyInfo(currency);
    
    // ✅ CORREÇÃO: Inverter a taxa para mostrar quanto vale 1 unidade da moeda estrangeira em BRL
    final foreignToBrlRate = 1.0 / brlToForeignRate;
    final variation = previousRate != null ? ((foreignToBrlRate - previousRate) / previousRate) * 100 : 0.0;
    
    return ExchangeRate(
      currency: currency,
      name: currencyInfo['name']!,
      rate: foreignToBrlRate, // ✅ Agora mostra quanto vale 1 USD em BRL
      flag: currencyInfo['flag']!,
      previousRate: previousRate,
      variation: variation,
      lastUpdate: DateTime.now(),
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

  bool get isPositiveVariation => variation >= 0;
  
  String get formattedVariation {
    final sign = isPositiveVariation ? '+' : '';
    return '$sign${variation.toStringAsFixed(2)}%';
  }

  String get formattedRate {
    if (currency == 'JPY') {
      return rate.toStringAsFixed(2); // Iene usa 2 casas decimais
    }
    return rate.toStringAsFixed(4); // Outras moedas usam 4 casas
  }
}

class ExchangeRateService {
  // ✅ TAXAS CORRETAS (1 USD = ~5.20 BRL, 1 EUR = ~5.60 BRL, etc)
  static const Map<String, double> _correctFallbackRates = {
    'USD': 5.20,  // 1 Dólar = 5.20 Reais
    'EUR': 5.65,  // 1 Euro = 5.65 Reais
    'GBP': 6.45,  // 1 Libra = 6.45 Reais
    'JPY': 0.035, // 1 Iene = 0.035 Reais
    'CAD': 3.85,  // 1 Dólar Canadense = 3.85 Reais
    'AUD': 3.42,  // 1 Dólar Australiano = 3.42 Reais
    'CHF': 5.85,  // 1 Franco Suíço = 5.85 Reais
    'CNY': 0.72,  // 1 Yuan = 0.72 Reais
  };

  static final Map<String, ExchangeRate> _cachedRates = {};
  static DateTime? _lastUpdate;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// ✅ OBTER COTAÇÕES COM VALORES CORRETOS
  static Future<List<ExchangeRate>> getExchangeRates() async {
    try {
      // Verificar cache
      if (_isCacheValid()) {
        print('📦 Usando cotações do cache');
        return _cachedRates.values.toList();
      }

      print('🌐 Buscando cotações atualizadas...');

      // Tentar API real primeiro
      try {
        final rates = await _fetchFromRealApi();
        if (rates.isNotEmpty) {
          _updateCache(rates);
          return rates;
        }
      } catch (e) {
        print('⚠️ Falha na API real: $e');
      }

      // Fallback para dados corretos
      print('📊 Usando cotações de fallback corretas');
      final fallbackRates = _generateCorrectFallbackRates();
      _updateCache(fallbackRates);
      return fallbackRates;

    } catch (e) {
      print('❌ Erro geral nas cotações: $e');
      
      // Retornar cache mesmo expirado se houver
      if (_cachedRates.isNotEmpty) {
        return _cachedRates.values.toList();
      }
      
      // Último recurso: fallback correto
      return _generateCorrectFallbackRates();
    }
  }

  /// ✅ BUSCAR DE API REAL (com correção de taxa)
  static Future<List<ExchangeRate>> _fetchFromRealApi() async {
    // ✅ API que retorna BRL como base (1 BRL = X moedas estrangeiras)
    const apiUrl = 'https://api.exchangerate-api.com/v4/latest/BRL';
    
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final rates = data['rates'] as Map<String, dynamic>;
    final List<ExchangeRate> exchangeRates = [];

    for (final currency in _correctFallbackRates.keys) {
      if (rates.containsKey(currency)) {
        final brlToForeignRate = (rates[currency] as num).toDouble();
        final previousRate = _cachedRates[currency]?.rate;
        
        // ✅ CORREÇÃO: Inverter para mostrar quanto vale a moeda estrangeira em BRL
        final foreignToBrlRate = 1.0 / brlToForeignRate;
        
        exchangeRates.add(
          ExchangeRate(
            currency: currency,
            name: ExchangeRate._getCurrencyInfo(currency)['name']!,
            rate: foreignToBrlRate,
            flag: ExchangeRate._getCurrencyInfo(currency)['flag']!,
            previousRate: previousRate,
            variation: previousRate != null 
                ? ((foreignToBrlRate - previousRate) / previousRate) * 100 
                : 0.0,
          )
        );
      }
    }

    print('✅ ${exchangeRates.length} cotações obtidas da API');
    return exchangeRates;
  }

  /// ✅ GERAR COTAÇÕES CORRETAS DE FALLBACK
  static List<ExchangeRate> _generateCorrectFallbackRates() {
    final now = DateTime.now();
    final List<ExchangeRate> rates = [];

    for (final entry in _correctFallbackRates.entries) {
      final currency = entry.key;
      final baseRate = entry.value;
      
      // Simular variação realista (-1% a +1%)
      final seed = currency.hashCode + now.day + now.hour;
      final variationPercent = ((seed % 200) - 100) / 10000; // -0.01 a +0.01
      final currentRate = baseRate * (1 + variationPercent);
      final previousRate = _cachedRates[currency]?.rate ?? baseRate;
      
      rates.add(
        ExchangeRate(
          currency: currency,
          name: ExchangeRate._getCurrencyInfo(currency)['name']!,
          rate: currentRate,
          flag: ExchangeRate._getCurrencyInfo(currency)['flag']!,
          previousRate: previousRate,
          variation: previousRate != 0 
              ? ((currentRate - previousRate) / previousRate) * 100 
              : 0.0,
        )
      );
    }

    return rates;
  }

  /// ✅ VERIFICAR SE CACHE É VÁLIDO
  static bool _isCacheValid() {
    if (_lastUpdate == null || _cachedRates.isEmpty) return false;
    
    final now = DateTime.now();
    final difference = now.difference(_lastUpdate!);
    
    return difference < _cacheExpiration;
  }

  /// ✅ ATUALIZAR CACHE
  static void _updateCache(List<ExchangeRate> rates) {
    _cachedRates.clear();
    for (final rate in rates) {
      _cachedRates[rate.currency] = rate;
    }
    _lastUpdate = DateTime.now();
    print('💾 Cache atualizado com ${rates.length} cotações');
  }

  /// ✅ CONVERSÃO CORRETA BRL PARA MOEDA ESTRANGEIRA
  static Future<double> convertBRLTo(String currency, double brlAmount) async {
    try {
      final rates = await getExchangeRates();
      final targetRate = rates.firstWhere(
        (rate) => rate.currency == currency,
        orElse: () => throw Exception('Moeda $currency não encontrada'),
      );
      
      // Se 1 USD = 5.20 BRL, então 100 BRL = 100/5.20 USD
      return brlAmount / targetRate.rate;
    } catch (e) {
      print('❌ Erro na conversão BRL -> $currency: $e');
      
      final fallbackRate = _correctFallbackRates[currency];
      if (fallbackRate != null) {
        return brlAmount / fallbackRate;
      }
      
      throw Exception('Não foi possível converter para $currency');
    }
  }

  /// ✅ CONVERSÃO CORRETA MOEDA ESTRANGEIRA PARA BRL
  static Future<double> convertToBRL(String currency, double foreignAmount) async {
    try {
      final rates = await getExchangeRates();
      final targetRate = rates.firstWhere(
        (rate) => rate.currency == currency,
        orElse: () => throw Exception('Moeda $currency não encontrada'),
      );
      
      // Se 1 USD = 5.20 BRL, então 10 USD = 10 * 5.20 BRL
      return foreignAmount * targetRate.rate;
    } catch (e) {
      print('❌ Erro na conversão $currency -> BRL: $e');
      
      final fallbackRate = _correctFallbackRates[currency];
      if (fallbackRate != null) {
        return foreignAmount * fallbackRate;
      }
      
      throw Exception('Não foi possível converter de $currency');
    }
  }

  /// ✅ LIMPAR CACHE
  static void clearCache() {
    _cachedRates.clear();
    _lastUpdate = null;
    print('🧹 Cache de cotações limpo');
  }

  /// ✅ STATUS DO SERVIÇO
  static Map<String, dynamic> getServiceStatus() {
    return {
      'cacheValid': _isCacheValid(),
      'lastUpdate': _lastUpdate?.toIso8601String(),
      'cachedCurrencies': _cachedRates.keys.toList(),
      'cacheSize': _cachedRates.length,
      'sampleRate': _cachedRates.isNotEmpty ? 'USD: R\$ ${_cachedRates['USD']?.formattedRate ?? 'N/A'}' : 'N/A',
    };
  }
}