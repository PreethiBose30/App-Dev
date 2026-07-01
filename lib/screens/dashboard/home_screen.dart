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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: const Icon(
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
            horizontal: w * 0.05,
            vertical: h * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Good Evening",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: w * 0.045,
                ),
              ),

              SizedBox(height: h * 0.005),

              Text(
                "Preethi",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: w * 0.085,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: h * 0.035),

              Container(
                height: h * 0.07,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const TextField(
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search documents...",
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

            ],
          ),
        ),
      ),
    );
  }
}
