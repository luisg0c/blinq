class Validators {
  // Validação de email seguindo regras do Firebase
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email não pode estar vazio';
    }

    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        caseSensitive: false);

    if (!emailRegex.hasMatch(email)) {
      return 'Digite um email válido';
    }

    // Verificações adicionais de tamanho
    if (email.length > 254) {
      return 'Email muito longo';
    }

    return null;
  }

  // Validação de senha para registro local
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Senha não pode estar vazia';
    }

    // Requisitos mínimos do Firebase Authentication
    if (password.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }

    // Validações adicionais de segurança (opcionais)
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // Sugestões de força de senha (não bloqueantes)
    if (!hasUppercase || !hasLowercase || !hasDigits || !hasSpecialChar) {
      return 'Considere usar uma senha mais forte';
    }

    return null;
  }

  // Validação de nome para cadastro
  static String? validateFullName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nome não pode estar vazio';
    }

    // Nome completo com pelo menos duas palavras
    final nameParts = name.trim().split(' ');

    if (nameParts.length < 2) {
      return 'Digite nome completo (nome e sobrenome)';
    }

    // Verificar se cada parte do nome tem pelo menos 2 caracteres
    if (nameParts.any((part) => part.length < 2)) {
      return 'Partes do nome muito curtas';
    }

    // Validação de caracteres com suporte a acentuação
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ ]+$');
    if (!nameRegex.hasMatch(name)) {
      return 'Nome deve conter apenas letras';
    }

    // Verificar comprimento máximo
    if (name.length > 100) {
      return 'Nome muito longo';
    }

    return null;
  }

  // Validação de valor monetário para transações
  static String? validateTransactionAmount(String? amount,
      {double minAmount = 1.0, double maxAmount = 10000.0}) {
    if (amount == null || amount.isEmpty) {
      return 'Valor não pode estar vazio';
    }

    // Converter valor, removendo vírgulas e pontos
    final parsedAmount =
        double.tryParse(amount.replaceAll('.', '').replaceAll(',', '.'));

    if (parsedAmount == null) {
      return 'Digite um valor válido';
    }

    if (parsedAmount < minAmount) {
      return 'Valor mínimo de R\$ ${minAmount.toStringAsFixed(2)}';
    }

    if (parsedAmount > maxAmount) {
      return 'Valor máximo de R\$ ${maxAmount.toStringAsFixed(2)} excedido';
    }

    // Limitar para 2 casas decimais
    if (parsedAmount.toString().split('.')[1].length > 2) {
      return 'Valor deve ter no máximo 2 casas decimais';
    }

    return null;
  }

  // Validação de confirmação de senha
  static String? validatePasswordConfirmation(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirmação de senha não pode estar vazia';
    }

    if (password != confirmPassword) {
      return 'Senhas não coincidem';
    }

    return null;
  }
}
