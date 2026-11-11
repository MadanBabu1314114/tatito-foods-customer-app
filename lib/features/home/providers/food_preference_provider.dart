import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/widgets/veg_toggle.dart';

class FoodPreferenceProvider extends ChangeNotifier {
  static const String _storageKey = 'tatito_food_preference';
  FoodPreference _preference = FoodPreference.all;

  FoodPreference get preference => _preference;

  FoodPreferenceProvider() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        if (saved == 'veg') {
          _preference = FoodPreference.veg;
        } else if (saved == 'non_veg') {
          _preference = FoodPreference.nonVeg;
        } else {
          _preference = FoodPreference.all;
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setPreference(FoodPreference newPref) async {
    if (_preference == newPref) return;
    _preference = newPref;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'all';
      if (newPref == FoodPreference.veg) val = 'veg';
      if (newPref == FoodPreference.nonVeg) val = 'non_veg';
      await prefs.setString(_storageKey, val);
    } catch (_) {}
  }
}
