import '../repositories/pin_repository.dart';

/// Caso de uso para definir ou atualizar o PIN de transações.
///
/// O PIN deve conter de 4 a 6 dígitos numéricos.
class SetPinUseCase {
  final PinRepository _repository;

  SetPinUseCase(this._repository);

  Future<void> execute(String pin) async {
    if (!_isValid(pin)) {
      throw Exception('O PIN deve conter de 4 a 6 dígitos numéricos');
    }

    await _repository.savePin(pin);
  }

  bool _isValid(String pin) {
    final regex = RegExp(r'^\d{4,6}$');
    return regex.hasMatch(pin);
  }
}
