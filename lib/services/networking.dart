import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Networking{
  String baseUrl ="https://api2.branch.io";
  Future postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    Uri url = Uri.parse(baseUrl + endpoint);
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    try{
      http.Response response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 59));
      String data = response.body;
      var jsonDecoded = jsonDecode(data);
      return jsonDecoded;
    }on SocketException catch (e) {
      throw "No Internet connection";
    }catch(e){
      print(e);
      rethrow;
    }
  }
}