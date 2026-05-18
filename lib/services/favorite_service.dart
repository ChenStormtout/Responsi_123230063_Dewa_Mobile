import 'package:hive/hive.dart';
import '../models/meal.dart';

class FavoriteService {
  static const String _boxName = 'favorites';

  Future<Box<Meal>> _getBox() async {
    return await Hive.openBox<Meal>(_boxName);
  }

  Future<void> addFavorite(Meal meal) async {
    final box = await _getBox();
    await box.put(meal.idMeal, meal);
  }

  Future<void> removeFavorite(String idMeal) async {
    final box = await _getBox();
    await box.delete(idMeal);
  }

  Future<bool> isFavorite(String idMeal) async {
    final box = await _getBox();
    return box.containsKey(idMeal);
  }

  Future<List<Meal>> getFavorites() async {
    final box = await _getBox();
    return box.values.toList();
  }
}
