/// Funções de validação reutilizáveis para formulários e inputs.
class Validators {
  /// Valida campo obrigatório.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  /// Valida formato de e-mail.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(value.trim()) ? null : 'E-mail inválido';
  }

  /// Valida tamanho mínimo.
  static String? minLength(String? value, int length) {
    if (value == null || value.length < length) {
      return 'Mínimo de $length caracteres';
    }
    return null;
  }

  /// Valida PIN numérico de 4 a 6 dígitos.
  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'Informe o PIN';
    final regex = RegExp(r'^\d{4,6}$');
    return regex.hasMatch(value) ? null : 'PIN inválido (4 a 6 dígitos)';
  }

  /// Valida CPF simples (só formato).
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) return 'Informe o CPF';
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    return cleaned.length == 11 ? null : 'CPF inválido';
  }
}
