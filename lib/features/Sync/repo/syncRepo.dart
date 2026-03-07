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

    // DO NOT clear all data - use upsert pattern instead
    // This prevents data loss when server returns empty arrays (no new updates)

    for (var user in pullmodels.data?.values.first.users ?? []) {
      // Mark as synced since it's from server
      user.pendingSync = true;
      await userRepo.updateUser(user);
    }

    // Upsert accounts: update if exists, insert if new, delete if marked
    final accounts = pullmodels.data?.values.first.accounts ?? [];
    log('Number of accounts from server: ${accounts.length}');

    for (var account in accounts) {
      try {
        account.pendingSync = true;

        if (account.isDeleted == true) {
          // Delete if marked as deleted
          try {
            await accountRepo.deleteFromLocal(account.id ?? '');
            log('Deleted account: ${account.name}');
          } catch (e) {
            log('Cannot delete account ${account.name}: $e');
          }
        } else {
          // Upsert: update if exists, insert if new
          final existing = accountRepo.getFromLocalById(account.id ?? '');
          if (existing != null) {
            await accountRepo.updateInLocal(account);
            log('Updated account: ${account.name}');
          } else {
            await accountRepo.saveToLocal(account);
            log('Added new account: ${account.name}');
          }
        }
      } catch (e) {
        log('Error processing account ${account.name}: $e');
      }
    }

    final savedAccounts = accountRepo.getAllFromLocal();
    log('Total accounts after sync: ${savedAccounts.length}');

    // Upsert transactions: update if exists, insert if new, delete if marked
    final transactions = pullmodels.data?.values.first.transactions ?? [];
    log('Number of transactions from server: ${transactions.length}');

    for (var transaction in transactions) {
      try {
        transaction.pendingSync = true;

        if (transaction.isDeleted == true) {
          // Delete if marked as deleted
          try {
            await transactionRepo.deleteFromLocal(transaction.id);
            log('Deleted transaction: ${transaction.id}');
          } catch (e) {
            log('Cannot delete transaction ${transaction.id}: $e');
          }
        } else {
          // Upsert: update if exists, insert if new
          final allTransactions = transactionRepo.getAllTransactions();
          final existing =
              allTransactions.where((t) => t.id == transaction.id).firstOrNull;

          if (existing != null) {
            await transactionRepo.updateInLocal(transaction);
            log('Updated transaction: ${transaction.id}');
          } else {
            await transactionRepo.saveToLocal(transaction);
            log('Added new transaction: ${transaction.id}');
          }
        }
      } catch (e) {
        log('Error processing transaction ${transaction.id}: $e');
      }
    }

    final savedTransactions = transactionRepo.getAllTransactions();
    log('Total transactions after sync: ${savedTransactions.length}');

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
        // Mark as synced since it's from server
        category.pendingSync = true;
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
              (acc) =>
                  acc.pendingSync != true &&
                  acc.uid != null &&
                  acc.uid!.isNotEmpty, // Only sync accounts with valid uid
            )
            .toList();

    log('Filtered accounts for sync: ${filteredAccounts.length}');
    final filteredTransactions =
        transactions
            .where(
              (tx) =>
                  tx.pendingSync != true &&
                  tx.uid.isNotEmpty &&
                  tx.accountId.isNotEmpty &&
                  tx
                      .categoriesId
                      .isNotEmpty, // Only sync transactions with valid uid, accountId, and categoriesId
            )
            .toList();
    log(
      'Filtered transactions for sync: ${filteredTransactions.length} of ${transactions.length}',
    );
    final filteredCategories =
        categories
            .where(
              (cat) =>
                  cat.pendingSync != true &&
                  cat.updatedAt != null &&
                  cat.uid != null &&
                  cat
                      .uid!
                      .isNotEmpty, // Only sync categories with valid uid and updatedAt
            )
            .toList();
    log(
      'Filtered categories for sync: ${filteredCategories.length} of ${categories.length}',
    );

    final result = await SyncDataService().syncData(
      currentUser,
      filteredAccounts,
      filteredTransactions,
      filteredCategories,
    );

    // After successful sync, update pendingSync to true for all synced items
    log('Updating pendingSync status for synced items...');

    // Update accounts
    for (var account in filteredAccounts) {
      account.pendingSync = true;
      await accountRepo.updateInLocal(account);
      log('Updated account ${account.name} pendingSync to true');
    }

    // Update transactions
    for (var transaction in filteredTransactions) {
      transaction.pendingSync = true;
      await transactionRepo.updateInLocal(transaction);
    }
    log(
      'Updated ${filteredTransactions.length} transactions pendingSync to true',
    );

    // Update categories
    for (var category in filteredCategories) {
      category.pendingSync = true;
      final index = await categoryRepo.getIndexOfCategory(category);
      if (index != -1) {
        await categoryRepo.updateCategory(index, category);
      }
    }
    log('Updated ${filteredCategories.length} categories pendingSync to true');

    // Update user if it was synced
    if (currentUser != null &&
        (currentUser.pendingSync == false || currentUser.pendingSync == null)) {
      currentUser.pendingSync = true;
      await userRepo.updateUser(currentUser);
      log('Updated user pendingSync to true');
    }

    log('Sync completed successfully');
    return result;
  }
}
