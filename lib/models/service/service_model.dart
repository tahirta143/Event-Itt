import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String startingPrice;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.startingPrice,
    required this.imageUrl,
  });
}
