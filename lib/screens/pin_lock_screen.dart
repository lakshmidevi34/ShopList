import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinLockScreen extends StatefulWidget {
  final String userId;
  final void Function(bool success) onUnlock;

  const PinLockScreen({required this.userId, required this.onUnlock, super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _secureStorage = const FlutterSecureStorage();
  final _pinController = TextEditingController();
  int _attempts = 0;
  bool _locked = false;
  DateTime? _lockUntil;

  Future<void> _verify() async {
    if (_locked) return;
    final stored = await _secureStorage.read(key: 'pin_${widget.userId}');
    if (stored == _pinController.text) {
      widget.onUnlock(true);
      return;
    } else {
      _attempts++;
      if (_attempts >= 3) {
        // lock for 60 seconds
        _locked = true;
        _lockUntil = DateTime.now().add(const Duration(seconds: 60));
        setState(() {});
        Future.delayed(const Duration(seconds: 60), () {
          _attempts = 0;
          _locked = false;
          _lockUntil = null;
          if (mounted) setState(() {});
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong PIN')));
      widget.onUnlock(false);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockedText = _locked ? 'Locked until ${_lockUntil?.toLocal().toIso8601String().substring(11,19)}' : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (lockedText != null) ...[
            Text(lockedText, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
          ],
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: const InputDecoration(labelText: '4-digit PIN', border: OutlineInputBorder()),
            enabled: !_locked,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _locked ? null : _verify, child: const Text('Unlock')),
        ]),
      ),
    );
  }
}
