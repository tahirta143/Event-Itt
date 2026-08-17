# Color Theme Alignment Plan

Align the app's color usage with the brand palette defined in `AppColors`, specifically targeting the hardcoded blue (`0xFF1565C0`) and other non-standard colors in the Drawer and other screens.

## User Review Required

> [!IMPORTANT]
> The hardcoded blue (`0xFF1565C0`) currently used for "Vendor" roles and "In Progress" statuses will be replaced with `AppColors.primaryGold` to maintain a consistent luxury theme.

> [!NOTE]
> All hardcoded green (`0xFF2E7D32`) values will be replaced with the existing `AppColors.successGreen` constant.

## Proposed Changes

### [Component Name] Widgets & UI

#### [MODIFY] [custom_drawer_widget.dart](file:///D:/Eventtt/Eventitt/eventitt%20app/lib/widgets/custom_drawer/custom_drawer_widget.dart)
- Replace hardcoded blue (`0xFF1565C0`) with `AppColors.primaryGold` for the Vendor badge.
- Replace hardcoded green (`0xFF2E7D32`) with `AppColors.successGreen` for the Customer badge.
- Use `AppColors.textWhite.withOpacity(0.7)` instead of `Colors.white70`.

#### [MODIFY] [admin_bookings_screen.dart](file:///D:/Eventtt/Eventitt/eventitt%20app/lib/screens/admin/admin_bookings_screen.dart)
- Update `_statusColor` to use `AppColors` constants.
- Replace blue (`0xFF1565C0`) with `AppColors.primaryGold`.
- Replace purple (`0xFF6A1B9A`) with `AppColors.brandPink`.

#### [MODIFY] [admin_dashboard_screen.dart](file:///D:/Eventtt/Eventitt/eventitt%20app/lib/screens/admin/admin_dashboard_screen.dart)
- Replace all hardcoded hex color values with `AppColors` references.

#### [MODIFY] [vendor_home_screen.dart](file:///D:/Eventtt/Eventitt/eventitt%20app/lib/screens/vendor/vendor_home_screen.dart)
- Replace blue icons and containers with `AppColors.primaryGold`.

## Verification Plan

### Manual Verification
- Open the Drawer as an Admin, Vendor, and Customer to verify the badge colors.
- Navigate to Booking screens to verify the status colors.
- Check the Vendor Home screen for consistent use of Gold instead of Blue.
