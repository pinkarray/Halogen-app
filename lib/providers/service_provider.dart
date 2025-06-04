import 'package:flutter/material.dart';

class ServiceProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _allServices = [
    {
      'title': 'Electric Fence',
      'status': 'No subscription',
      'isActive': false,
      'type': 'Physical Security Service',
      'icon': Icons.electric_bolt,
      'route': '/electric-fence',
    },
    
  ];

  String _searchQuery = '';

  List<Map<String, dynamic>> get allServices => _allServices;

  List<Map<String, dynamic>> get filteredServices {
    if (_searchQuery.isEmpty) return _allServices;
    return _allServices.where((s) =>
      s['title'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
