import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- MODELS ---
class UserModel {
  String id;
  String name;
  String email;
  String password;
  String role;

  UserModel({
    required this.id, required this.name, required this.email, 
    required this.password, this.role = 'user',
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'password': password, 'role': role};
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'], name: json['name'], email: json['email'], password: json['password'], role: json['role'],
  );
}

class RecipeItem {
  String id;
  String name;
  String category;
  String ingredients;
  String formula;
  String cookingTime;
  String difficulty;
  IconData icon;
  Color color;
  bool isFavorite;

  RecipeItem({
    required this.id, required this.name, required this.category, 
    required this.ingredients, required this.formula, required this.cookingTime, 
    required this.difficulty, required this.icon, required this.color,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'category': category, 'ingredients': ingredients, 'formula': formula,
    'cookingTime': cookingTime, 'difficulty': difficulty,
    'iconCode': icon.codePoint, 'colorValue': color.value,
    'isFavorite': isFavorite,
  };

  factory RecipeItem.fromJson(Map<String, dynamic> json) => RecipeItem(
    id: json['id'], name: json['name'], category: json['category'], 
    ingredients: json['ingredients'], formula: json['formula'],
    cookingTime: json['cookingTime'], difficulty: json['difficulty'],
    icon: IconData(json['iconCode'], fontFamily: 'MaterialIcons'),
    color: Color(json['colorValue']),
    isFavorite: json['isFavorite'] ?? false,
  );
}

// --- SERVICE ---
class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final List<UserModel> _users = [];
  UserModel? _currentUser;
  final List<RecipeItem> _items = [];
  
  UserModel? get currentUser => _currentUser;
  List<RecipeItem> get items => _items;
  List<RecipeItem> get favorites => _items.where((i) => i.isFavorite).toList();

  // Load data from Storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? usersString = prefs.getString('users');
    if (usersString != null) {
      final List<dynamic> jsonList = jsonDecode(usersString);
      _users.clear();
      _users.addAll(jsonList.map((e) => UserModel.fromJson(e)).toList());
    } else {
      _createDefaultUsers();
    }

    final String? itemsString = prefs.getString('items');
    if (itemsString != null) {
      final List<dynamic> jsonList = jsonDecode(itemsString);
      _items.clear();
      _items.addAll(jsonList.map((e) => RecipeItem.fromJson(e)).toList());
    } else {
      _createDefaultRecipes();
    }
    notifyListeners();
  }

  // --- THE FIXED METHOD ---
  List<RecipeItem> getByCategory(String category) {
    if (category == 'All') return _items;
    return _items.where((item) => item.category == category).toList();
  }

  void toggleFavorite(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isFavorite = !_items[index].isFavorite;
      _saveItemsToDisk();
      notifyListeners();
    }
  }

  bool login(String email, String password) {
    try {
      final user = _users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool register(String name, String email, String password) {
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) return false;
    _users.add(UserModel(id: DateTime.now().toString(), name: name, email: email, password: password, role: 'user'));
    _saveUsersToDisk();
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Admin CRUD Actions
  void addItem(RecipeItem item) { _items.add(item); _saveItemsToDisk(); notifyListeners(); }
  void updateItem(String id, RecipeItem newItem) { 
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) { _items[index] = newItem; _saveItemsToDisk(); notifyListeners(); }
  }
  void deleteItem(String id) { _items.removeWhere((item) => item.id == id); _saveItemsToDisk(); notifyListeners(); }

  Future<void> _saveUsersToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', jsonEncode(_users.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveItemsToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('items', jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _items.clear();
    _users.clear();
    _createDefaultUsers();
    _createDefaultRecipes();
    notifyListeners();
  }

  void _createDefaultUsers() {
    _users.add(UserModel(id: 'admin1', name: 'Super Admin', email: 'admin@mhub.com', password: '123', role: 'admin'));
    _users.add(UserModel(id: 'user1', name: 'Sim Leng', email: 'leng@mhub.com', password: '123', role: 'user'));
    _saveUsersToDisk();
  }

  void _createDefaultRecipes() {
    _items.add(RecipeItem(id: '1', name: 'Mojito', category: 'Drink', ingredients: 'Mint, Lime, Sugar, Rum', formula: 'Mix all', cookingTime: '5 min', difficulty: 'Easy', icon: Icons.local_drink, color: Colors.teal));
    _items.add(RecipeItem(id: '2', name: 'Burger', category: 'Food', ingredients: 'Beef, Bun, Cheese', formula: 'Grill it', cookingTime: '20 min', difficulty: 'Medium', icon: Icons.lunch_dining, color: Colors.orange));
    _items.add(RecipeItem(id: '3', name: 'Chocolate Cake', category: 'Dessert', ingredients: 'Flour, Cocoa, Sugar', formula: 'Bake it', cookingTime: '45 min', difficulty: 'Hard', icon: Icons.cake, color: Colors.brown));
    _items.add(RecipeItem(id: '4', name: 'Matcha Latte', category: 'Drink', ingredients: 'Matcha, Milk, Sugar', formula: 'Mix and heat', cookingTime: '10 min', difficulty: 'Easy', icon: Icons.local_cafe, color: Colors.green));
    _saveItemsToDisk();
  }
}
