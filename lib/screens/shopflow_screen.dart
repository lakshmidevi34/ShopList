import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_storage.dart';
import '../data/intent_model.dart';
import '../data/user_model.dart';

class ShopFlowScreen extends StatefulWidget {
  const ShopFlowScreen({super.key});
  @override
  State<ShopFlowScreen> createState() => _ShopFlowScreenState();
}

class _ShopFlowScreenState extends State<ShopFlowScreen> {
  double wallet = 0.0;
  String? userId;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadWalletAndUser();
  }

  Future<void> _loadWalletAndUser() async {
    userId = await LocalStorage.getActiveUserId();
    if (userId != null) {
      user = LocalStorage.getUserById(userId!);
      wallet = user?.walletBalance ?? 0.0;
      setState(() {});
    }
  }

  Future<void> _saveWallet() async {
    if (userId != null) {
      await LocalStorage.updateWallet(userId!, wallet);
      user = LocalStorage.getUserById(userId!);
      setState(() {});
    }
  }

  Future<void> _buy(IntentItem item) async {
    if (wallet < item.expectedPrice) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough wallet balance')));
      return;
    }
    setState(() => wallet -= item.expectedPrice);
    await _saveWallet();
    item.bought = true;
    await item.save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShopFlow Simulation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Wallet: ₹${wallet.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<IntentItem>>(
              future: userId == null ? Future.value([]) : LocalStorage.getIntentsForUser(userId!),
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (items.isEmpty) return const Center(child: Text('No pending intents'));
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(it.name, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text('₹${it.expectedPrice.toStringAsFixed(0)} — Desire ${it.desireLevel}'),
                        trailing: ElevatedButton.icon(onPressed: () => _buy(it), icon: const Icon(Icons.shopping_cart_checkout), label: const Text('Buy')),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
