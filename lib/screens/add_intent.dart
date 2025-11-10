import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/intent_model.dart';
import '../data/local_storage.dart';

class AddIntentScreen extends StatefulWidget {
  final String userId;
  const AddIntentScreen({required this.userId, super.key});

  @override
  State<AddIntentScreen> createState() => _AddIntentScreenState();
}

class _AddIntentScreenState extends State<AddIntentScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _reason = TextEditingController();
  int _desire = 5;
  String _priority = 'now';

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final id = const Uuid().v4();
    final item = IntentItem(
      id: id,
      name: _name.text.trim(),
      expectedPrice: double.tryParse(_price.text.trim()) ?? 0.0,
      desireLevel: _desire,
      priority: _priority,
      reason: _reason.text.trim(),
    );
    await LocalStorage.addIntentForUser(widget.userId, item);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Intent', style: Theme.of(context).textTheme.titleLarge)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextFormField(controller: _name, validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null, decoration: const InputDecoration(labelText: 'Item name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(controller: _price, keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) => v == null || v.trim().isEmpty ? 'Enter price' : null, decoration: const InputDecoration(labelText: 'Expected price', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Text('Desire: $_desire', style: Theme.of(context).textTheme.titleSmall),
            Slider(value: _desire.toDouble(), min: 1, max: 10, divisions: 9, label: '$_desire', onChanged: (v) => setState(() => _desire = v.toInt())),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(value: _priority, items: const [DropdownMenuItem(value: 'now', child: Text('Now')), DropdownMenuItem(value: 'later', child: Text('Later')), DropdownMenuItem(value: 'someday', child: Text('Someday'))], onChanged: (v) => setState(() => _priority = v ?? 'now'), decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(controller: _reason, maxLines: 3, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Save Intent'))),
          ]),
        ),
      ),
    );
  }
}
