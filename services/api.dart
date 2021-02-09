import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'exception.dart';

abstract class Api<T> {
  final String _baseUrl;

  Api(this._baseUrl);

  Future<T> post(String url, Map<String, dynamic> body) async {
    try {
      final http.Response response = await http.post(
        _baseUrl + url,
        headers: {"Content-Type": 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      _throwException(response);

      print(response.body);
      return parsedJson(response.body);
    } on SocketException {
      throw FetchDataException('No Internet connection!');
    }
  }

  Future<T> multiPart(
    String url,
    Map<String, dynamic> body,
    Map<String, String> fileMap,
  ) async {
    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(_baseUrl + url),
      )..fields['data'] = jsonEncode(body);

      for (MapEntry e in fileMap.entries) {
        request.files.add(await http.MultipartFile.fromPath(e.key, e.value));
      }

      final http.StreamedResponse response = await request.send();
      final String responseBody = await response.stream.bytesToString();

      _throwMultipartException(response);

      print(responseBody);
      return parsedJson(responseBody);
    } on SocketException {
      throw FetchDataException('No Internet connection!');
    }
  }

  T parsedJson(String responseBody);

  void _throwException(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return;

      case 400:
        throw BadRequestException(response.body);

      case 401:
      case 403:
        throw UnauthorisedException(response.body);

      default:
        throw FetchDataException('${response.statusCode}');
    }
  }

  void _throwMultipartException(http.StreamedResponse response) {
    switch (response.statusCode) {
      case 200:
        return;

      case 400:
        throw BadRequestException(response.reasonPhrase);

      case 401:
      case 403:
        throw UnauthorisedException(response.reasonPhrase);

      default:
        throw FetchDataException('${response.statusCode}');
    }
  }
}
