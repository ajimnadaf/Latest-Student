import 'package:flutter/material.dart';

class StudentDocumentPage extends StatelessWidget {
  const StudentDocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Color.fromARGB(255, 3, 169, 244),
        title: const Text(
          "Document",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Document Management Card
            _buildWhiteCard(
              leftImage:
                  "https://cdn-icons-png.flaticon.com/512/1161/1161388.png",
              title: "DOCUMENT MANAGEMENT",
              rightImage:
                  "https://cdn-icons-png.flaticon.com/512/992/992651.png",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DocumentPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            // Category Card
            _buildColorCard(
              color: Colors.deepOrange,
              image: "https://cdn-icons-png.flaticon.com/512/2920/2920046.png",
              title: "CATEGORY",
              subtitle: "Click Here to Change Category",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoryPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            // Sub-Category Card
            _buildColorCard(
              color: Colors.purple,
              image: "https://cdn-icons-png.flaticon.com/512/2921/2921123.png",
              title: "SUB-CATEGORY",
              subtitle: "Click Here to Change Sub-Category",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SubCategoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // White Card (Document Management)
  Widget _buildWhiteCard({
    required String leftImage,
    required String title,
    required String rightImage,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.network(leftImage, height: 45, width: 45),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
            Image.network(rightImage, height: 40, width: 40),
          ],
        ),
      ),
    );
  }

  // Colored Card (Category / Sub-Category)
  Widget _buildColorCard({
    required Color color,
    required String image,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.network(image, height: 45, width: 45),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- NEXT PAGES --------------------

class DocumentPage extends StatelessWidget {
  const DocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document Management")),
      body: const Center(
        child: Text(
          "Welcome to Document Management Page!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Category")),
      body: const Center(
        child: Text(
          "Welcome to Category Page!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class SubCategoryPage extends StatelessWidget {
  const SubCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sub-Category")),
      body: const Center(
        child: Text(
          "Welcome to Sub-Category Page!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
