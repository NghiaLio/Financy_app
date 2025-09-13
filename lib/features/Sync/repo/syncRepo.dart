import 'package:financy_ui/app/services/Server/sync_data.dart';
import 'package:financy_ui/features/Account/repo/manageMoneyRepo.dart';
import 'package:financy_ui/features/Categories/repo/categorieRepo.dart';
import 'package:financy_ui/features/Sync/models/pullModels.dart';
import 'package:financy_ui/features/Users/Repo/userRepo.dart';
import 'package:financy_ui/features/transactions/repo/transactionsRepo.dart';

class SyncRepo {
  final userRepo = UserRepo();
  final accountRepo = ManageMoneyRepo();
  final transactionRepo = TransactionsRepo();
  final categoryRepo = Categorierepo();

  Future<void> updateData(Pullmodels pullmodels) async {
    transactionRepo.clearAllTransactions();
    accountRepo.clearLocalData();
    categoryRepo.clearAllCategories();

    for (var user in pullmodels.data?.values.first.users ?? []) {
      await userRepo.updateUser(user);
    }

    for (var account in pullmodels.data?.values.first.accounts ?? []) {
      await accountRepo.saveToLocal(account);
    }

    for (var transaction in pullmodels.data?.values.first.transactions ?? []) {
      await transactionRepo.saveToLocal(transaction);
    }

    for (var category in pullmodels.data?.values.first.categories ?? []) {
      await categoryRepo.addCategory(category);
    }
  }

  Future syncData() async {
    // get all local data
    final currentUser = await userRepo.getUser();
    final accounts = accountRepo.getAllFromLocal();
    final transactions = transactionRepo.getAllTransactions();
    final categories = await categoryRepo.getCategories();

    final filteredAccounts =
        accounts
            .where((acc) => acc.pendingSync == false || acc.pendingSync == null)
            .toList();
    final filteredTransactions =
        transactions
            .where((tx) => tx.pendingSync == false || tx.pendingSync == null)
            .toList();
    final filteredCategories =
        categories
            .where(
              (cat) =>
                  cat.pendingSync == false ||
                  cat.pendingSync == null && cat.updatedAt != null,
            )
            .toList();

    final result = await SyncDataService().syncData(
      currentUser,
      filteredAccounts,
      filteredTransactions,
      filteredCategories,
    );
    return result;
  }
}
