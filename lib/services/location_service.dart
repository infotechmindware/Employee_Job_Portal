import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _baseUrl = 'https://countriesnow.space/api/v0.1/countries';

  static Future<List<String>> getCountries() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data'].map((c) => c['country']));
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
    return [];
  }

  static Future<List<String>> getStates(String country) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/states'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'country': country}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data']['states'].map((s) => s['name']));
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
    return [];
  }

  static Future<List<String>> getCities(String country, String state) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/state/cities'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'country': country, 'state': state}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data']);
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
    return [];
  }
}
