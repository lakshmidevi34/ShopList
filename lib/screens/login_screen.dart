import 'package:flutter/material.dart';
import '../data/local_storage.dart';
import '../data/user_model.dart';
import 'register_user.dart';
import 'pin_lock_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  const LoginScreen({required this.onLoggedIn, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _users = LocalStorage.getAllUsers();
    setState(() {});
  }

  Future<void> _createUser() async {
    final res = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RegisterUserScreen()));
    if (res == true) _loadUsers();
  }

  Future<void> _selectUser(UserModel user) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PinLockScreen(
            userId: user.id,
            onUnlock: (success) async {
              if (success) {
                await LocalStorage.setActiveUserId(user.id);
                widget.onLoggedIn();
              }
              Navigator.of(context).pop();
            })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('SHOPMIND Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_users.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text(
                          'No users yet — create one to get started!',
                          style: TextStyle(color: Colors.white70))))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (_, i) {
                    final u = _users[i];
                    return Card(
                      color: Colors.white12,
                      child: ListTile(
                        title: Text(u.name,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Phone: ${u.phone}',
                            style:
                            const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                            icon: const Icon(Icons.login, color: Colors.white),
                            onPressed: () => _selectUser(u)),
                      ),
                    );
                  },
                ),
              ),
            FilledButton.icon(
                onPressed: _createUser,
                icon: const Icon(Icons.person_add),
                label: const Text('Create New User')),
          ],
        ),
      ),
    );
  }
}
