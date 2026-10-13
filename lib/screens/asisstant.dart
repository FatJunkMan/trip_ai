import 'package:flutter/material.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {
      "type": "ai",
      "text":
          "Hi! I'm your Trip Assistant. What would you like to explore in Jordan?",
      "time": "10:00",
    }
  ];

  final List<String> suggestedQuestions = [
    'Where should I go in 2 days in Amman?',
    'Plan a cheap trip for 3 friends',
    'Best places for families in Petra',
    'Weekend getaway under 200 JOD',
  ];

  final sampleResponse = {
    "text":
        "I'd love to help you plan a 2-day trip in Amman! Here’s a suggestion:",
    "suggestions": [
      {
        "title": "Day 1: Ancient Amman",
        "places": ["Roman Theater", "Citadel", "Jordan Museum"],
        "cost": 45,
        "duration": "8 hours",
      },
      {
        "title": "Day 2: Modern Culture",
        "places": ["Rainbow Street", "Souk Jara", "Art Galleries"],
        "cost": 60,
        "duration": "7 hours",
      }
    ]
  };

  void sendMessage([String? text]) {
    final message = text ?? controller.text;
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({
        "type": "user",
        "text": message,
        "time": TimeOfDay.now().format(context),
      });
    });

    controller.clear();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add({
          "type": "ai",
          "text": sampleResponse["text"],
          "suggestions": sampleResponse["suggestions"],
          "time": TimeOfDay.now().format(context),
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      /// HEADER
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D28D9),
        title: const Text("Trip Assistant"),
      ),

      body: Column(
        children: [
          /// CHAT
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["type"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg["text"],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// suggestions (AI only)
                        if (!isUser && msg["suggestions"] != null)
                          ...List.generate(
                            msg["suggestions"].length,
                            (i) {
                              final s = msg["suggestions"][i];

                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s["title"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(s["places"].join(" • ")),
                                    Text(
                                        "${s["duration"]} • ${s["cost"]} JOD"),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// QUICK QUESTIONS
          if (messages.length == 1)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: suggestedQuestions.map((q) {
                  return ActionChip(
                    label: Text(q),
                    onPressed: () => sendMessage(q),
                  );
                }).toList(),
              ),
            ),

          /// INPUT
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Ask me about Jordan...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}