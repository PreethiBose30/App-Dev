import 'package:flutter/material.dart';

class ChatbotTab extends StatelessWidget {
  const ChatbotTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('VAULT CO-PILOT AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: Color(0xFFF4F4F0))),
          const SizedBox(height: 6),
          const Text('Scan logs or interrogate warranty metrics.', style: TextStyle(fontSize: 12, color: Color(0xFF7A7A7A))),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(24)),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF4A4A4A), size: 36),
                    SizedBox(height: 12),
                    Text('CHATBOT INTERFACE PLACEHOLDER', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
                  child: const Text('RUN INTELLIGENT EXPENSE ANALYSIS...', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.send, color: Color(0xFF7A7A7A), size: 16),
              )
            ],
          )
        ],
      ),
    );
  }
}