import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'; // Removed 'as http' and imported directly
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Meal>> meals;

  @override
  void initState() {
    super.initState();
    meals = fetchMeals();
  }

  // Fetch data from the API
  Future<List<Meal>> fetchMeals() async {
    final response = await get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=a'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> mealsData = data['meals'];

      return mealsData.map((meal) => Meal.fromJson(meal)).toList();
    } else {
      throw Exception('Failed to load meals: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<List<Meal>>(
        future: meals,
        builder: (BuildContext ctx, AsyncSnapshot<List<Meal>> snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(child: Text('Oh no! Error: ${snapshot.error}'));
          }

          // No data state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nothing to show"));
          }

          // Data loaded successfully
          final List<Meal> meals = snapshot.data!;

          return Column(
            children: [
              // Centered title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "List of Meals",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // List of meals in the body
              Expanded(
                child: ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0), // Space between ExpansionTiles
                      child: Container(
                        color: Colors.grey[200], // Set background to gray
                        child: ExpansionTile(
                          leading: Image.network(meal.strMealThumb,
                              width: 50, height: 50, fit: BoxFit.cover),
                          title: Text(meal.strMeal),
                          subtitle:
                              Text('${meal.strCategory} - ${meal.strArea}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Show the instructions for this meal
                                  Text(
                                    "Instructions:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(meal.strInstructions.isEmpty
                                      ? "No instructions available"
                                      : meal.strInstructions),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Model class for Meal
class Meal {
  final String strMeal;
  final String strMealThumb;
  final String strCategory;
  final String strArea;
  final String strInstructions;

  Meal({
    required this.strMeal,
    required this.strMealThumb,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
  });

  // A factory constructor to create a Meal object from JSON data
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      strMeal: json['strMeal'],
      strMealThumb: json['strMealThumb'],
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions:
          json['strInstructions'] ?? "", // Handle null instructions
    );
  }
}
