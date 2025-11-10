import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/local_storage.dart';
import '../data/user_model.dart';
import '../widgets/expense_pie_chart.dart';
import '../utils/app_colors.dart';

class WalletScreen extends StatefulWidget {
  final UserModel user;
  const WalletScreen({super.key, required this.user});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late TextEditingController walletController;
  double totalSpent = 0.0;
  Map<String, double> categorySpends = {};

  @override
  void initState() {
    super.initState();
    walletController =
        TextEditingController(text: widget.user.walletLimit.toString());
    _loadSpendingData();
  }

  /// ✅ Multiplies expectedPrice × desireLevel and reloads latest data
  Future<void> _loadSpendingData() async {
    final intents = await LocalStorage.getIntentsForUser(widget.user.id);
    double spent = 0.0;
    final Map<String, double> categoryTotals = {};

    for (var i in intents) {
      if (i.bought) {
        final double totalItemCost = i.expectedPrice * i.desireLevel;
        spent += totalItemCost;
        categoryTotals[i.priority] =
            (categoryTotals[i.priority] ?? 0) + totalItemCost;
      }
    }

    setState(() {
      totalSpent = spent;
      categorySpends = categoryTotals;
    });
  }

  Future<void> _saveWalletLimit() async {
    final newLimit = double.tryParse(walletController.text) ?? 0.0;
    final userBox = Hive.box<UserModel>(LocalStorage.usersBox);
    widget.user.walletLimit = newLimit;
    await userBox.put(widget.user.id, widget.user);
    await widget.user.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Wallet limit updated successfully 💰"),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadSpendingData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final remaining = widget.user.walletLimit - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wallet & Analytics"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSpendingData,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0F111C), const Color(0xFF1C1E2A)]
                  : [AppColors.backgroundTop, AppColors.backgroundBottom],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 💰 Wallet Limit Card
              _walletLimitCard(isDark),

              const SizedBox(height: 20),

              // 📊 Summary Card
              _summaryCard(isDark, remaining),

              const SizedBox(height: 25),

              // 🧠 Expense Pie Chart
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard.withOpacity(0.9)
                      : AppColors.card.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ExpensePieChart(expenses: categorySpends),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletLimitCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withOpacity(0.9)
                : AppColors.card.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Wallet Limit",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.header,
                  )),
              const SizedBox(height: 8),
              TextField(
                controller: walletController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Enter wallet limit",
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Save Limit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _saveWalletLimit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(bool isDark, double remaining) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withOpacity(0.9)
            : AppColors.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Wallet Summary",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.header)),
          const SizedBox(height: 10),
          _summaryRow("Total Limit",
              "₹${widget.user.walletLimit.toStringAsFixed(0)}", isDark),
          _summaryRow("Total Spent", "₹${totalSpent.toStringAsFixed(0)}", isDark),
          _summaryRow(
              "Remaining", "₹${remaining.toStringAsFixed(0)}", isDark,
              highlight: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDark,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              )),
          Text(value,
              style: TextStyle(
                color: highlight
                    ? AppColors.accent
                    : (isDark ? Colors.white : AppColors.header),
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
