import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/user_model.dart';
import '../data/local_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  final _confirmPin = TextEditingController();
  final _secure = const FlutterSecureStorage();

  Future<void> _save() async {
    if (_name.text.isEmpty || _phone.text.isEmpty || _pin.text.isEmpty) return;
    if (_pin.text != _confirmPin.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('PINs do not match')));
      return;
    }

    final id = const Uuid().v4();
    final user = UserModel(
        id: id, name: _name.text, phone: _phone.text, walletBalance: 10000);
    await LocalStorage.addUser(user);
    await _secure.write(key: 'pin_$id', value: _pin.text);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(controller: _pin, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PIN')),
            const SizedBox(height: 12),
            TextField(controller: _confirmPin, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Confirm PIN')),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Save User'))
          ],
        ),
      ),
    );
  }
}
