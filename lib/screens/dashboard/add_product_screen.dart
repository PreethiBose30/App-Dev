import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Phone';

  DateTime? _purchaseDate;
  DateTime? _serviceDate;

  String? _documentPath;

  bool _reminderEnabled = false;
  bool _isSaving = false;

  final List<String> _categories = [
    'Phone',
    'Laptop',
    'TV',
    'Car',
    'Appliance',
    'Furniture',
    'Other',
  ];

  Future<void> _pickDate({
    required bool isPurchaseDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF4F4F0),
              onPrimary: Color(0xFF0D0D0D),
              surface: Color(0xFF1A1A1A),
              onSurface: Color(0xFFF4F4F0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _serviceDate = picked;
        }
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result != null &&
        result.files.single.path != null) {
      setState(() {
        _documentPath = result.files.single.path;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the product name',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final int warrantyMonths =
          int.tryParse(
            _warrantyController.text.trim(),
          ) ??
              0;

      DateTime? warrantyExpiry;

      if (_purchaseDate != null &&
          warrantyMonths > 0) {
        warrantyExpiry = DateTime(
          _purchaseDate!.year,
          _purchaseDate!.month + warrantyMonths,
          _purchaseDate!.day,
        );
      }

      final product = Product(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        name: _nameController.text.trim(),

        category: _selectedCategory,

        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),

        modelNumber:
        _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),

        price: double.tryParse(
          _priceController.text.trim(),
        ),

        purchaseDate: _purchaseDate,

        warrantyDuration:
        warrantyMonths == 0
            ? null
            : warrantyMonths,

        warrantyExpiry: warrantyExpiry,

        serviceDate: _serviceDate,

        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),

        documentPath: _documentPath,
      );

      await HiveService.addProduct(product);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product saved successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save product: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _warrantyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFFF4F4F0),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF8A8A8A),
          fontSize: 11,
          letterSpacing: 0.8,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF383838),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF4F4F0),
          ),
        ),
      ),
    );
  }

  Widget _dateTile({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFFF4F4F0),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                date == null
                    ? title
                    : '$title: '
                    '${date.day}/'
                    '${date.month}/'
                    '${date.year}',
                style: const TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFF0D0D0D),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFFF4F4F0),
        ),
        title: const Text(
          'ADD PRODUCT',
          style: TextStyle(
            color: Color(0xFFF4F0),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            24,
            10,
            24,
            35,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              const Text(
                'NEW ASSET RECORD',
                style: TextStyle(
                  color: Color(0xFFF4F4F0),
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter the product details below',
                style: TextStyle(
                  color: Color(0xFF7A7A7A),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding:
                const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color:
                  const Color(0xFF1A1A1A),

                  borderRadius:
                  BorderRadius.circular(
                    24,
                  ),
                ),

                child: Column(
                  children: [
                    _textField(
                      controller:
                      _nameController,
                      label:
                      'PRODUCT NAME',
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value:
                      _selectedCategory,

                      dropdownColor:
                      const Color(
                        0xFF1A1A1A,
                      ),

                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFFF4F4F0,
                        ),
                      ),

                      decoration:
                      const InputDecoration(
                        labelText:
                        'CATEGORY',

                        labelStyle:
                        TextStyle(
                          color:
                          Color(
                            0xFF8A8A8A,
                          ),

                          fontSize:
                          11,
                        ),
                      ),

                      items:
                      _categories.map(
                            (category) {
                          return DropdownMenuItem(
                            value:
                            category,

                            child:
                            Text(
                              category,
                            ),
                          );
                        },
                      ).toList(),

                      onChanged:
                          (value) {
                        if (value !=
                            null) {
                          setState(
                                () {
                              _selectedCategory =
                                  value;
                            },
                          );
                        }
                      },
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _textField(
                      controller:
                      _brandController,
                      label:
                      'BRAND',
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _textField(
                      controller:
                      _modelController,
                      label:
                      'MODEL NUMBER',
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _textField(
                      controller:
                      _priceController,
                      label:
                      'PRICE (OPTIONAL)',
                      keyboardType:
                      TextInputType
                          .number,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _textField(
                      controller:
                      _warrantyController,
                      label:
                      'WARRANTY DURATION '
                          '(MONTHS)',
                      keyboardType:
                      TextInputType
                          .number,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _textField(
                      controller:
                      _notesController,
                      label:
                      'NOTES (OPTIONAL)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _dateTile(
                title:
                'CHOOSE PURCHASE DATE',

                date:
                _purchaseDate,

                onTap: () {
                  _pickDate(
                    isPurchaseDate:
                    true,
                  );
                },
              ),

              const SizedBox(height: 14),

              _dateTile(
                title:
                'CHOOSE NEXT SERVICE DATE',

                date:
                _serviceDate,

                onTap: () {
                  _pickDate(
                    isPurchaseDate:
                    false,
                  );
                },
              ),

              const SizedBox(height: 14),

              InkWell(
                onTap:
                _pickDocument,

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

                child: Container(
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFF161616,
                    ),

                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .upload_file_outlined,

                        color:
                        Color(
                          0xFFF4F4F0,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Text(
                          _documentPath ==
                              null
                              ? 'UPLOAD BILL '
                              'OR WARRANTY '
                              'DOCUMENT'
                              : 'DOCUMENT '
                              'SELECTED',

                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFFB0B0B0,
                            ),

                            fontSize:
                            12,

                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SwitchListTile(
                value:
                _reminderEnabled,

                onChanged:
                    (value) {
                  setState(
                        () {
                      _reminderEnabled =
                          value;
                    },
                  );
                },

                activeColor:
                const Color(
                  0xFFF4F4F0,
                ),

                title:
                const Text(
                  'WARRANTY EXPIRY '
                      'REMINDER',

                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFFF4F4F0,
                    ),

                    fontSize:
                    13,

                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),

                subtitle:
                const Text(
                  'Get notified before '
                      'the warranty expires',

                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFF7A7A7A,
                    ),

                    fontSize:
                    11,
                  ),
                ),

                contentPadding:
                EdgeInsets.zero,
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed:
                _isSaving
                    ? null
                    : _saveProduct,

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  const Color(
                    0xFFF4F4F0,
                  ),

                  foregroundColor:
                  const Color(
                    0xFF0D0D0D,
                  ),

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 18,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                  ),
                ),

                child:
                Text(
                  _isSaving
                      ? 'SAVING...'
                      : 'SAVE PRODUCT',

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,

                    letterSpacing:
                    1,
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