import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,

      /// 🚀 FLOATING ACTION BUTTON (SCAN / ADD)
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      /// 📱 PREMIUM BOTTOM NAV
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.description), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.category), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
        ),
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

              /// 👋 HEADER CARD
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

              SizedBox(height: h * 0.03),

              /// 🧭 SECTION CHIP (NEW UI ELEMENT)
              _sectionChip("Storage Overview"),

              const SizedBox(height: 12),

              /// 📦 STORAGE CARD (UPGRADED)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Storage Used",
                            style: TextStyle(color: AppColors.textPrimary)),
                        Text("68%",
                            style: TextStyle(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        value: 0.68,
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("6.8 GB Used",
                            style: TextStyle(color: AppColors.textSecondary)),
                        Text("10 GB Total",
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),

              /// 🔍 SEARCH
              Container(
                height: h * 0.065,
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const TextField(
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search documents...",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.mic_none_rounded,
                        color: AppColors.primary),
                  ),
                ),
              ),

              SizedBox(height: h * 0.03),

              /// 📄 RECENT DOCS CHIP
              _sectionChip("Recent Documents"),

              const SizedBox(height: 12),

              _recentDocCard("Invoice_2026.pdf", "PDF", "2h ago"),
              _recentDocCard("Project Notes", "Doc", "Yesterday"),
              _recentDocCard("ID Scan", "Image", "3d ago"),

              SizedBox(height: h * 0.03),

              /// 📂 CATEGORIES CHIP
              _sectionChip("Categories"),

              const SizedBox(height: 12),

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

              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  /// 🧠 SECTION CHIP (NEW PREMIUM UI ELEMENT)
  Widget _sectionChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 📄 RECENT CARD (POLISHED)
  Widget _recentDocCard(String title, String type, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
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
          const Icon(Icons.more_horiz,
              color: AppColors.textSecondary),
        ],
      ),
    );
  }

  /// 📂 CATEGORY CARD (MODERN)
  Widget _categoryCard(IconData icon, String title, String count) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.surface,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const Spacer(),
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
      ),
    );
  }
}
