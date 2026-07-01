import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,

      /// 📱 BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "Docs"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Digital Inventory",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.textPrimary,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person_outline, color: Colors.white),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.05,
            vertical: h * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 👋 WELCOME CARD
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.06),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.35),
                      AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Evening",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: w * 0.04,
                          ),
                        ),
                        SizedBox(height: h * 0.01),
                        Text(
                          "Preethi",
                          style: TextStyle(
                            fontSize: w * 0.08,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(.15),
                      ),
                      child: const Icon(
                        Icons.folder_copy_outlined,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),

              /// 📦 STORAGE CARD
              const Text(
                "Storage",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: h * 0.02),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Storage Used",
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold)),
                        Text("68%",
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const SizedBox(height: 15),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: const LinearProgressIndicator(
                        value: 0.68,
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("6.8 GB Used",
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                        Text("10 GB Total",
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),

              /// 🔍 SEARCH BAR
              Container(
                height: h * 0.07,
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(.75),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: const TextField(
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search documents...",
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textSecondary),
                    suffixIcon: Icon(Icons.mic_none_rounded,
                        color: AppColors.primary),
                  ),
                ),
              ),

              SizedBox(height: h * 0.04),

              /// 📄 RECENT DOCUMENTS
              const Text(
                "Recent Documents",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _recentDocCard("Invoice_2026.pdf", "PDF", "2h ago"),
              _recentDocCard("Project Notes", "Doc", "Yesterday"),
              _recentDocCard("ID Proof Scan", "Image", "3 days ago"),

              SizedBox(height: h * 0.03),

              /// 📂 CATEGORIES
              const Text(
                "Categories",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _categoryCard(Icons.picture_as_pdf, "PDFs", "12"),
                  _categoryCard(Icons.image_outlined, "Images", "8"),
                  _categoryCard(Icons.scanner_outlined, "Scans", "5"),
                  _categoryCard(Icons.folder_outlined, "Folders", "3"),
                ],
              ),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  /// 📄 Recent Document Card
  static Widget _recentDocCard(String title, String type, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined,
                color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("$type • $time",
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.more_vert,
              color: AppColors.textSecondary),
        ],
      ),
    );
  }

  /// 📂 Category Card
  static Widget _categoryCard(
      IconData icon, String title, String count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text("$count items",
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
