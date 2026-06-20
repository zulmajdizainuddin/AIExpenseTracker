class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final int id;
  final String name;
  final String icon;
  final String color;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id:    json['id'] as int,
        name:  json['name'] as String,
        icon:  json['icon'] as String? ?? 'category',
        color: json['color'] as String? ?? '#6366f1',
      );
}

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.transactionDate,
    this.note,
    this.category,
    this.categoryId,
  });

  final int id;
  final String title;
  final double amount;
  final DateTime transactionDate;
  final String? note;
  final CategoryModel? category;
  final int? categoryId;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id:              json['id'] as int,
        title:           json['title'] as String,
        amount:          double.parse(json['amount'].toString()),
        transactionDate: DateTime.parse(json['transaction_date'] as String),
        note:            json['note'] as String?,
        category:        json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
        categoryId:      json['category_id'] as int?,
      );
}
