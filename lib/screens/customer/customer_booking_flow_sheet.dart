import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/booking/booking_model.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../providers/customer/customer_bookings_provider.dart';
import '../../providers/venue/venue_provider.dart';
import '../../utils/colors/app_colors.dart';
import 'create_wedding_event_modal.dart';

class CustomerBookingFlowSheet extends StatefulWidget {
  final String? initialSubcategoryId;
  final String? initialSubcategoryName;
  final String? initialCategoryName;
  final String? initialEventId;

  const CustomerBookingFlowSheet({
    super.key,
    this.initialSubcategoryId,
    this.initialSubcategoryName,
    this.initialCategoryName,
    this.initialEventId,
  });

  static void show(
    BuildContext context, {
    String? subcategoryId,
    String? subcategoryName,
    String? categoryName,
    String? eventId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerBookingFlowSheet(
        initialSubcategoryId: subcategoryId,
        initialSubcategoryName: subcategoryName,
        initialCategoryName: categoryName,
        initialEventId: eventId,
      ),
    );
  }

  @override
  State<CustomerBookingFlowSheet> createState() =>
      _CustomerBookingFlowSheetState();
}

class _CustomerBookingFlowSheetState extends State<CustomerBookingFlowSheet> {
  // Step state: 0 = Pick Service, 1 = Pick Event, 2 = Details, 3 = Success
  int _currentStep = 0;

  String? _selectedSubcategoryId;
  String? _selectedSubcategoryName;
  String? _selectedCategoryName;

  final Set<String> _selectedEventIds = {};
  DateTime? _selectedDate;
  int _guestCount = 150;
  final TextEditingController _notesController = TextEditingController();

  bool _submitting = false;
  String? _error;
  int _createdCount = 0;

  static const Map<String, String> _eventCovers = {
    'engagement':
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
    'mehndi':
        'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=600&q=80',
    'baraat':
        'https://images.unsplash.com/photo-1464366400600-7168b107af1c?w=600&q=80',
    'walima':
        'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=600&q=80',
    'nikkah':
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
    'qawwali':
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
    'reception':
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600&q=80',
    'other':
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
  };

  String _resolveEventImage(WeddingEventModel event) {
    if (event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty) {
      return event.coverImageUrl!;
    }
    final key = event.eventType.toLowerCase();
    return _eventCovers[key] ?? _eventCovers['engagement']!;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategoryName = widget.initialCategoryName;

    // If subcategory was pre-selected (by ID or by name), start directly at Step 1 (Pick Event)
    if (widget.initialSubcategoryId != null &&
        widget.initialSubcategoryId!.isNotEmpty) {
      _selectedSubcategoryId = widget.initialSubcategoryId;
      _selectedSubcategoryName = widget.initialSubcategoryName;
      _currentStep = 1;
    } else if (widget.initialSubcategoryName != null &&
        widget.initialSubcategoryName!.isNotEmpty) {
      _selectedSubcategoryName = widget.initialSubcategoryName;
      _currentStep = 1;
    }

    if (widget.initialEventId != null && widget.initialEventId!.isNotEmpty) {
      _selectedEventIds.add(widget.initialEventId!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = context.read<CustomerAuthProvider>().token ?? '';
      context.read<CustomerBookingsProvider>().loadWeddingEvents(token);

      final venueProvider = context.read<VenueProvider>();
      if (venueProvider.subCategories.isEmpty) {
        await venueProvider.fetchCategories();
      }

      if (!mounted) return;

      // If we have an ID but need the name
      if (_selectedSubcategoryId != null &&
          (_selectedSubcategoryName == null ||
              _selectedSubcategoryName!.isEmpty)) {
        try {
          final matched = venueProvider.subCategories
              .firstWhere((s) => s.id == _selectedSubcategoryId);
          setState(() {
            _selectedSubcategoryName = matched.title;
            _selectedCategoryName ??= matched.categoryName;
          });
        } catch (_) {}
      }

      // If we have a name but need the ID
      if (_selectedSubcategoryId == null &&
          _selectedSubcategoryName != null &&
          _selectedSubcategoryName!.isNotEmpty) {
        try {
          final matched = venueProvider.subCategories.firstWhere(
            (s) =>
                s.title.toLowerCase() ==
                    _selectedSubcategoryName!.toLowerCase() ||
                (s.categoryName != null &&
                    _selectedCategoryName != null &&
                    s.categoryName!.toLowerCase() ==
                        _selectedCategoryName!.toLowerCase()),
          );
          setState(() {
            _selectedSubcategoryId = matched.id;
            _selectedCategoryName ??= matched.categoryName;
          });
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleToggleEvent(WeddingEventModel event) {
    setState(() {
      if (_selectedEventIds.contains(event.id)) {
        _selectedEventIds.remove(event.id);
      } else {
        _selectedEventIds.add(event.id);
      }

      if (_selectedEventIds.isNotEmpty && _selectedDate == null) {
        if (event.eventDate != null && event.eventDate!.isNotEmpty) {
          final parsed = DateTime.tryParse(event.eventDate!);
          if (parsed != null) _selectedDate = parsed;
        }
      }
    });
  }

  void _openCreateEvent() async {
    final created = await showModalBottomSheet<WeddingEventModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateWeddingEventModal(),
    );

    if (created != null && mounted) {
      setState(() {
        _selectedEventIds.add(created.id);
        if (created.eventDate != null && created.eventDate!.isNotEmpty) {
          final parsed = DateTime.tryParse(created.eventDate!);
          if (parsed != null) _selectedDate = parsed;
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedSubcategoryId == null) {
      setState(() => _error = 'Please select a service or subcategory.');
      return;
    }
    if (_selectedEventIds.isEmpty) {
      setState(() => _error = 'Please select at least one wedding event.');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = 'Please select an event date.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final token = context.read<CustomerAuthProvider>().token ?? '';
    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    final err = await context.read<CustomerBookingsProvider>().createBooking(
          token: token,
          subcategoryId: _selectedSubcategoryId!,
          eventIds: _selectedEventIds.toList(),
          eventDate: dateStr,
          guestCount: _guestCount,
          specialRequests: _notesController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (err == null) {
      setState(() {
        _createdCount = _selectedEventIds.length;
        _currentStep = 3; // Success step
      });
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _stepTitle(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _stepSubtitle(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textDark, size: 22),
                ),
              ],
            ),
          ),

          // Multi-Step Progress Indicator
          if (_currentStep < 3) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: Row(
                children: [
                  _buildStepDot(0, 'Service'),
                  _buildStepDivider(0),
                  _buildStepDot(1, 'Event'),
                  _buildStepDivider(1),
                  _buildStepDot(2, 'Details'),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.lightGrey),
          ],

          // Error Banner
          if (_error != null) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Step Body
          Expanded(
            child: _buildCurrentStepContent(),
          ),

          // Bottom Action Bar
          if (_currentStep < 3) _buildBottomActionBar(),
        ],
      ),
    );
  }

  String _stepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Choose Service';
      case 1:
        return 'Select Wedding Event';
      case 2:
        return 'Booking Details';
      case 3:
        return 'Booking Submitted!';
      default:
        return 'Book Service';
    }
  }

  String _stepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Step 1 of 3 — Pick a category & offering';
      case 1:
        return 'Step 2 of 3 — Attach to your wedding event(s)';
      case 2:
        return 'Step 3 of 3 — Enter date, guest count & notes';
      case 3:
        return 'Your booking request has been dispatched';
      default:
        return '';
    }
  }

  Widget _buildStepDot(int stepIndex, String label) {
    final isDone = _currentStep > stepIndex;
    final isCurrent = _currentStep == stepIndex;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? AppColors.brandPink
                : (isDone ? AppColors.successGreen : AppColors.lightGrey),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.brandPink.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : AppColors.textMedium,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent ? AppColors.brandPink : AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int stepIndex) {
    final isPassed = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
        color: isPassed ? AppColors.successGreen : AppColors.lightGrey,
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep0ChooseService();
      case 1:
        return _buildStep1PickEvents();
      case 2:
        return _buildStep2Details();
      case 3:
        return _buildStep3Success();
      default:
        return const SizedBox();
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 0: Choose Service / Subcategory (Grouped by Category)
  // ---------------------------------------------------------------------------
  Widget _buildStep0ChooseService() {
    final venueProvider = context.watch<VenueProvider>();
    final categories =
        venueProvider.categories.where((c) => c.id != 'all').toList();

    if (venueProvider.isLoading && categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (context, catIdx) {
        final cat = categories[catIdx];
        final catSubcategories = venueProvider.subCategories
            .where((s) => s.categoryId == cat.id)
            .toList();

        if (catSubcategories.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Section Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.brandPink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${catSubcategories.length})',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Subcategory Cards under this Category
            ...catSubcategories.map((sub) {
              final isSelected = _selectedSubcategoryId == sub.id;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedSubcategoryId = sub.id;
                    _selectedSubcategoryName = sub.title;
                    _selectedCategoryName = cat.title;
                    _error = null;
                    // Instantly advance to Step 1 (Pick Event) like React!
                    _currentStep = 1;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brandPink.withOpacity(0.06)
                        : AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandPink
                          : AppColors.borderGrey,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          sub.imageUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 52,
                            height: 52,
                            color: AppColors.brandPink.withOpacity(0.1),
                            child: const Icon(Icons.room_service_outlined,
                                color: AppColors.brandPink, size: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sub.basePrice != null && sub.basePrice! > 0
                                  ? 'From PKR ${sub.basePrice!.toStringAsFixed(0)}'
                                  : 'Price on quotation',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.primaryGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textMedium),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Pick Wedding Events
  // ---------------------------------------------------------------------------
  Widget _buildStep1PickEvents() {
    final customerBookings = context.watch<CustomerBookingsProvider>();
    final events = customerBookings.weddingEvents;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service summary pill with "Change" option
          if (_selectedSubcategoryName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            size: 18, color: AppColors.primaryGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedCategoryName != null
                                ? '$_selectedCategoryName › $_selectedSubcategoryName'
                                : _selectedSubcategoryName!,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _currentStep = 0),
                    child: Text(
                      'Change',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandPink,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            'Which event is this booking for?',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You can select multiple wedding events if this service applies to several ceremonies.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
          ),
          const SizedBox(height: 14),

          if (events.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Column(
                children: [
                  const Icon(Icons.celebration_outlined,
                      size: 40, color: AppColors.brandPink),
                  const SizedBox(height: 10),
                  Text(
                    'No Wedding Events Yet',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your first wedding event (e.g. Mehndi, Baraat, Walima) to attach your booking.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: _openCreateEvent,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      'Create Wedding Event',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // List of Event Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final ev = events[index];
                final isSelected = _selectedEventIds.contains(ev.id);

                return InkWell(
                  onTap: () => _handleToggleEvent(ev),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandPink.withOpacity(0.06)
                          : AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.brandPink
                            : AppColors.borderGrey,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _resolveEventImage(ev),
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 52,
                              height: 52,
                              color: AppColors.brandPink.withOpacity(0.1),
                              child: const Icon(Icons.celebration_rounded,
                                  color: AppColors.brandPink, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ev.customLabel,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (ev.eventDate != null &&
                                      ev.eventDate!.isNotEmpty) ...[
                                    Text(
                                      '📅 ${ev.eventDate!.length >= 10 ? ev.eventDate!.substring(0, 10) : ev.eventDate}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    '${ev.bookingCount} Bookings',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          activeColor: AppColors.brandPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onChanged: (_) => _handleToggleEvent(ev),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
            // Add New Event Shortcut
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandPink,
                side: BorderSide(color: AppColors.brandPink.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: _openCreateEvent,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Add Another Event',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Booking Details
  // ---------------------------------------------------------------------------
  Widget _buildStep2Details() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Date Picker
          Text(
            'Event Date *',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 730)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          color: AppColors.brandPink, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select celebration date',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _selectedDate != null
                              ? AppColors.textDark
                              : AppColors.textLight,
                          fontWeight: _selectedDate != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down_rounded,
                      color: AppColors.textMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Guest Count Stepper
          Text(
            'Estimated Guests',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        color: AppColors.brandPink, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '$_guestCount Guests',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_guestCount > 25) {
                          setState(() => _guestCount -= 25);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline_rounded,
                          color: AppColors.brandPink),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _guestCount += 25);
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: AppColors.brandPink),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Special Requests & Notes
          Text(
            'Special Requests / Notes (Optional)',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'e.g. Preference for stage decor colors, dietary requirements, camera angles, timing...',
              hintStyle:
                  GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.cardWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.brandPink, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Success Confirmation
  // ---------------------------------------------------------------------------
  Widget _buildStep3Success() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.successGreen, size: 64),
            ),
            const SizedBox(height: 20),
            Text(
              'Booking Request Sent!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _createdCount > 1
                  ? '$_createdCount booking requests were created and assigned to your events.'
                  : 'Your booking request for ${_selectedSubcategoryName ?? 'this service'} has been submitted.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'View My Bookings',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Action Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.borderGrey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => setState(() => _currentStep--),
                child: Text(
                  'Back',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
              ),
              onPressed: _submitting ? null : _handlePrimaryButton,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 2 ? 'Submit Booking Request' : 'Continue',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePrimaryButton() {
    if (_currentStep == 0) {
      if (_selectedSubcategoryId == null) {
        setState(() => _error = 'Please pick a subcategory to continue.');
        return;
      }
      setState(() {
        _error = null;
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      if (_selectedEventIds.isEmpty) {
        setState(() => _error = 'Please select at least one wedding event.');
        return;
      }
      setState(() {
        _error = null;
        _currentStep = 2;
      });
    } else if (_currentStep == 2) {
      _submitBooking();
    }
  }
}
