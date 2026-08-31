import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../providers/customer/customer_bookings_provider.dart';
import '../../utils/colors/app_colors.dart';

class CreateWeddingEventModal extends StatefulWidget {
  final ValueChanged<WeddingEventModel>? onCreated;

  const CreateWeddingEventModal({super.key, this.onCreated});

  @override
  State<CreateWeddingEventModal> createState() => _CreateWeddingEventModalState();
}

class _CreateWeddingEventModalState extends State<CreateWeddingEventModal> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();

  String _selectedEventType = 'mehndi';
  DateTime? _selectedDate;
  bool _submitting = false;
  String? _error;

  static const List<Map<String, String>> _eventTypes = [
    {'type': 'mehndi', 'label': 'Mehndi', 'icon': '✨'},
    {'type': 'baraat', 'label': 'Baraat', 'icon': '🎺'},
    {'type': 'walima', 'label': 'Walima', 'icon': '🥂'},
    {'type': 'engagement', 'label': 'Engagement', 'icon': '💍'},
    {'type': 'nikkah', 'label': 'Nikkah', 'icon': '📜'},
    {'type': 'qawwali', 'label': 'Qawwali Night', 'icon': '🎵'},
    {'type': 'reception', 'label': 'Reception', 'icon': '🎉'},
    {'type': 'other', 'label': 'Custom Event', 'icon': '✨'},
  ];

  @override
  void dispose() {
    _labelController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Please enter an event name/label.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final token = context.read<CustomerAuthProvider>().token ?? '';
    final dateStr = _selectedDate != null
        ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
        : null;

    final created = await context
        .read<CustomerBookingsProvider>()
        .createWeddingEvent(
          token: token,
          eventType: _selectedEventType,
          customLabel: label,
          eventDate: dateStr,
          venue: _venueController.text.trim().isNotEmpty
              ? _venueController.text.trim()
              : null,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (created != null) {
      if (widget.onCreated != null) {
        widget.onCreated!(created);
      }
      Navigator.pop(context, created);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event "$label" created successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else {
      setState(() => _error = 'Failed to create event. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Wedding Event',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Add an event to organize your service bookings',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMedium),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Event Type Chips
            Text(
              'Select Event Type',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _eventTypes.map((item) {
                final isSelected = _selectedEventType == item['type'];
                return ChoiceChip(
                  label: Text('${item['icon']} ${item['label']}'),
                  labelStyle: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.brandPink,
                  backgroundColor: AppColors.lightGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.brandPink
                          : Colors.transparent,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedEventType = item['type']!;
                        if (_labelController.text.isEmpty ||
                            _eventTypes.any((t) =>
                                t['label'] == _labelController.text)) {
                          _labelController.text = item['label']!;
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Event Custom Label
            Text(
              'Event Name / Label',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                hintText: 'e.g. Fatima & Ali’s Mehndi',
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Event Date
            Text(
              'Event Date (Optional)',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 1095)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderGrey),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Tap to pick date',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _selectedDate != null
                            ? AppColors.textDark
                            : AppColors.textMedium,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: AppColors.brandPink,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Venue Location
            Text(
              'Event Venue / Location (Optional)',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _venueController,
              decoration: InputDecoration(
                hintText: 'e.g. Pearl Continental Grand Ballroom',
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Create Event',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
