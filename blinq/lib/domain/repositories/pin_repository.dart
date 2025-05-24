/// Repositório responsável pelo PIN de transações.
/// O PIN é usado para autorizar operações sensíveis como transferências.
abstract class PinRepository {
  /// Salva ou atualiza o PIN localmente (de forma segura).
  Future<void> savePin(String pin);

  /// Verifica se o PIN informado corresponde ao salvo.
  Future<bool> validatePin(String pin);

  /// Retorna se já existe um PIN configurado no dispositivo.
  Future<bool> hasPin();
}