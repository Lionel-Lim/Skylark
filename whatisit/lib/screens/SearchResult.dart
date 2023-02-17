import 'package:flutter/material.dart';
import 'package:whatisit/models/places_model.dart';
import 'package:whatisit/services/maps_places.dart';

class SearchResult extends StatefulWidget {
  final List<PlacesModel> result;
  const SearchResult(this.result, {super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

final numbers = List.generate(50, (index) => "$index");

dynamic fetchImg(result) async {
  final photos = [];
  for (var item in result) {
    photos.add(APIService().getPhoto(item.photos[0]["photo_reference"]));
  }
  return photos;
}

Future<Widget> buildGridView(List<PlacesModel> result) async {
  final photos = await fetchImg(result);
  return SizedBox(
    height: 500,
    child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: result.length,
        itemBuilder: (context, index) {
          final item = result[index];
          final photo = photos[index];
          return buildNumber(item, photo);
        }),
  );
}

Widget buildNumber(PlacesModel item, dynamic photo) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        image: DecorationImage(
      image: photo,
      fit: BoxFit.cover,
    )),
    color: Colors.orange,
    child: Center(
      child: Text(item.name),
    ),
  );
}

class _SearchResultState extends State<SearchResult> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 30,
          ),
          const Text(
            " Search Result",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 30,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: buildGridView(widget.result),
          ),
        ],
      ),
    );
  }
}
