import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _warrantyController = TextEditingController();
  DateTime? _selectedDate;
  bool _notificationTriggered = false;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
                primary: Color(0xFFF4F4F0),
                onPrimary: Color(0xFF0D0D0D),
                surface: Color(0xFF1A1A1A)
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('NEW ASSET RECORD', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: Color(0xFFF4F4F0))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Color(0xFFF4F4F0)),
                    decoration: const InputDecoration(labelText: 'PRODUCT NAME', labelStyle: TextStyle(color: Color(0xFF7A7A7A), fontSize: 10)),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _warrantyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFF4F4F0)),
                    decoration: const InputDecoration(labelText: 'WARRANTY DURATION (MONTHS)', labelStyle: TextStyle(color: Color(0xFF7A7A7A), fontSize: 10)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDate == null ? 'CHOOSE PURCHASE DATE' : 'DATE: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7A7A7A))),
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7A7A7A)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // local notification link trigger mock
            InkWell(
              onTap: () {
                setState(() => _notificationTriggered = !_notificationTriggered);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('flutter_local_notifications boilerplate triggered.')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _notificationTriggered ? const Color(0xFFF4F4F0) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: _notificationTriggered ? const Color(0xFFF4F4F0) : const Color(0xFF7A7A7A), size: 18),
                    const SizedBox(width: 14),
                    const Text('MOCK SYSTEM EXPIRY REMINDER', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4F4F0),
                  foregroundColor: const Color(0xFF0D0D0D),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
              ),
              child: const Text('COMMIT ENTRY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            )
          ],
        ),
      ),
    );
  }
}