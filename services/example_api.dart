import 'dart:convert';

import 'response_model.dart';
import 'api.dart';

abstract class ExampleApi extends Api<ResponseModel> {
  ExampleApi() : super('https://example.com/');
}

class ResponseModelApi extends ExampleApi {
  @override
  ResponseModel parsedJson(String responseBody) {
    final Map<String, dynamic> parsed = jsonDecode(responseBody);
    return ResponseModel.fromJson(parsed);
  }
}

class DataModelApi extends ExampleApi {
  @override
  DataModel parsedJson(String responseBody) {
    final Map<String, dynamic> parsed = jsonDecode(responseBody);
    return DataModel.fromJson(parsed);
  }
}
