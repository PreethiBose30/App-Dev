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

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Digital Inventory",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: w * .05,
            vertical: h * .02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Greeting Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * .06),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(.35),
                      AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(.15),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Good Evening",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: w * .04,
                          ),
                        ),

                        SizedBox(height: h * .01),

                        Text(
                          "Preethi",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: w * .08,
                          ),
                        ),

                        SizedBox(height: h * .01),

                        const Text(
                          "Let's organize your documents",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary
                            .withOpacity(.15),
                      ),
                      child: const Icon(
                        Icons.folder_copy_outlined,
                        size: 38,
                        color: AppColors.primary,
                      ),
                    ),

                  ],
                ),
              ),

              SizedBox(height: h * .035),

              /// Search Bar
              Container(
                height: h * .07,
                decoration: BoxDecoration(
                  color:
                      AppColors.surface.withOpacity(.8),
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary
                          .withOpacity(.08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const TextField(
                  textAlignVertical:
                      TextAlignVertical.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search documents...",
                    contentPadding:
                        EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: h * .04),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: h * .02),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _quickActionCard(
                    icon:
                        Icons.document_scanner_outlined,
                    title: "Scan",
                    width: w,
                  ),
                  _quickActionCard(
                    icon: Icons.add_box_outlined,
                    title: "Add",
                    width: w,
                  ),
                  _quickActionCard(
                    icon:
                        Icons.upload_file_outlined,
                    title: "Import",
                    width: w,
                  ),
                ],
              ),

              SizedBox(height: h * .04),

                            /// Storage
              const Text(
                "Storage",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: h * .02),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * .05),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Storage Used",
                          style: TextStyle(
                            color:
                                AppColors.textPrimary,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        Text(
                          "68%",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20),
                      child:
                          const LinearProgressIndicator(
                        value: .68,
                        minHeight: 10,
                        backgroundColor:
                            Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "6.8 GB Used",
                          style: TextStyle(
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          "10 GB Total",
                          style: TextStyle(
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * .04),

              /// Recent Documents
              const Text(
                "Recent Documents",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: h * .02),

              _documentTile(
                icon: Icons.picture_as_pdf,
                title: "Passport.pdf",
                subtitle: "2 MB • Today",
              ),

              SizedBox(height: h * .015),

              _documentTile(
                icon: Icons.description,
                title: "Resume.docx",
                subtitle: "850 KB • Yesterday",
              ),

              SizedBox(height: h * .015),

              _documentTile(
                icon: Icons.image,
                title: "Invoice.png",
                subtitle: "1.4 MB • 2 days ago",
              ),

              SizedBox(height: h * .05),

                          ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy_outlined),
            label: "Files",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required double width,
  }) {
    return Container(
      width: width * .27,
      height: width * .27,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }
}
