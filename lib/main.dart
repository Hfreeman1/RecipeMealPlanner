import 'package:flutter/material.dart';

void main() {
  runApp(RecipeApp());
}

class Recipe {
  final String name;
  final String category;
  final List<String> ingredients;
  final List<String> steps;

  Recipe(this.name, this.category, this.ingredients, this.steps);
}

class RecipeApp extends StatelessWidget {
  final List<Recipe> recipes = [
    Recipe("Spaghetti", "Vegetarian",
        ["Pasta", "Tomato Sauce", "Cheese"],
        ["Boil pasta", "Add sauce", "Top with cheese"]),
    Recipe("Chicken Salad", "Gluten-Free",
        ["Chicken", "Lettuce", "Dressing"],
        ["Cook chicken", "Mix ingredients"]),
    Recipe("Avocado Toast", "Vegan",
        ["Bread", "Avocado", "Salt"],
        ["Toast bread", "Spread avocado", "Add salt"]),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe & Meal Planner',
      theme: ThemeData(primarySwatch: Colors.green),
      home: RecipeListScreen(recipes: recipes),
    );
  }
}

class RecipeListScreen extends StatefulWidget {
  final List<Recipe> recipes;
  RecipeListScreen({required this.recipes});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    List<Recipe> filteredRecipes = selectedFilter == "All"
        ? widget.recipes
        : widget.recipes
            .where((r) => r.category == selectedFilter)
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Recipes")),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedFilter,
            items: ["All", "Vegan", "Vegetarian", "Gluten-Free"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedFilter = value!;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = filteredRecipes[index];
                return ListTile(
                  title: Text(recipe.name),
                  subtitle: Text(recipe.category),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ingredients:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.ingredients.map((e) => Text("- $e")),
            SizedBox(height: 10),
            Text("Steps:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.steps.map((e) => Text("- $e")),
          ],
        ),
      ),
    );
  }
}
