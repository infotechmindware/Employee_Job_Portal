import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _baseUrl = 'https://countriesnow.space/api/v0.1/countries';

  /// Fetch all countries
  static Future<List<String>> getCountries() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          final List countries = data['data'];
          return countries.map((c) => c['country'].toString()).toList();
        }
      }
    } catch (e) {
      print('❌ Error fetching countries: $e');
    }
    return [];
  }

  /// Fetch states by country using GET
  static Future<List<String>> getStates(String country) async {
    final cleanCountry = country.trim();
    if (cleanCountry.isEmpty) return [];
    
    try {
      final url = 'https://countriesnow.space/api/v0.1/countries/states/q?country=$cleanCountry';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null && data['data']['states'] != null) {
          final List statesData = data['data']['states'];
          return statesData.map((e) => e['name'].toString()).toList();
        }
      }
    } catch (e) {
      print('❌ ERROR in getStates: $e');
    }
    return [];
  }

  /// Fetch cities by country and state using GET
  static Future<List<String>> getCities(String country, String state) async {
    final cleanCountry = country.trim();
    final cleanState = state.trim();
    if (cleanCountry.isEmpty || cleanState.isEmpty) return [];

    try {
      final url = 'https://countriesnow.space/api/v0.1/countries/state/cities/q?country=$cleanCountry&state=$cleanState';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          final List citiesData = data['data'];
          return citiesData.map((e) => e.toString()).toList();
        }
      }
    } catch (e) {
      print('❌ CITY ERROR in getCities: $e');
    }
    return [];
  }
}
