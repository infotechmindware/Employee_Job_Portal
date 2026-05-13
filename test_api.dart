import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  var url = 'https://www.mindwareinfotech.com/api/v1/employer/messages';
  // Try another url if this fails
  // First we need a token or we just test the 401 response
  var response = await http.get(Uri.parse(url));
  print(response.statusCode);
  print(response.body);
}
