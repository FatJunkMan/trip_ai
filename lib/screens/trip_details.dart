import 'package:flutter/material.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool showShare = false;

  final Map<String, dynamic> placeDetails = {
    "name": "Roman Theater",
    "description":
        "A stunning 6,000-seat Roman amphitheater built during the reign of Antoninus Pius (138-161 CE). This remarkably well-preserved structure is carved into a hillside and still hosts cultural events today.",
    "image":
        "https://images.unsplash.com/photo-1580674285054-bed31e145f59?w=800",
    "rating": 4.7,
    "reviews": 3420,
    "duration": "1.5 hours",
    "ticketLocal": 1,
    "ticketTourist": 3,
    "bestTime":
        "Early morning or late afternoon to avoid crowds",
    "tips": [
      "Wear comfortable shoes as there are many steps",
      "Bring water, especially in summer",
      "Visit the adjacent Odeon theater as well",
      "Photography is allowed"
    ],
    "highlights": [
      "Ancient Roman architecture",
      "Panoramic views of Amman",
      "Adjacent folklore museum",
      "Active cultural venue"
    ],
  };

  @override
  Widget build(BuildContext context) {
    final totalReviews = placeDetails["reviews"];
    final rating = placeDetails["rating"];

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          /// 🖼️ HEADER IMAGE
          Stack(
            children: [
              Image.network(
                placeDetails["image"],
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
              ),

              /// gradient overlay
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              /// back button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// 📄 CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE + RATING
                  Text(
                    placeDetails["name"],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "$rating",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text("($totalReviews reviews)",
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(placeDetails["duration"]),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// DESCRIPTION
                  Text(
                    placeDetails["description"],
                    style: const TextStyle(height: 1.5, color: Colors.black87),
                  ),

                  const SizedBox(height: 20),

                  /// PRICING CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ticket Pricing",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        rowPrice("Local", placeDetails["ticketLocal"]),
                        rowPrice("Tourist", placeDetails["ticketTourist"]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// HIGHLIGHTS
                  const Text(
                    "Highlights",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      placeDetails["highlights"].length,
                      (index) => Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          placeDetails["highlights"][index],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TIPS
                  const Text(
                    "Tips",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Column(
                    children: List.generate(
                      placeDetails["tips"].length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Text("• ",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(placeDetails["tips"][index]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BEST TIME
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF22C55E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Best Time to Visit",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          placeDetails["bestTime"],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔘 BOTTOM ACTIONS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh),
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

  Widget rowPrice(String title, int price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            "$price JOD",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}