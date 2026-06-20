class ReceiptModel {
  const ReceiptModel({
    required this.id,
    this.merchantName,
    this.amount,
    this.receiptDate,
    this.categorySuggestion,
    required this.processingStatus,
  });

  final int id;
  final String? merchantName;
  final double? amount;
  final DateTime? receiptDate;
  final String? categorySuggestion;
  final String processingStatus;

  factory ReceiptModel.fromJson(Map<String, dynamic> json) => ReceiptModel(
        id:                 json['id'] as int,
        merchantName:       json['merchant_name'] as String?,
        amount:             json['amount'] != null ? double.parse(json['amount'].toString()) : null,
        receiptDate:        json['receipt_date'] != null ? DateTime.parse(json['receipt_date']) : null,
        categorySuggestion: json['category_suggestion'] as String?,
        processingStatus:   json['processing_status'] as String,
      );
}

class AiReceiptData {
  const AiReceiptData({
    this.merchantName,
    this.amount,
    this.date,
    this.categorySuggestion,
  });

  final String? merchantName;
  final double? amount;
  final String? date;
  final String? categorySuggestion;

  factory AiReceiptData.fromJson(Map<String, dynamic> json) => AiReceiptData(
        merchantName:       json['merchant_name'] as String?,
        amount:             json['amount'] != null ? double.parse(json['amount'].toString()) : null,
        date:               json['date'] as String?,
        categorySuggestion: json['category_suggestion'] as String?,
      );
}
