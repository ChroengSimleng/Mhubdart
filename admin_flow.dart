import 'package:flutter/material.dart';
import 'data_service.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Management")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
        onPressed: () {
          // Open form in Create Mode
          Navigator.push(context, MaterialPageRoute(builder: (c) => const ItemFormScreen()));
        },
      ),
      body: ListenableBuilder(
        listenable: DataService(),
        builder: (context, child) {
          final items = DataService().items;
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(item.icon)),
                title: Text(item.name),
                subtitle: Text(item.category),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Open form in Edit Mode
                        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemFormScreen(itemToEdit: item)));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Delete logic
                        DataService().deleteItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Deleted")));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- ADD/EDIT FORM SCREEN ----------------
class ItemFormScreen extends StatefulWidget {
  final RecipeItem? itemToEdit; // If null, we are creating. If exists, we are editing.

  const ItemFormScreen({super.key, this.itemToEdit});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _ingCtrl;
  late TextEditingController _formCtrl;
  String _category = 'Food';
  
  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing
    _nameCtrl = TextEditingController(text: widget.itemToEdit?.name ?? '');
    _ingCtrl = TextEditingController(text: widget.itemToEdit?.ingredients ?? '');
    _formCtrl = TextEditingController(text: widget.itemToEdit?.formula ?? '');
    if (widget.itemToEdit != null) {
      _category = widget.itemToEdit!.category;
    }
  }

  void _saveData() {
  if (_formKey.currentState!.validate()) {
    final isEditing = widget.itemToEdit != null;
    
    final newItem = RecipeItem(
      id: isEditing ? widget.itemToEdit!.id : DateTime.now().toString(),
      name: _nameCtrl.text,
      category: _category,
      ingredients: _ingCtrl.text,
      formula: _formCtrl.text,
      // Default values for new admin items for now (to keep code simple)
      cookingTime: '15 min', 
      difficulty: 'Medium',
      icon: _category == 'Food' ? Icons.fastfood : (_category == 'Drink' ? Icons.local_drink : Icons.cake),
      color: Colors.blue, 
    );

    if (isEditing) {
      DataService().updateItem(widget.itemToEdit!.id, newItem);
    } else {
      DataService().addItem(newItem);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "Updated!" : "Created!")));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.itemToEdit == null ? "Add New Item" : "Edit Item")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                  items: ['Food', 'Drink'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Ingredients", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _formCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: "Formula / Recipe", border: OutlineInputBorder(), alignLabelWithHint: true),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.itemToEdit == null ? "Create Item" : "Save Changes"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
