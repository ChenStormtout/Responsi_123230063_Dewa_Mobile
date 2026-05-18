import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> getMealsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/filter.php?c=$category'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List? ?? [];
      return meals.map((m) => Meal(
        idMeal: m['idMeal'] ?? '',
        strMeal: m['strMeal'] ?? '',
        strCategory: category,
        strArea: '',
        strInstructions: '',
        strMealThumb: m['strMealThumb'] ?? '',
        strSource: '',
      )).toList();
    }
    return [];
  }

  Future<Meal?> getMealDetail(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lookup.php?i=$id'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null && meals.isNotEmpty) {
        return Meal.fromJson(meals[0]);
      }
    }
    return null;
  }
}
