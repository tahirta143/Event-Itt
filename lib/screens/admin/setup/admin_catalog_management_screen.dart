import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../widgets/custom_header/custom_header_widget.dart';
import 'admin_setup_category_screen.dart';
import 'admin_setup_subcategory_screen.dart';

class AdminCatalogManagementScreen extends StatefulWidget {
  final int initialTabIndex;
  const AdminCatalogManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AdminCatalogManagementScreen> createState() => _AdminCatalogManagementScreenState();
}

class _AdminCatalogManagementScreenState extends State<AdminCatalogManagementScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  @override
  void didUpdateWidget(AdminCatalogManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      setState(() => _currentIndex = widget.initialTabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catalog Setup',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _currentIndex,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPink,
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Categories')),
                      DropdownMenuItem(value: 1, child: Text('Sub-Categories')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _currentIndex = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: const [
              AdminSetupCategoryScreen(),
              AdminSetupSubcategoryScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
