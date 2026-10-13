import 'package:flutter/material.dart';

class TripSetupScreen extends StatefulWidget {
  const TripSetupScreen({super.key});

  @override
  State<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends State<TripSetupScreen> {
  double budget = 500;
  int people = 2;
  String selectedType = "family";
  bool hasCar = false;
  String selectedLocation = "Amman - Downtown";

  final List<Map<String, dynamic>> tripTypes = [
    {"id": "family", "label": "Family", "icon": Icons.family_restroom},
    {"id": "friends", "label": "Friends", "icon": Icons.group},
    {"id": "couples", "label": "Couples", "icon": Icons.favorite},
    {"id": "adventure", "label": "Adventure", "icon": Icons.terrain},
  ];

  final List<String> locations = [
  "Amman - Downtown",
  "Amman - Abdali",
  "Amman - Jabal Amman",
  "Petra",
  "Wadi Rum",
  "Dead Sea",
];

  void generateTrip() {
  Navigator.pushNamed(
    context,
    '/ai-results',
    arguments: {
      "budget": budget,
      "people": people,
      "tripType": selectedType,
      "hasCar": hasCar,
      "location": selectedLocation,
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Plan Your Trip",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [

          /// CONTENT
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                /// 💰 BUDGET
                _buildCard(
                  title: "Budget",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${budget.toInt()} JOD",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      Slider(
                        value: budget,
                        min: 50,
                        max: 2000,
                        divisions: 40,
                        label: budget.toInt().toString(),
                        onChanged: (value) {
                          setState(() => budget = value);
                        },
                      ),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("50 JOD"),
                          Text("2000 JOD"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// 👥 PEOPLE
                _buildCard(
                  title: "Number of People",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (people > 1) people--;
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),

                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "$people",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() => people++);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// 🎯 TRIP TYPE
                _buildCard(
                  title: "Trip Type",
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tripTypes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final item = tripTypes[index];
                      final isSelected = selectedType == item["id"];

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedType = item["id"]);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green.shade50
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item["icon"],
                                color: isSelected
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 5),
                              Text(item["label"]),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                /// 🚗 TRANSPORT
                _buildCard(
                  title: "Transportation",
                  child: Row(
                    children: [

                      Expanded(
                        child: _transportOption(
                          title: "With Car",
                          icon: Icons.directions_car,
                          selected: hasCar,
                          onTap: () => setState(() => hasCar = true),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _transportOption(
                          title: "Public Transport",
                          icon: Icons.directions_bus,
                          selected: !hasCar,
                          onTap: () => setState(() => hasCar = false),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

          _buildCard(
          title: "Location",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Choose starting location"),

              const SizedBox(height: 10),

           Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 10),

                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLocation,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: locations.map((loc) {
                          return DropdownMenuItem(
                            value: loc,
                            child: Text(loc),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
            ],
          ),
        ),

              ],
            ),
          ),



          /// 🔥 GENERATE BUTTON
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: generateTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 10),
                  Text("Generate AI Trip Plan"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧱 Reusable Card
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  /// 🚗 Transport option
  Widget _transportOption({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }
}