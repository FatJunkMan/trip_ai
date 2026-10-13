import 'package:flutter/material.dart';
import 'package:trip_ai/widgets/share_trip_sheet.dart';

class AIResultsScreen extends StatefulWidget {
  const AIResultsScreen({super.key});

  @override
  State<AIResultsScreen> createState() => _AIResultsScreenState();
}

class _AIResultsScreenState extends State<AIResultsScreen> {
  bool saved = false;

  final List<Map<String, dynamic>> itinerary = [
    {
      "time": "9:00 AM",
      "place": "Roman Theater",
      "duration": "1.5 hours",
      "cost": 3,
      "image":
          "https://images.unsplash.com/photo-1580674285054-bed31e145f59?w=400",
    },
    {
      "time": "11:00 AM",
      "place": "Jordan Museum",
      "duration": "2 hours",
      "cost": 5,
      "image":
          "https://images.unsplash.com/photo-1566127992631-e5e8f3c5a6f4?w=400",
    },
    {
      "time": "1:30 PM",
      "place": "Rainbow Street Lunch",
      "duration": "1 hour",
      "cost": 15,
      "image":
          "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400",
    },
    {
      "time": "3:00 PM",
      "place": "Citadel (Jabal al-Qalaa)",
      "duration": "2 hours",
      "cost": 3,
      "image":
          "https://images.unsplash.com/photo-1591608971362-d00a3f3c4c9f?w=400",
    },
    {
      "time": "6:00 PM",
      "place": "Souk Jara",
      "duration": "1.5 hours",
      "cost": 10,
      "image":
          "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400",
    },
  ];

  int get totalCost =>
      itinerary.fold(0, (sum, item) => sum + item["cost"] as int);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      body: Column(
        children: [

          /// 🔥 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF2563EB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Back + Title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      "Your Trip Plan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// AI Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "AI Generated Trip",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),

                const SizedBox(height: 12),

                /// Summary Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      _stat("JOD", totalCost.toString()),
                      _stat("Places", itinerary.length.toString()),
                      _stat("Duration", "8h"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 ITINERARY LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: itinerary.length,
              itemBuilder: (context, index) {
                final item = itinerary[index];

                return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/trip-details',
                    arguments: item,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                 
                 child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical:10 ),
                  
                 
                  child: Row(
                    children: [

                      /// Image + Time badge
                    Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item["image"],
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace){
                                return Container(
                                  width: 90,
                                  height: 90,
                                  color:  Colors.grey,
                                  child: const Icon(Icons.image),
                                );
                              },
                            ),
                          ),

                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item["time"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      /// Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              item["place"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14),
                                const SizedBox(width: 4),
                                Text(item["duration"]),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 14),
                                const SizedBox(width: 4),
                                Text("${item["cost"]} JOD"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                 ),
                ),
                );
              },
            ),
          ),

          /// 🔥 BOTTOM ACTIONS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Column(
              children: [

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const ShareTripSheet(
                              title: "Amman Day Trip",
                              budget: 72,
                              people: 2,
                              duration: "8 hours",
                            ),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/trip-setup');
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Recreate"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => saved = true);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                  icon: const Icon(Icons.bookmark),
                  label: Text(saved ? "Trip Saved!" : "Save Trip"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}