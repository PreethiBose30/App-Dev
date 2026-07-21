import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ChatbotTab extends StatelessWidget {
  const ChatbotTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Inventory Assistant',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Ask anything about your inventory',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Expanded(
                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: AppColors.surface,

                    borderRadius: BorderRadius.circular(24),

                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'How can I help?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Ask about your products, warranties,\nreminders, or inventory.',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.surface,

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),

                      child: const TextField(
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),

                        decoration: InputDecoration(
                          hintText: 'Ask your inventory assistant...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),

                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}