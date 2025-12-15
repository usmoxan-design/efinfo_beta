import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // uuid paketini ishlatish tavsiya etiladi

const uuid = Uuid();

class TeamModel {
  final String id;
  String name;
  Color color; // Vizual farqlash uchun

  TeamModel({required this.name, Color? color, String? id})
      : id = id ?? uuid.v4(),
        color = color ?? _getRandomColor();

  static Color _getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(200) + 55,
      random.nextInt(200) + 55,
      random.nextInt(200) + 55,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': color.value,
      };

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['colorValue'] as int),
    );
  }
}