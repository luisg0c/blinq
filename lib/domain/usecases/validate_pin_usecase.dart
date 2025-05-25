import '../repositories/pin_repository.dart';

/// Caso de uso para verificar se o PIN digitado é válido.
class ValidatePinUseCase {
  final PinRepository _repository;

  ValidatePinUseCase(this._repository);

  Future<bool> execute(String pin) {
    return _repository.validatePin(pin);
  }
}
