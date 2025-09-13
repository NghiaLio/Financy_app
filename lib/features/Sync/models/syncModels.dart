import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';

class Syncmodels {
  List<UserModel> users;
  List<MoneySource> accounts;
  List<Transactionsmodels> transactions;
  List<Category> categories;

  Syncmodels({
    required this.users,
    required this.accounts,
    required this.transactions,
    required this.categories,
  });

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
      'accounts': accounts.map((account) => account.toJson()).toList(),
      'transactions':
          transactions.map((transaction) => transaction.toJson()).toList(),
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }
}
