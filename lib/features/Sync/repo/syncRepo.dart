// ignore_for_file: file_names
import 'dart:developer';

import 'package:financy_ui/app/services/Server/sync_data.dart';
import 'package:financy_ui/features/Account/repo/manageMoneyRepo.dart';
import 'package:financy_ui/features/Categories/repo/categorieRepo.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/core/constants/icons.dart'
    show defaultExpenseCategories, defaultIncomeCategories;
import 'package:financy_ui/features/Sync/models/pullModels.dart';
import 'package:financy_ui/features/Users/Repo/userRepo.dart';
import 'package:financy_ui/features/transactions/repo/transactionsRepo.dart';

class SyncRepo {
  final userRepo = UserRepo();
  final accountRepo = ManageMoneyRepo();
  final transactionRepo = TransactionsRepo();
  final categoryRepo = Categorierepo();

  Future<void> updateData(Pullmodels pullmodels) async {
    log('Updating data with pullmodels:');

    // Ensure clearing completes before saving new data to avoid race conditions
    log('Clearing local transactions and accounts...');
    await transactionRepo.clearAllTransactions();
    await accountRepo.clearLocalData();
    log('Cleared local transactions and accounts.');
    //categoryRepo.clearAllCategories();

    for (var user in pullmodels.data?.values.first.users ?? []) {
      await userRepo.updateUser(user);
    }

    final accounts = pullmodels.data?.values.first.accounts ?? [];
    log('Number of accounts to save: ${accounts.length}');

    for (var account in accounts) {
      log('Saving account: ${account.name} with id: ${account.id}');
      try {
        await accountRepo.saveToLocal(account);
        log('Successfully saved account: ${account.name}');
      } catch (e) {
        log('Error saving account ${account.name}: $e');
      }
    }

    // Verify accounts were saved
    final savedAccounts = accountRepo.getAllFromLocal();
    log('Total accounts after saving: ${savedAccounts.length}');

    for (var transaction in pullmodels.data?.values.first.transactions ?? []) {
      await transactionRepo.saveToLocal(transaction);
    }

    // Merge categories: keep existing defaults, upsert server categories, skip deleted
    final pulledCategories = pullmodels.data?.values.first.categories ?? [];
    final existingCategories = await categoryRepo.getCategories();
    log('Existing categories: ${existingCategories.length}');
    log('Categories from server: ${pulledCategories.length}');

    for (var category in pulledCategories) {
      // Skip categories flagged as deleted from server to avoid wiping local defaults
      if (category.isDeleted == true) {
        log('Skipping deleted category from server: ${category.name}');
        continue;
      }
      try {
        final idx = await categoryRepo.getIndexOfCategory(category);
        if (idx != -1) {
          await categoryRepo.updateCategory(idx, category);
          log('Updated category: ${category.name}');
        } else {
          await categoryRepo.addCategory(category);
          log('Added new category: ${category.name}');
        }
      } catch (e) {
        log('Error merging category ${category.name}: $e');
      }
    }
    final categoriesAfter = await categoryRepo.getCategories();
    log('Total categories after merge: ${categoriesAfter.length}');

    // Ensure default categories still exist. Criteria for presence:
    // - match by id OR by (type + icon) if ids were regenerated
    try {
      final existingById = {for (var c in categoriesAfter) c.id};
      final existingSignature = <String>{
        for (var c in categoriesAfter) '${c.type}|${c.icon}'.toLowerCase(),
      };

      Future<void> ensureDefaults(List<Category> defaults) async {
        for (final def in defaults) {
          final sig = '${def.type}|${def.icon}'.toLowerCase();
          if (existingById.contains(def.id) ||
              existingSignature.contains(sig)) {
            continue; // already present
          }
          // Clone default to avoid mutating global list
          final clone = Category(
            id: def.id,
            name: def.name,
            type: def.type,
            icon: def.icon,
            color: def.color,
            createdAt: def.createdAt,
            userId: null,
            pendingSync: false,
          );
          try {
            await categoryRepo.addCategory(clone);
            log('Restored missing default category: ${clone.name}');
          } catch (e) {
            log('Failed to restore default category ${clone.name}: $e');
          }
        }
      }

      await ensureDefaults(defaultExpenseCategories);
      await ensureDefaults(defaultIncomeCategories);
    } catch (e) {
      log('Error ensuring default categories: $e');
    }
  }

  Future syncData() async {
    // get all local data
    final currentUser = await userRepo.getUser();
    final accounts = accountRepo.getAllFromLocal();
    final transactions = transactionRepo.getAllTransactions();
    final categories = await categoryRepo.getCategories();

    log('Total accounts from local: ${accounts.length}');
    for (var acc in accounts) {
      log('Account: ${acc.name}, pendingSync: ${acc.pendingSync}');
    }

    final filteredAccounts =
        accounts
            .where(
              (acc) => acc.pendingSync != true,
            ) // Include accounts that are not pending sync
            .toList();

    log('Filtered accounts for sync: ${filteredAccounts.length}');
    final filteredTransactions =
        transactions
            .where(
              (tx) => tx.pendingSync != true,
            ) // Include transactions that are not pending sync
            .toList();
    final filteredCategories =
        categories
            .where(
              (cat) =>
                  cat.pendingSync != true &&
                  cat.updatedAt !=
                      null, // Include categories that are not pending sync and have updatedAt
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
