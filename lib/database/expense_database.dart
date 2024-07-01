import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import 'package:expensestracker/model/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpense = [];

// setup
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

// getters
  List<Expense> get allExpense => _allExpense;

// operations
  // create - add new expense
  Future<void> createNewExpense(Expense newExpense) async {
    // add to db
    await isar.writeTxn(
      () => isar.expenses.put(newExpense),
    );

    // re-read from db
    readExpenses();
  }

  // read - read expense from db
  Future<void> readExpenses() async {
    // fetch all existing expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // give to local expense list
    _allExpense.clear();
    _allExpense.addAll(fetchedExpenses);

    // update ui
    notifyListeners();
  }

  // update - edit expense in db
  Future<void> updateExpense(int id, Expense updatedExpense) async {

    // same id
    updatedExpense.id = id;

    // update in db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense),);

    // re-read from db
    await readExpenses();
  }

  // delete - delete an expense from db
  Future<void> deleteExpense(int id)async{
    await isar.writeTxn(() => isar.expenses.delete(id),);
    await readExpenses();
  }
}
