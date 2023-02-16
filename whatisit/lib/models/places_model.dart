class PlacesModel {
  final Map<String, dynamic> geometry;
  final String icon, placeId, reference, vicinity;
  final List<dynamic> types, photos;

  PlacesModel.fromJson(Map<String, dynamic> json)
      : geometry = json["geometry"],
        icon = json["icon"],
        photos = json["photos"] ?? [],
        placeId = json["place_id"],
        reference = json["reference"],
        types = json["types"],
        vicinity = json["vicinity"];
}