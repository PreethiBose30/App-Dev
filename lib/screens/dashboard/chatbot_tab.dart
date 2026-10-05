import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';

class ChatbotTab extends StatelessWidget {
  const ChatbotTab({super.key});

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder (rather than the ThemeAwareState mixin used by the
    // stateful screens) since this widget has no State to attach a
    // listener to -- it still needs to repaint when Appearance changes
    // while it's sitting underneath another route.
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: Text(
          'INVENTORY ASSISTANT',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),

          child: Column(
            children: [
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

                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'How can I help?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Ask about your products, warranties, '
                            'reminders, or inventory.',
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

                      child: TextField(
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),

                        decoration: InputDecoration(
                          hintText:
                          'Ask your inventory assistant...',

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