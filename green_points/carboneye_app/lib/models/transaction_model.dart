class TransactionModel {
  final String transactionId;
  final String email;
  final double weightGrams;
  final double pointsEarned;
  final String binId;
  final String timestamp;

  TransactionModel({
    required this.transactionId,
    required this.email,
    required this.weightGrams,
    required this.pointsEarned,
    required this.binId,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] ?? '',
      email: json['email'] ?? '',
      weightGrams: (json['weight_grams'] ?? 0).toDouble(),
      pointsEarned: (json['points_earned'] ?? 0).toDouble(),
      binId: json['bin_id'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}