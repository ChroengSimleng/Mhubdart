import 'package:flutter/material.dart';
import 'auth_flow.dart';
import 'data_service.dart';
import 'admin_flow.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DashboardTab(),
    const NotificationTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 
          ? null 
          : AppBar(
              title: const Text("Mhub"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    DataService().logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()));
                  },
                )
              ],
            ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// ---------------- DASHBOARD TAB ----------------
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DataService(),
      builder: (context, child) {
        final items = DataService().getByCategory(selectedCategory);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Discover Recipes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                background: Container(color: Theme.of(context).primaryColor),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Row(
                  children: ['All', 'Food', 'Drink', 'Dessert'].map((cat) {
                    bool isSel = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        onSelected: (v) => setState(() => selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => RecipeDetailScreen(item: item))),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, size: 50, color: item.color),
                            const SizedBox(height: 10),
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(item.category, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer_outlined, size: 14),
                                Text(" ${item.cookingTime}"),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------- RECIPE DETAIL SCREEN ----------------
class RecipeDetailScreen extends StatelessWidget {
  final RecipeItem item;
  const RecipeDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: DataService(),
        builder: (context, child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: item.color.withOpacity(0.2),
                    child: Center(child: Icon(item.icon, size: 120, color: item.color)),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(
                                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: item.isFavorite ? Colors.pink : Colors.grey,
                                size: 30,
                              ),
                              onPressed: () => DataService().toggleFavorite(item.id),
                            ),
                          ],
                        ),
                        Text(item.category, style: TextStyle(fontSize: 18, color: item.color, fontWeight: FontWeight.w600)),
                        const Divider(height: 30),
                        const Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(item.ingredients, style: const TextStyle(fontSize: 16, height: 1.5)),
                        const SizedBox(height: 25),
                        const Text("Cooking Instructions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(item.formula, style: const TextStyle(fontSize: 16, height: 1.6)),
                      ],
                    ),
                  )
                ]),
              )
            ],
          );
        },
      ),
    );
  }
}

// ---------------- PROFILE TAB ----------------
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DataService().currentUser;
    if (user == null) return const Center(child: Text("Please Login"));
    final isAdmin = user.role == 'admin';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60)),
          const SizedBox(height: 10),
          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(user.email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
              title: const Text("Admin Dashboard"),
              subtitle: const Text("Manage recipe categories & items"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPage())),
            ),
          
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pink),
            title: const Text("My Favorites"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FavoritesPage())),
          ),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsPage())),
          ),
        ],
      ),
    );
  }
}

// ---------------- FAVORITES PAGE ----------------
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: ListenableBuilder(
        listenable: DataService(),
        builder: (context, child) {
          final favorites = DataService().favorites;
          if (favorites.isEmpty) {
            return const Center(child: Text("No favorites yet. Tap the heart on a recipe!"));
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              return ListTile(
                leading: Icon(item.icon, color: item.color),
                title: Text(item.name),
                subtitle: Text(item.category),
                trailing: const Icon(Icons.favorite, color: Colors.pink),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => RecipeDetailScreen(item: item))),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- SETTINGS PAGE ----------------
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help & Support"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Reset App Data"),
            subtitle: const Text("This wipes all custom recipes and local changes"),
            onTap: () async {
              await DataService().resetAllData();
              if (context.mounted) {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Reset Successfully")));
              }
            },
          ),
        ],
      ),
    );
  }
}

class NotificationTab extends StatelessWidget {
  const NotificationTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("No new notifications"));
  }
}
