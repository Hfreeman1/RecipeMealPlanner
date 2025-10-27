import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

void main() {
  runApp(RecipeApp());
}

class Recipe {
  final String name;
  final String category;
  final List<String> ingredients;
  final List<String> steps;

  Recipe(this.name, this.category, this.ingredients, this.steps);

  Map<String, dynamic> toJson() => {
        "name": name,
        "category": category,
        "ingredients": ingredients,
        "steps": steps
      };

  static Recipe fromJson(Map<String, dynamic> json) => Recipe(
        json["name"],
        json["category"],
        List<String>.from(json["ingredients"]),
        List<String>.from(json["steps"]),
      );
}

class RecipeApp extends StatefulWidget {
  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  int index = 0;
  final pages = [RecipeListScreen(), MealPlannerScreen(), FavoritesScreen()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ✅ hides DEBUG banner
      title: 'Recipe & Meal Planner',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        appBar: AppBar(title: Text('Recipe & Meal Planner')),
        body: pages[index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Recipes"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Planner"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          ],
        ),
      ),
    );
  }
}

class RecipeListScreen extends StatefulWidget {
  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final recipes = [
    Recipe("Spaghetti", "Vegetarian", ["Pasta", "Tomato Sauce", "Cheese"], ["Boil pasta", "Add sauce", "Top with cheese"]),
    Recipe("Chicken Salad", "Gluten-Free", ["Chicken", "Lettuce", "Dressing"], ["Cook chicken", "Mix ingredients"]),
    Recipe("Avocado Toast", "Vegan", ["Bread", "Avocado", "Salt"], ["Toast bread", "Spread avocado", "Add salt"]),
  ];

  String filter = "All";

  @override
  Widget build(BuildContext context) {
    final filtered = filter == "All"
        ? recipes
        : recipes.where((r) => r.category == filter).toList();

    return Column(children: [
      DropdownButton<String>(
        value: filter,
        items: ["All", "Vegan", "Vegetarian", "Gluten-Free"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => filter = v!),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final recipe = filtered[i];
            return ListTile(
              title: Text(recipe.name),
              subtitle: Text(recipe.category),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe)),
              ),
            );
          },
        ),
      )
    ]);
  }
}

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  RecipeDetailScreen(this.recipe);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool fav = false;

  void toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("favorites") ?? [];
    if (fav) {
      list.removeWhere((e) => e.contains(widget.recipe.name));
    } else {
      list.add(jsonEncode(widget.recipe.toJson()));
    }
    await prefs.setStringList("favorites", list);
    setState(() => fav = !fav);
  }

  void shareRecipe() {
    Share.share(
      "${widget.recipe.name}\n\nIngredients:\n${widget.recipe.ingredients.join(", ")}\n\nSteps:\n${widget.recipe.steps.join(", ")}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe.name), actions: [
        IconButton(icon: Icon(Icons.share), onPressed: shareRecipe),
        IconButton(icon: Icon(fav ? Icons.favorite : Icons.favorite_border), onPressed: toggleFavorite)
      ]),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Ingredients:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...widget.recipe.ingredients.map((e) => Text("- $e")),
          SizedBox(height: 10),
          Text("Steps:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...widget.recipe.steps.map((e) => Text("- $e")),
        ]),
      ),
    );
  }
}

class MealPlannerScreen extends StatefulWidget {
  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  Map<String, String> plan = {};
  final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final recipes = ["Spaghetti", "Chicken Salad", "Avocado Toast"];

  @override
  void initState() {
    super.initState();
    loadPlan();
  }

  Future<void> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("mealPlan");
    if (data != null) setState(() => plan = Map<String, String>.from(jsonDecode(data)));
  }

  Future<void> savePlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("mealPlan", jsonEncode(plan));
  }

  void showGroceries() {
    final grocery = ["Pasta", "Tomato Sauce", "Cheese", "Chicken", "Lettuce", "Dressing", "Bread", "Avocado", "Salt"];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Grocery List"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: grocery.map((e) => Text("- $e")).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              return ListTile(
                title: Text("$day: ${plan[day] ?? 'No meal selected'}"),
                trailing: DropdownButton<String>(
                  value: plan[day],
                  hint: Text("Select"),
                  items: recipes.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) {
                    setState(() => plan[day] = v!);
                    savePlan();
                  },
                ),
              );
            },
          ),
        ),
        ElevatedButton(onPressed: showGroceries, child: Text("Generate Grocery List")),
      ]),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Recipe> favs = [];

  @override
  void initState() {
    super.initState();
    loadFavs();
  }

  Future<void> loadFavs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("favorites") ?? [];
    setState(() => favs = list.map((e) => Recipe.fromJson(jsonDecode(e))).toList());
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: favs.length,
      itemBuilder: (context, i) {
        final r = favs[i];
        return ListTile(title: Text(r.name), subtitle: Text(r.category));
      },
    );
  }
}
