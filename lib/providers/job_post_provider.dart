import 'package:flutter/material.dart';
import '../services/job_service.dart';

class JobPostProvider extends ChangeNotifier {
  List<String> titleSuggestions = [];
  List<String> skillSuggestions = [];
  
  bool isSearchingTitles = false;
  bool isSearchingSkills = false;
  
  String? errorMessage;

  Future<List<String>> searchJobTitles(String query) async {
    isSearchingTitles = true;
    errorMessage = null;
    notifyListeners();

    try {
      titleSuggestions = await JobService.getJobTitleSuggestions(query);
      isSearchingTitles = false;
      notifyListeners();
      return titleSuggestions;
    } catch (e) {
      isSearchingTitles = false;
      errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<String>> searchSkills({
    required String query,
    required String title,
    required String category,
  }) async {
    isSearchingSkills = true;
    errorMessage = null;
    notifyListeners();

    try {
      skillSuggestions = await JobService.getSkillSuggestions(
        query: query,
        title: title,
        category: category,
      );
      isSearchingSkills = false;
      notifyListeners();
      return skillSuggestions;
    } catch (e) {
      isSearchingSkills = false;
      errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  void clearSuggestions() {
    titleSuggestions = [];
    skillSuggestions = [];
    notifyListeners();
  }
}
