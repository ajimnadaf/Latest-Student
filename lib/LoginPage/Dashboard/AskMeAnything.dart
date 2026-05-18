import 'package:flutter/material.dart';

class AIIntegratedPage extends StatelessWidget {
  const AIIntegratedPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController queryController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Color.fromARGB(255, 244, 22, 96),
        title: const Text(
          "Ask Me Anything",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Orange header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 236, 64, 122),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    "https://cdn-icons-png.flaticon.com/512/4712/4712105.png",
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "AI Integrated By Anthropic",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Query TextField
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: TextField(
                controller: queryController,
                decoration: const InputDecoration(
                  hintText: "Enter Your Query",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Search button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Searching your query...")),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Color.fromARGB(255, 236, 64, 122)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "SEARCH",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Your Answer + Make a Note
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Answer :",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Make a Note clicked")),
                    );
                  },
                  icon: const Icon(Icons.note_add, color: Color.fromARGB(255, 236, 64, 122)),
                  label: const Text(
                    "Make A Note",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Answer Box
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 15),

            // Bottom clickable text
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Getting possible doubts...")),
                );
              },
              child: const Text(
                "🧠 CLICK HERE TO GET POSSIBLE DOUBTS",
                style: TextStyle(
                  color: Color.fromARGB(255, 236, 64, 122),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
