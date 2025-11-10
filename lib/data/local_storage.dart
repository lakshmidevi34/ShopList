import 'package:hive/hive.dart';
import 'intent_model.dart';
import 'user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // box names
  static const String usersBox = 'users_box';
  static const String prefsActiveUser = 'active_user_id';

  // register adapters (call at app init)
  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(IntentItemAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserModelAdapter());
  }

  // open core boxes
  static Future<void> initBoxes() async {
    await Hive.openBox<UserModel>(usersBox);
    // do not open intents boxes here; open per user on demand
  }

  // ----- User methods -----
  static Box<UserModel> getUsersBox() => Hive.box<UserModel>(usersBox);

  static Future<void> addUser(UserModel user) async {
    await getUsersBox().put(user.id, user);
  }

  static Future<void> deleteUser(String userId) async {
    await getUsersBox().delete(userId);
    // Optionally delete user's intents box (uncomment to delete data)
    // await Hive.deleteBoxFromDisk('intents_$userId');
  }

  static List<UserModel> getAllUsers() => getUsersBox().values.cast<UserModel>().toList();

  static UserModel? getUserById(String id) => getUsersBox().get(id);

  // ----- Active user in SharedPreferences -----
  static Future<void> setActiveUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(prefsActiveUser);
    } else {
      await prefs.setString(prefsActiveUser, userId);
    }
  }

  static Future<String?> getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsActiveUser);
  }

  // ----- Per-user intent box helpers -----
  static String intentBoxName(String userId) => 'intents_$userId';

  static Future<Box<IntentItem>> openIntentBoxFor(String userId) async {
    final name = intentBoxName(userId);
    if (Hive.isBoxOpen(name)) {
      return Hive.box<IntentItem>(name);
    } else {
      return await Hive.openBox<IntentItem>(name);
    }
  }

  static Future<void> addIntentForUser(String userId, IntentItem item) async {
    final box = await openIntentBoxFor(userId);
    await box.put(item.id, item);
  }

  static Future<void> deleteIntentForUser(String userId, String intentId) async {
    final box = await openIntentBoxFor(userId);
    await box.delete(intentId);
  }

  static Future<List<IntentItem>> getIntentsForUser(String userId) async {
    final box = await openIntentBoxFor(userId);
    return box.values.cast<IntentItem>().toList();
  }

  // ----- Wallet updates per user -----
  static Future<void> updateWallet(String userId, double newBalance) async {
    final user = getUserById(userId);
    if (user != null) {
      user.walletBalance = newBalance;
      await user.save();
    }
  }
}
