class Validators {
  // Evitar instanciação
  Validators._();

  /// Validação de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  /// Validação de senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }

    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  /// Validação de valor monetário
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um valor';
    }

    final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(cleanValue);

    if (amount == null) {
      return 'Valor inválido';
    }

    if (amount <= 0) {
      return 'O valor deve ser maior que zero';
    }

    return null;
  }

  /// Validação de senha de transação
  static String? validateTransactionPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira a senha de transação';
    }

    if (value.length < 4) {
      return 'A senha deve ter pelo menos 4 dígitos';
    }

    final numericRegExp = RegExp(r'^[0-9]+$');
    if (!numericRegExp.hasMatch(value)) {
      return 'A senha deve conter apenas números';
    }

    return null;
  }
}
