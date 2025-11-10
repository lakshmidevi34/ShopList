import 'package:flutter/material.dart';
import '../data/intent_model.dart';

class IntentCard extends StatelessWidget {
  final IntentItem item;
  final VoidCallback? onBought;
  final VoidCallback? onDelay;
  final VoidCallback? onDelete;

  const IntentCard({
    super.key,
    required this.item,
    this.onBought,
    this.onDelay,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.shopping_bag_outlined)),
        title: Text(item.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text('₹${item.expectedPrice.toStringAsFixed(0)} • ${item.priority}', style: Theme.of(context).textTheme.bodySmall),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'bought') {
              onBought?.call();
            } else if (v == 'delay') {
              onDelay?.call();
            } else if (v == 'delete') {
              onDelete?.call();
            }
          },
          itemBuilder: (_) => [
            if (!item.bought) const PopupMenuItem(value: 'bought', child: Text('Mark as bought')),
            const PopupMenuItem(value: 'delay', child: Text('Delay')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

