class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final String type;
  final String counterparty;
  final String status;

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    required this.counterparty,
    required this.status,
  });
}
