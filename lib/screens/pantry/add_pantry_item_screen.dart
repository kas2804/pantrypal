import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/pantry_item.dart';
import '../../providers/pantry_provider.dart';

class AddPantryItemScreen extends ConsumerStatefulWidget {
  const AddPantryItemScreen({super.key});

  @override
  ConsumerState<AddPantryItemScreen> createState() =>
      _AddPantryItemScreenState();
}

class _AddPantryItemScreenState extends ConsumerState<AddPantryItemScreen> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');

  String _category = 'Veggies';
  String _unit = 'pcs';
  String _status = 'In Stock';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter an item name',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    ref
        .read(pantryProvider.notifier)
        .addItem(
          PantryItem(
            name: name,
            category: _category,
            quantity: double.tryParse(_qtyCtrl.text) ?? 1.0,
            unit: _unit,
            status: _status,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Pantry'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name ──────────────────────────────────────────────────────
            _label('Item Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(),
              decoration: _inputDeco('e.g. Basmati Rice', emoji: '🥦'),
            ),
            const SizedBox(height: 24),

            // ── Category ──────────────────────────────────────────────────
            _label('Category'),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.9,
              children: AppConstants.categories.map((cat) {
                final label = cat['label']!;
                final emoji = cat['emoji']!;
                final isSelected = _category == label;
                return GestureDetector(
                  onTap: () => setState(() => _category = label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.teal : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.teal
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkText,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Quantity + Unit ────────────────────────────────────────────
            _label('Quantity & Unit'),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    decoration: _inputDeco('1'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.units.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final u = AppConstants.units[i];
                        final sel = _unit == u;
                        return GestureDetector(
                          onTap: () => setState(() => _unit = u),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.orange : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel
                                    ? AppColors.orange
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                u,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? Colors.white
                                      : AppColors.darkText,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Status ────────────────────────────────────────────────────
            _label('Current Status'),
            const SizedBox(height: 10),
            Row(
              children: [
                _statusChip('In Stock', AppColors.teal),
                const SizedBox(width: 8),
                _statusChip('Running Low', AppColors.orange),
                const SizedBox(width: 8),
                _statusChip('Out of Stock', const Color(0xFFE74C3C)),
              ],
            ),
            const SizedBox(height: 32),

            // ── Save ──────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Add to Pantry ✓',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    final isSelected = _status == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 46,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.darkText,
    ),
  );

  InputDecoration _inputDeco(String hint, {String? emoji}) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
    prefixIcon: emoji != null
        ? Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          )
        : null,
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.teal, width: 2),
    ),
  );
}
