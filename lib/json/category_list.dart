//items not in list counted as 'others'
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

List<List<String>> categoryList = [
  ['food', 'meal', 'bakery', 'bar', 'cafe', 'restaurant'],
  ['beauty', 'beauty_salon', 'hair_care'],
  ['supermarket'],
  ['shopping', 'store', 'florist'],
  [
    'entertainment',
    'movie',
    'art_gallery',
    'bowling_alley',
    'casino',
    'night_club'
  ],
  [
    'health',
    'dentist',
    'doctor',
    'hospital',
    'pharmacy',
    'physiotherapist',
    'spa'
  ],
  ['transport', 'car', 'subway_station', 'bus_station', 'taxi_stand', 'parking']
];

final List<String> categoryItems = [
  'Food',
  'Beauty',
  'Supermarket',
  'Shopping',
  'Entertainment',
  'Health',
  'Transport',
  'Others'
];

final List<String> categoryItemsWithWarranty = [
  'Warranty',
  'Food',
  'Beauty',
  'Supermarket',
  'Shopping',
  'Entertainment',
  'Health',
  'Transport',
  'Others'
];

IconData getIcon(String category) {
  switch (category) {
    case 'Warranty':
      return IconlyBold.paper;
    case 'Food':
      return Icons.fastfood;
    case 'Beauty':
      return CupertinoIcons.house_fill;
    case 'Supermarket':
      return Icons.store;
    case 'Shopping':
      return Icons.shopping_cart;
    case 'Entertainment':
      return Icons.movie;
    case 'Health':
      return Icons.health_and_safety;
    case 'Transport':
      return Icons.directions_bus;
  }
  return Icons.more_horiz;
}

Color getIconColor(String category) {
  switch (category) {
    case 'Warranty':
      return const Color.fromARGB(255, 95, 92, 89);
    case 'Food':
      return const Color.fromARGB(255, 190, 136, 70);
    case 'Beauty':
      return const Color(0xFFFF736C);
    case 'Supermarket':
      return const Color.fromARGB(255, 105, 100, 157);
    case 'Shopping':
      return const Color.fromARGB(255, 83, 118, 53);
    case 'Entertainment':
      return const Color.fromARGB(255, 58, 132, 188);
    case 'Health':
      return const Color.fromARGB(255, 207, 186, 66);
    case 'Transport':
      return const Color.fromARGB(255, 111, 61, 108);
  }
  return const Color.fromARGB(255, 0, 0, 0);
}
