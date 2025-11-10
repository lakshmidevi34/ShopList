import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/local_storage.dart';
import '../data/user_model.dart';
import '../data/intent_model.dart';
import '../utils/app_colors.dart';
import '../widgets/intent_card.dart';
import 'add_intent.dart';
import 'wallet_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  const HomeScreen({
    required this.onLogout,
    required this.onToggleTheme,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? user;
  List<IntentItem> intents = [];
  double totalSpent = 0.0;
  double remaining = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  /// 🔹 Load user data + intents and calculate spent & remaining
  Future<void> _loadUser() async {
    final id = await LocalStorage.getActiveUserId();
    if (id != null) {
      user = LocalStorage.getUserById(id);
      intents = await LocalStorage.getIntentsForUser(id);

      double spent = 0;
      for (var i in intents) {
        if (i.bought) {
          spent += i.expectedPrice * i.desireLevel;
        }
      }

      final limit = user?.walletLimit ?? 0;
      final walletBalance = limit - spent;

      if (user != null) {
        user!.walletBalance = walletBalance;
        await user!.save();
      }

      setState(() {
        totalSpent = spent;
        remaining = walletBalance;
      });
    }
  }

  /// ✅ Deduct from wallet balance when bought (matches wallet screen math)
  Future<void> _markItemAsBought(IntentItem item) async {
    if (user == null) return;

    final itemCost = item.expectedPrice * item.desireLevel;
    if (user!.walletBalance >= itemCost) {
      user!.walletBalance -= itemCost;
      item.bought = true;

      await item.save();
      await user!.save();
      await LocalStorage.updateWallet(user!.id, user!.walletBalance);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Purchased '${item.name}' for ₹$itemCost"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Insufficient wallet balance!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    await _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletLimit = user?.walletLimit ?? 0;
    final walletBalance = remaining;
    final walletPercent =
    walletLimit > 0 ? (walletBalance / walletLimit).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mindful Store'),
        actions: [
          // 💰 Wallet Button
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            tooltip: "My Wallet",
            color: theme.colorScheme.primary.withOpacity(0.9),
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WalletScreen(user: user!),
                  ),
                ).then((_) => _loadUser());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please log in first!")),
                );
              }
            },
          ),

          // 📊 Analytics
          IconButton(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            tooltip: "Analytics",
            color: theme.colorScheme.primary.withOpacity(0.9),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
          ),

          // 🌗 Theme Toggle
          IconButton(
            icon: Icon(Icons.brightness_6,
                color: theme.colorScheme.primary.withOpacity(0.9)),
            tooltip: "Toggle Theme",
            onPressed: widget.onToggleTheme,
          ),

          // 🚪 Logout
          IconButton(
            icon: Icon(Icons.logout,
                color: theme.colorScheme.secondary.withOpacity(0.9)),
            tooltip: "Logout",
            onPressed: widget.onLogout,
          ),
        ],
      ),

      body: Stack(
        children: [
          // 🪄 Faint background watermark
          Positioned.fill(
            child: Center(
              child: Text(
                "ShopMind Pro",
                style: TextStyle(
                  fontSize: 95,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyMedium!.color!.withOpacity(0.05),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          RefreshIndicator(
            onRefresh: _loadUser,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 💰 Wallet Summary Card (same as WalletScreen calculation)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Wallet Overview",
                              style: theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              )),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹${walletBalance.toStringAsFixed(0)}",
                                style: theme.textTheme.titleLarge!.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.header.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                "/ ₹${walletLimit.toStringAsFixed(0)}",
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.textTheme.bodyMedium!.color!
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: walletPercent,
                            backgroundColor: Colors.white24,
                            color: AppColors.accent,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Remaining: ₹${walletBalance.toStringAsFixed(0)}",
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Spent: ₹${totalSpent.toStringAsFixed(0)}",
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  "My Intents",
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                if (intents.isEmpty)
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 80),
                    child: Text(
                      "No Intents Yet 🛍️",
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: Colors.grey),
                    ),
                  )
                else
                  ...intents.map(
                        (item) => IntentCard(
                      item: item,
                      onBought: () async => _markItemAsBought(item),
                      onDelete: () async {
                        await LocalStorage.deleteIntentForUser(
                            user!.id, item.id);
                        _loadUser();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // ➕ Floating Add Button
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4,
        hoverElevation: 8,
        backgroundColor: AppColors.accent,
        label: const Text(
          "Add Intent",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(
            builder: (_) => AddIntentScreen(userId: user!.id)))
            .then((_) => _loadUser()),
      ),
    );
  }
}
