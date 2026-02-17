import 'package:flutter/material.dart';

class RecipeItem {
  String id;
  String name;
  String category; // "Food", "Drink", "Dessert"
  String ingredients;
  String formula;
  String cookingTime; // New: e.g., "15 min"
  String difficulty;  // New: e.g., "Easy"
  IconData icon;
  Color color;        // New: To make the UI colorful

  RecipeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.ingredients,
    required this.formula,
    required this.cookingTime,
    required this.difficulty,
    required this.icon,
    required this.color,
  });
}

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal() {
    _populateInitialData();
  }

  final List<RecipeItem> _items = [];

  List<RecipeItem> get items => _items;

  // Filter Logic
  List<RecipeItem> getByCategory(String category) {
    if (category == 'All') return _items;
    return _items.where((item) => item.category == category).toList();
  }

  void addItem(RecipeItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(String id, RecipeItem newItem) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = newItem;
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void _populateInitialData() {
    _items.addAll([
      RecipeItem(
        id: '1',
        name: 'Mojito',
        category: 'Drink',
        ingredients: 'Mint, Lime, Sugar, Rum, Soda',
        formula: 'Muddle mint -> Add liquid -> Stir.',
        cookingTime: '5 min',
        difficulty: 'Easy',
        icon: Icons.local_drink,
        color: Colors.teal,
      ),
      RecipeItem(
        id: '2',
        name: 'Burger',
        category: 'Food',
        ingredients: 'Beef, Bun, Cheese, Lettuce',
        formula: 'Grill patty -> Assemble.',
        cookingTime: '20 min',
        difficulty: 'Medium',
        icon: Icons.lunch_dining,
        color: Colors.orange,
      ),
      RecipeItem(
        id: '3',
        name: 'Pizza',
        category: 'Food',
        ingredients: 'Dough, Tomato Sauce, Cheese, Pepperoni',
        formula: 'Roll dough -> Add toppings -> Bake at 200C.',
        cookingTime: '45 min',
        difficulty: 'Hard',
        icon: Icons.local_pizza,
        color: Colors.redAccent,
      ),
      RecipeItem(
        id: '4',
        name: 'Donut',
        category: 'Dessert',
        ingredients: 'Flour, Sugar, Milk, Oil',
        formula: 'Mix batter -> Deep fry -> Glaze.',
        cookingTime: '30 min',
        difficulty: 'Medium',
        icon: Icons.donut_large,
        color: Colors.pinkAccent,
      ),
       RecipeItem(
        id: '5',
        name: 'Salad',
        category: 'Food',
        ingredients: 'Lettuce, Tomato, Cucumber, Dressing',
        formula: 'Chop veggies -> Mix with dressing.',
        cookingTime: '10 min',
        difficulty: 'Easy',
        icon: Icons.eco,
        color: Colors.green,
      ),
      RecipeItem(
        id: '6',
        name: 'Coffee',
        category: 'Drink',
        ingredients: 'Coffee beans, Water, Milk',
        formula: 'Brew coffee -> Froth milk -> Pour.',
        cookingTime: '5 min',
        difficulty: 'Easy',
        icon: Icons.coffee,
        color: Colors.brown,
      ),
    ]);
  }
}