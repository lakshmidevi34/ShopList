import '../data/intent_model.dart';

class InsightRules {
  static String quickSummary(List<IntentItem> items) {
    if (items.isEmpty) return 'No intents yet — add your first intention.';
    final nowCount = items.where((i) => i.priority == 'now').length;
    final wants = items.where((i) => i.desireLevel >= 7).length;
    final bought = items.where((i) => i.bought).length;
    return 'You have ${items.length} intents • $nowCount Now • $wants high-desire • $bought bought';
  }

  static String personaTag(List<IntentItem> items) {
    if (items.isEmpty) return 'Newcomer';
    final avg = items.fold<int>(0, (p, e) => p + e.desireLevel) / items.length;
    if (avg >= 8) return 'The Explorer 🔥';
    if (avg <= 4) return 'The Saver 🧊';
    return 'The Balanced 🌱';
  }
}
