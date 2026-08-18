import 'package:flutter/material.dart';
import '../../models/dashboard/dashboard_stat_model.dart';
import '../../models/service/service_model.dart';
import '../../utils/mock_data/mock_data.dart';

class DashboardProvider extends ChangeNotifier {
  final List<DashboardStatModel> _stats = List.from(MockData.stats);
  final List<ServiceModel> _services = List.from(MockData.services);

  List<DashboardStatModel> get stats => _stats;
  List<ServiceModel> get services => _services;
}
