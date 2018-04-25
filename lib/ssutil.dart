import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

typedef T FromJsonFactory<T>(Map<String, dynamic> json);

class Api {
  String auth;
  bool logging = false;

  Future<http.Response> get(String url, {Map<String, String> headers}) async {
    Map<String, String> h = headers ?? {};
    if (auth != null) {
      h[HttpHeaders.AUTHORIZATION] = auth;
    }

    final response = await http.get(url, headers: h);

    if (response.statusCode != 200) {
      logHttpResponseError(response);
      throw HttpException(response);
    }

    if (logging) {
      print("HTTP Response:");
      print(responseToString(response));
    }

    return response;
  }

  Future<List<T>> getList<T>(String url, FromJsonFactory<T> fromJsonFactory) async {
    final response = await get(url);
    return decodeJsonList(response.body, fromJsonFactory);
  }

  Future<T> getObject<T>(String url, FromJsonFactory<T> fromJsonFactory) async {
    final response = await get(url);
    final Map<String, dynamic> jsonObject = json.decode(response.body);
    return fromJsonFactory(jsonObject);
  }

  void setAuth(String authToken) {
    this.auth = authToken;
  }
}

class HttpException implements Exception {
  final http.Response response;

  HttpException(this.response);

  String toString() {
    return responseToString(response);
  }

  log() {
    print(toString());
  }
}

List<T> convertJsonList<T>(List<dynamic> jsonListParsed, FromJsonFactory<T> fromJsonFactory) {
  List tmp = [];
  for (var jsonObject in jsonListParsed) {
    T o = fromJsonFactory(jsonObject);
    tmp.add(o);
  }
  return new List.from(tmp);
}

List<T> decodeJsonList<T>(String jsonListUnparsed, FromJsonFactory<T> fromJsonFactory) {
  final List<dynamic> jsonListParsed = json.decode(jsonListUnparsed);
  return convertJsonList(jsonListParsed, fromJsonFactory);
}

String responseToString(http.Response response) {
  return """url: ${response.request.url}
        responseStatus: ${response.statusCode}
        responsebody: ${response.body}
        """;
}

logHttpResponseError(response) {
  print("HTTP Response Error:");
  print(responseToString(response));
}

String createBasicAuthToken(String userName, String password) {
  String authRaw = "$userName:$password";
  Uint8List u = utf8.encode(authRaw);
  String b = base64.encode(u);
  return "Basic $b";
}

bool isMissing(String s) {
  if (s == null) return true;
  if (s.trim().isEmpty) return true;
  return false;
}

String nullNormalize(String s) {
  if (s == null) return null;
  if (s.trim().isEmpty) return null;
  return s.trim();
}
