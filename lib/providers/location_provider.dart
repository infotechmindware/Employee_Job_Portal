import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  List<String> countries = [];
  List<String> states = [];
  List<String> cities = [];

  bool isLoadingCountries = false;
  bool isLoadingStates = false;
  bool isLoadingCities = false;

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  Future<void> fetchCountries() async {
    isLoadingCountries = true;
    notifyListeners();

    countries = await LocationService.getCountries();
    
    isLoadingCountries = false;
    notifyListeners();
  }

  Future<void> onCountryChanged(String? country) async {
    selectedCountry = country;
    selectedState = null;
    selectedCity = null;
    states = [];
    cities = [];
    
    if (country != null) {
      isLoadingStates = true;
      notifyListeners();
      
      states = await LocationService.getStates(country);
      
      isLoadingStates = false;
    }
    notifyListeners();
  }

  Future<void> onStateChanged(String? state) async {
    selectedState = state;
    selectedCity = null;
    cities = [];
    
    if (selectedCountry != null && state != null) {
      isLoadingCities = true;
      notifyListeners();
      
      cities = await LocationService.getCities(selectedCountry!, state);
      
      isLoadingCities = false;
    }
    notifyListeners();
  }

  void onCityChanged(String? city) {
    selectedCity = city;
    notifyListeners();
  }
}
