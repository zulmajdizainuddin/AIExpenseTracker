class BudgetSummary {
  const BudgetSummary({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.budgetAmount,
    required this.spent,
    required this.remaining,
    required this.percent,
  });

  final int id;
  final int categoryId;
  final String categoryName;
  final String categoryColor;
  final double budgetAmount;
  final double spent;
  final double remaining;
  final double percent;

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    final budget   = json['budget'] as Map<String, dynamic>;
    final category = budget['category'] as Map<String, dynamic>? ?? {};
    return BudgetSummary(
      id:            budget['id'] as int,
      categoryId:    budget['category_id'] as int,
      categoryName:  category['name'] as String? ?? 'Unknown',
      categoryColor: category['color'] as String? ?? '#6366f1',
      budgetAmount:  double.parse(budget['amount'].toString()),
      spent:         double.parse(json['spent'].toString()),
      remaining:     double.parse(json['remaining'].toString()),
      percent:       double.parse(json['percent'].toString()),
    );
  }
}
