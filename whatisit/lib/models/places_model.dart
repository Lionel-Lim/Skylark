class PlacesModel {
  final Map<String, dynamic> geometry;
  final String icon, placeId, reference, vicinity, name;
  final List<dynamic> types, photos;
  final int userRating;

  PlacesModel.fromJson(Map<String, dynamic> json)
      : geometry = json["geometry"],
        icon = json["icon"],
        photos = json["photos"] ?? [],
        placeId = json["place_id"],
        reference = json["reference"],
        types = json["types"],
        vicinity = json["vicinity"],
        name = json["name"],
        userRating = json["user_ratings_total"] ?? 0;
}
