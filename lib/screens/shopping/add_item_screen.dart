import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/shopping_item.dart';
import '../../providers/shopping_provider.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  // Controllers hold the text the user types
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _intervalCtrl = TextEditingController(
    text: '1',
  ); // for custom frequency

  // Local form state — which options are selected
  String _category = 'Veggies';
  String _unit = 'pcs';
  String _priority = 'Medium';
  String _buyFrom = 'Any';
  String _store = 'Any';
  bool _isRepeating = false;

  // ── Repeat frequency state ───────────────────────────────────────────────
  // _repeatType: 'Daily' | 'Weekly' | 'Monthly' | 'Custom'
  String _repeatType = 'Weekly';
  // Custom mode — interval unit: 'Days' | 'Weeks' | 'Months'
  String _customUnit = 'Days';
  // Which weekdays are ticked (used when _customUnit == 'Weeks' OR _repeatType == 'Weekly')
  final Set<String> _selectedWeekdays = {'Mon'};

  bool _isOftenBought = false;

  // Weekday labels in display order
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Compute the final repeatFrequency string to persist
  String get _computedRepeatFreq {
    switch (_repeatType) {
      case 'Daily':
        return 'Daily';
      case 'Weekly':
        if (_selectedWeekdays.isEmpty) return 'Weekly';
        final ordered = _weekdays.where(_selectedWeekdays.contains).join(', ');
        return 'Weekly on $ordered';
      case 'Monthly':
        return 'Monthly';
      case 'Custom':
        final n = int.tryParse(_intervalCtrl.text) ?? 1;
        if (_customUnit == 'Weeks' && _selectedWeekdays.isNotEmpty) {
          final ordered = _weekdays
              .where(_selectedWeekdays.contains)
              .join(', ');
          return 'Every $n Week${n > 1 ? 's' : ''} on $ordered';
        }
        return 'Every $n $_customUnit';
      default:
        return 'Weekly';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _qtyCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  // ─── Save item ─────────────────────────────────────────────────────────────
  void _save() {
    final name = _nameCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter an item name 👆',
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

    final qty = double.tryParse(_qtyCtrl.text) ?? 1.0;

    ref
        .read(shoppingProvider.notifier)
        .addItem(
          ShoppingItem(
            name: name,
            category: _category,
            quantity: qty,
            unit: _unit,
            priority: _priority,
            buyFrom: _buyFrom,
            store: _store,
            notes: _notesCtrl.text.trim(),
            isRepeating: _isRepeating,
            repeatFrequency: _computedRepeatFreq,
            isOftenBought: _isOftenBought,
          ),
        );

    Navigator.pop(context);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
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
            // ── Item Name ──────────────────────────────────────────────────
            _label('Item Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(),
              decoration: _inputDeco('e.g. Whole Milk', emoji: '🛍️'),
            ),
            const SizedBox(height: 24),

            // ── Category ───────────────────────────────────────────────────
            _label('Category'),
            const SizedBox(height: 10),
            _buildCategoryGrid(),
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
                Expanded(child: _buildUnitPicker()),
              ],
            ),
            const SizedBox(height: 24),

            // ── Priority ───────────────────────────────────────────────────
            _label('Priority'),
            const SizedBox(height: 10),
            _buildThreeChips(
              options: const [
                {'label': 'High', 'emoji': '🔴'},
                {'label': 'Medium', 'emoji': '🟡'},
                {'label': 'Low', 'emoji': '🟢'},
              ],
              selected: _priority,
              activeColorOf: (l) {
                if (l == 'High') return const Color(0xFFE74C3C);
                if (l == 'Low') return AppColors.teal;
                return AppColors.orange;
              },
              onTap: (val) => setState(() => _priority = val),
            ),
            const SizedBox(height: 24),

            // ── Buy From ───────────────────────────────────────────────────
            _label('Buy From'),
            const SizedBox(height: 10),
            _buildThreeChips(
              options: const [
                {'label': 'Any', 'emoji': '🛍️'},
                {'label': 'Online', 'emoji': '📱'},
                {'label': 'Outside', 'emoji': '🚶'},
              ],
              selected: _buyFrom,
              activeColorOf: (_) => AppColors.teal,
              onTap: (val) => setState(() => _buyFrom = val),
            ),
            const SizedBox(height: 24),

            // ── Store ──────────────────────────────────────────────────────
            _label('Store'),
            const SizedBox(height: 10),
            _buildStorePicker(),
            const SizedBox(height: 24),

            // ── Notes ──────────────────────────────────────────────────────
            _label('Notes  (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _inputDeco('e.g. Get Amul brand only', emoji: '📝'),
            ),
            const SizedBox(height: 24),

            // ── Repeat toggle ──────────────────────────────────────────────
            _buildRepeatToggle(),
            const SizedBox(height: 12),

            // ── Often Bought toggle ────────────────────────────────────────
            _buildOftenBoughtToggle(),
            const SizedBox(height: 32),

            // ── Big save button ────────────────────────────────────────────
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
                  'Add to Shopping List ✓',
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

  // ─── Category Grid ─────────────────────────────────────────────────────────
  Widget _buildCategoryGrid() {
    return GridView.count(
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
                color: isSelected ? AppColors.teal : Colors.grey.shade200,
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
                    color: isSelected ? Colors.white : AppColors.darkText,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Unit Picker ───────────────────────────────────────────────────────────
  Widget _buildUnitPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _unit,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkText),
          onChanged: (val) => setState(() => _unit = val!),
          items: AppConstants.units.map((u) {
            return DropdownMenuItem(value: u, child: Text(u));
          }).toList(),
        ),
      ),
    );
  }

  // ─── Reusable 3-chip row ───────────────────────────────────────────────────
  Widget _buildThreeChips({
    required List<Map<String, String>> options,
    required String selected,
    required Color Function(String) activeColorOf,
    required void Function(String) onTap,
  }) {
    return Row(
      children: options.map((opt) {
        final label = opt['label']!;
        final emoji = opt['emoji']!;
        final isSelected = selected == label;
        final color = activeColorOf(label);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Store Picker ──────────────────────────────────────────────────────────
  Widget _buildStorePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _store,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkText),
          onChanged: (val) => setState(() => _store = val!),
          items: AppConstants.stores.map((s) {
            return DropdownMenuItem(value: s, child: Text(s));
          }).toList(),
        ),
      ),
    );
  }

  // ─── Repeat Toggle (fully revamped) ───────────────────────────────────────
  Widget _buildRepeatToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master on/off switch
          SwitchListTile(
            value: _isRepeating,
            onChanged: (val) => setState(() => _isRepeating = val),
            activeTrackColor: AppColors.teal,
            title: Text(
              '🔁  Repeat Item',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              _isRepeating
                  ? _computedRepeatFreq
                  : 'Auto-add this on a schedule',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _isRepeating ? AppColors.teal : Colors.grey[600],
                fontWeight: _isRepeating ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Expanded frequency builder — only when repeat is ON
          if (_isRepeating) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Preset tabs: Daily / Weekly / Monthly / Custom ──────
                  _buildFrequencyTypeTabs(),
                  const SizedBox(height: 14),

                  // ── Weekly: day-of-week picker ─────────────────────────
                  if (_repeatType == 'Weekly') ...[
                    Text(
                      'Repeat on',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildWeekdayPicker(),
                  ],

                  // ── Custom: interval + unit + optional weekdays ─────────
                  if (_repeatType == 'Custom') ...[
                    _buildCustomIntervalRow(),
                    if (_customUnit == 'Weeks') ...[
                      const SizedBox(height: 14),
                      Text(
                        'Repeat on',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildWeekdayPicker(),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Four preset tabs ───────────────────────────────────────────────────────
  Widget _buildFrequencyTypeTabs() {
    const tabs = [
      {'label': 'Daily', 'emoji': '☀️'},
      {'label': 'Weekly', 'emoji': '📅'},
      {'label': 'Monthly', 'emoji': '🗓️'},
      {'label': 'Custom', 'emoji': '⚙️'},
    ];

    return Row(
      children: tabs.map((tab) {
        final label = tab['label']!;
        final emoji = tab['emoji']!;
        final isSelected = _repeatType == label;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _repeatType = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.teal : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.teal : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Weekday picker (Mon–Sun toggle chips) ──────────────────────────────────
  Widget _buildWeekdayPicker() {
    return Row(
      children: _weekdays.map((day) {
        final isSelected = _selectedWeekdays.contains(day);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected && _selectedWeekdays.length == 1) {
                    return;
                  } // keep ≥1 day
                  if (isSelected) {
                    _selectedWeekdays.remove(day);
                  } else {
                    _selectedWeekdays.add(day);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.teal : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.teal : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    day.substring(0, 1), // M T W T F S S — single letter
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Custom interval row: "Every [N] [Days/Weeks/Months]" ──────────────────
  Widget _buildCustomIntervalRow() {
    const units = ['Days', 'Weeks', 'Months'];

    return Row(
      children: [
        // "Every" label
        Text(
          'Every',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(width: 10),

        // Number input
        Container(
          width: 64,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _intervalCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxValueFormatter(999),
            ],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => setState(() {}), // rebuild preview in subtitle
          ),
        ),
        const SizedBox(width: 10),

        // Unit picker chips
        Expanded(
          child: Row(
            children: units.map((u) {
              final isSelected = _customUnit == u;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _customUnit = u),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.teal.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.teal
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          u,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.teal
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Often Bought Toggle ───────────────────────────────────────────────────
  Widget _buildOftenBoughtToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: _isOftenBought,
        onChanged: (val) => setState(() => _isOftenBought = val),
        activeTrackColor: AppColors.orange,
        title: Text(
          '⚡  Often Bought',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          'Shows in quick-add row at the top',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
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

// ─── Helper formatter: prevents entering values above 999 ──────────────────
class _MaxValueFormatter extends TextInputFormatter {
  final int max;
  _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final val = int.tryParse(newValue.text) ?? 0;
    if (val > max) return oldValue;
    if (val < 1 && newValue.text.isNotEmpty) return oldValue;
    return newValue;
  }
}
