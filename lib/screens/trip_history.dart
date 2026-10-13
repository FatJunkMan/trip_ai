import 'package:flutter/material.dart';
import 'package:trip_ai/widgets/share_trip_sheet.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final List<Map<String, dynamic>> savedTrips = [
    {
      "id": 1,
      "title": "Petra & Wadi Rum Adventure",
      "budget": 500,
      "days": 3,
      "people": 2,
      "date": "Apr 20, 2026",
      "image":
          "https://images.unsplash.com/photo-1578070181910-f1e514afdd08?w=400",
    },
    {
      "id": 2,
      "title": "Amman City Explorer",
      "budget": 150,
      "days": 1,
      "people": 4,
      "date": "Apr 18, 2026",
      "image":
          "https://images.unsplash.com/photo-1553532434-5ab5b6b84993?w=400",
    },
    {
      "id": 3,
      "title": "Dead Sea Relaxation",
      "budget": 300,
      "days": 2,
      "people": 2,
      "date": "Apr 10, 2026",
      "image":
          "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400",
    },
    {
      "id": 4,
      "title": "Jerash Historical Tour",
      "budget": 100,
      "days": 1,
      "people": 3,
      "date": "Apr 5, 2026",
      "image":
          "https://images.unsplash.com/photo-1585137823500-8b62a21e4d16?w=400",
    },
  ];

void shareTrip(Map<String, dynamic> trip) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ShareTripSheet(
      title: trip["title"],
      budget: trip["budget"],
      people: trip["people"],
      duration: "${trip["days"]} Days",
    ),
  );
}

  Widget tripCard(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/ai-results');
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      trip["image"],
                      width: 105,
                      height: 105,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 105,
                          height: 105,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),

                  /// RIGHT SIDE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome,
                                  size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                "AI Generated",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          trip["title"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text("${trip["days"]} Days"),

                            const SizedBox(width: 10),

                            const Icon(Icons.people,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text("${trip["people"]}"),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.attach_money,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text("${trip["budget"]} JOD"),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Saved on ${trip["date"]}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BOTTOM BUTTONS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF1F1F1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => shareTrip(trip),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text("Share"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/trip-setup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Recreate"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.history, size: 35),
            ),
            const SizedBox(height: 18),
            const Text(
              "No saved trips",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Start planning your first AI-powered trip",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/trip-setup');
              },
              child: const Text("Plan Your Trip"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Trip History",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${savedTrips.length} Saved Trips",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: savedTrips.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: savedTrips.length,
                      itemBuilder: (context, index) {
                        return tripCard(savedTrips[index]);
                      },
                    )
                  : emptyState(),
            ),
          ],
        ),
      ),
    );
  }
}