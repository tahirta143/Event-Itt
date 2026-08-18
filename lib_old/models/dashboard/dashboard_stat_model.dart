import 'package:flutter/material.dart';

class DashboardStatModel {
  final String title;
  final String value;
  final String changePercentage;
  final bool isPositive;
  final IconData icon;

  DashboardStatModel({
    required this.title,
    required this.value,
    required this.changePercentage,
    required this.isPositive,
    required this.icon,
  });
}
