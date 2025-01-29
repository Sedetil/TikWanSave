import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, String>?> fetchDownloadLinks(String url) async {
    try {
      final apiUrl = "https://www.tikwm.com/api/?url=$url&hd=1";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "video": data["data"]["play"],
          "audio": data["data"]["music"],
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}