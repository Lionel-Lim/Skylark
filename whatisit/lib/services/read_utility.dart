import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class ReadUtility {
  Future<String> loadAsset(String address) async {
    return await rootBundle.loadString(address);
  }

  Map<String, dynamic> decodeJson(String json) {
    return jsonDecode(json);
  }
}
