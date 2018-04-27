import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

typedef T FromJsonFactory<T>(Map<String, dynamic> json);

class Api {
  bool logging = false;

  Future<http.Response> get(String url, {Map<String, String> headers}) async {
    Map<String, String> h = headers ?? {};

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
}

class HttpException implements Exception {
  final http.Response response;

  HttpException(this.response);

  String toString() {
    return responseToString(response);
  }

  int get statusCode => response.statusCode;

  log() {
    print(toString());
  }
}

List<T> convertJsonList<T>(List<dynamic> jsonListParsed, FromJsonFactory<T> fromJsonFactory) {
  List<T> tmp = [];
  for (var jsonObject in jsonListParsed) {
    T o = fromJsonFactory(jsonObject);
    tmp.add(o);
  }
  return tmp;
}

List<T> decodeJsonList<T>(String jsonListText, FromJsonFactory<T> fromJsonFactory) {
  final List<dynamic> jsonListParsed = json.decode(jsonListText);
  return convertJsonList(jsonListParsed, fromJsonFactory);
}

String responseToString(http.Response response) {
  return """url: ${response.request.url}
        responseStatus: ${response.statusCode}
        responseHeaders: ${response.headers}
        responsebody: ${response.body}
        """;
}

logHttpResponseError(response) {
  print("HTTP Response Error:");
  print(responseToString(response));
}

logError(Object err, String title) {
  final String effectiveTitle = title ?? "An error occurred";
  debugPrint(effectiveTitle);
  if (err == null) {
    debugPrint("Error object was null");
  } else {
    debugPrint(err.toString());
    debugPrint(err.runtimeType == null ? err.runtimeType.toString() : "No runtimeType");
    if (err is Error) {
      final StackTrace trace = err.stackTrace;
      if (trace != null) {
        debugPrint(err.stackTrace.toString());
      } else {
        debugPrint("No stackTrace");
      }
    }
  }
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

bool isValidEmail(String email) {
  RegExp emailRegExp = new RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
  return emailRegExp.hasMatch(email.toLowerCase());
}
