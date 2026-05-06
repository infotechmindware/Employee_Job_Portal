import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _rootUrl = 'https://countriesnow.space/api/v0.1/countries';

  static Future<List<String>> getCountries() async {
    try {
      final response = await http.get(Uri.parse(_rootUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          final List countries = data['data'];
          return countries.map((c) => c['country'].toString()).toList();
        }
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
    return [];
  }

  static Future<List<String>> getStates(String country) async {
    final cleanCountry = country.trim();
    if (cleanCountry.isEmpty) return [];
    
    print('🚀 Fetching states for: "$cleanCountry"');
    try {
      final response = await http.post(
        Uri.parse('https://countriesnow.space/api/v0.1/countries/states'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'country': cleanCountry}),
      );
      
      print('BODY: ${response.body}');
      print('STATUS CODE: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null && data['data']['states'] != null) {
          final List statesData = data['data']['states'];
          print('✅ States Loaded: ${statesData.length}');
          return statesData.map((e) => e['name'].toString()).toList();
        }
      } else {
        print('❌ Failed to load states: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR in getStates: $e');
    }
    return [];
  }

  static Future<List<String>> getCities(String country, String state) async {
    final cleanCountry = country.trim();
    final cleanState = state.trim();
    if (cleanCountry.isEmpty || cleanState.isEmpty) return [];

    print('🚀 Fetching cities for: "$cleanCountry / $cleanState"');
    try {
      final response = await http.post(
        Uri.parse('https://countriesnow.space/api/v0.1/countries/state/cities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'country': cleanCountry,
          'state': cleanState,
        }),
      );
      
      print('CITY STATUS: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          final List citiesData = data['data'];
          print('✅ Cities Loaded: ${citiesData.length}');
          return citiesData.map((e) => e.toString()).toList();
        }
      } else {
        print('❌ Failed to load cities: ${response.body}');
      }
    } catch (e) {
      print('❌ CITY ERROR in getCities: $e');
    }
    return [];
  }
}
