import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';

class MealListPage extends StatefulWidget {
  const MealListPage({super.key});

  @override
  State<MealListPage> createState() => _MealListPageState();
}

class _MealListPageState extends State<MealListPage> {
  final ApiService _apiService = ApiService();
  final FavoriteService _favoriteService = FavoriteService();
  String _selectedCategory = 'Beef';
  final List<String> _categories = ['Beef', 'Chicken', 'Pork'];
  List<Meal> _meals = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _loading = true);
    final meals = await _apiService.getMealsByCategory(_selectedCategory);
    setState(() {
      _meals = meals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: _categories.map((cat) {
              final selected = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat);
                    _loadMeals();
                  },
                  selectedColor: const Color(0xFFE65100),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)))
              : ListView.builder(
                  itemCount: _meals.length,
                  itemBuilder: (context, index) {
                    final meal = _meals[index];
                    return _MealCard(
                      meal: meal,
                      favoriteService: _favoriteService,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MealCard extends StatefulWidget {
  final Meal meal;
  final FavoriteService favoriteService;

  const _MealCard({required this.meal, required this.favoriteService});

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  Future<void> _checkFav() async {
    final fav = await widget.favoriteService.isFavorite(widget.meal.idMeal);
    if (mounted) setState(() => _isFav = fav);
  }

  Future<void> _toggleFav() async {
    if (_isFav) {
      await widget.favoriteService.removeFavorite(widget.meal.idMeal);
    } else {
      // Need full meal for favorites; fetch detail
      final ApiService api = ApiService();
      final detail = await api.getMealDetail(widget.meal.idMeal);
      if (detail != null) {
        await widget.favoriteService.addFavorite(detail);
      } else {
        await widget.favoriteService.addFavorite(widget.meal);
      }
    }
    if (mounted) setState(() => _isFav = !_isFav);
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(mealId: meal.idMeal)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  meal.strMealThumb,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.strMeal,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.strArea.isNotEmpty ? meal.strArea : meal.strCategory,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFav ? Icons.favorite : Icons.favorite_border,
                  color: _isFav ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleFav,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
