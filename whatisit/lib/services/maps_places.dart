import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:whatisit/models/places_model.dart';
import 'package:whatisit/services/read_utility.dart';

class APIService {
  late dynamic apiKeys;

  List<PlacesModel> searchResult = [];
  final String baseURL =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=";

  Future<List<PlacesModel>> searchPlaces({
    required LatLng coorinates,
    required double radius,
    List<String> types = const ['establishment'],
  }) async {
    apiKeys =
        jsonDecode(await ReadUtility().loadAsset('assets/APIKeys.json'))[0];
    final url = Uri.parse(
        "$baseURL${coorinates.latitude}%2C${coorinates.longitude}&radius=$radius&type=$types&key=${apiKeys["GoogleMaps"]}");
    final response = await http.get(url);
    // print(jsonDecode(response.body)["results"]);
    if (response.statusCode == 200) {
      for (var webtoon in jsonDecode(response.body)["results"].sublist(1)) {
        // print(webtoon);
        searchResult.add(PlacesModel.fromJson(webtoon));
      }
      print(searchResult);
      return searchResult;
    }
    print(response.body);
    throw Error();
  }
}
