import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:llm/llm.dart';

Future<List<AIModel>> fetchModels(
  String url,
  Map<String, String> headers,
) async {
  late http.Response response;
  response = await http.get(Uri.parse(url), headers: headers);
  if (response.statusCode == 405) {
    response = await http.post(Uri.parse(url), headers: headers);
  }

  if (response.statusCode == 200) {
    final List<dynamic> modelsJson = jsonDecode(response.body);
    List<AIModel> models = modelsJson
        .map((model) => AIModel.fromJson(model))
        .toList();
    return models;
  } else {
    throw Exception('Failed to load models');
  }
}
