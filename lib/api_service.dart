import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('https://api.mockfly.dev/mocks/386eeb6f-a7ae-4246-ad90-acd5625d0dad/posts'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
