import 'package:flutter/material.dart';

/// Shared state model passed through all 5 wizard steps
class PostJobModel extends ChangeNotifier {
  // Step 1 — Basics
  String jobTitle = '';
  String industry = '';
  String employmentType = '';
  String country = '';
  String state = '';
  String city = '';
  int openings = 1;
  String workplaceType = '';
  String address = '';

  // Step 2 — Details
  String jobLanguage = 'English';
  String experience = '';
  String hiringUrgency = '';
  String jobTimings = '';
  String interviewTimings = '';

  // Step 3 — Pay & Benefits
  String salaryType = 'Range'; // Range / Fixed / Negotiable
  String minSalary = '';
  String maxSalary = '';
  String fixedSalary = '';
  String salaryFrequency = 'Monthly';
  bool hasBonus = false;
  List<String> benefits = [];
  List<String> skills = [];

  // Step 4 — Description
  String description = '';
  List<String> qualifications = [];

  void notify() => notifyListeners();

  Map<String, dynamic> toJson() {
    return {
      'title': jobTitle,
      'description': description,
      'industry': industry,
      'employment_type': employmentType.toLowerCase().replaceAll(' ', '_'),
      'workplace_type': workplaceType.toLowerCase(),
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'vacancies': openings,
      'experience_level': experience,
      'salary_min': double.tryParse(minSalary) ?? 0,
      'salary_max': double.tryParse(maxSalary) ?? 0,
      'fixed_salary': double.tryParse(fixedSalary) ?? 0,
      'salary_type': salaryType.toLowerCase(),
      'salary_frequency': salaryFrequency.toLowerCase(),
      'currency': 'INR', // Default as per requirements
      'skills': skills,
      'benefits': benefits,
      'language': jobLanguage,
      'urgency': hiringUrgency,
    };
  }

  void prefill(Map<String, dynamic> data) {
    jobTitle = data['title'] ?? '';
    industry = data['industry'] ?? '';
    employmentType = data['employment_type'] ?? '';
    country = data['country'] ?? '';
    state = data['state'] ?? '';
    city = data['city'] ?? '';
    openings = data['vacancies'] ?? 1;
    workplaceType = data['workplace_type'] ?? '';
    address = data['address'] ?? '';
    
    jobLanguage = data['language'] ?? 'English';
    experience = data['experience_level'] ?? '';
    hiringUrgency = data['urgency'] ?? '';
    jobTimings = data['job_timings'] ?? '';
    interviewTimings = data['interview_timings'] ?? '';
    
    salaryType = data['salary_type']?.toString().toUpperCase() == 'FIXED' ? 'Fixed' : 'Range';
    minSalary = data['salary_min']?.toString() ?? '';
    maxSalary = data['salary_max']?.toString() ?? '';
    fixedSalary = data['fixed_salary']?.toString() ?? '';
    salaryFrequency = data['salary_frequency'] ?? 'Monthly';
    
    skills = List<String>.from(data['skills'] ?? []);
    benefits = List<String>.from(data['benefits'] ?? []);
    description = data['description'] ?? '';
    
    notify();
  }
}
