import 'dart:async';
import 'package:flutter/services.dart';

class ReadUtility {
  Future<String> loadAsset(String address) async {
    return await rootBundle.loadString(address);
  }
}
