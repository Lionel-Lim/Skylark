import 'package:cached_network_image/cached_network_image.dart';
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

Future<List<CachedNetworkImage>> fetchImg(result) async {
  List<CachedNetworkImage> photos = [];
  for (var item in result) {
    // https://img.icons8.com/ios-filled/2x/no-image.png
    if (item.photos.length > 0) {
      photos
          .add(await APIService().getPhoto(item.photos[0]["photo_reference"]));
    } else {
      photos.add(await APIService().getPhoto(""));
    }
  }
  return photos;
}

Widget buildGridView(
    List<PlacesModel> result, List<CachedNetworkImage> photos) {
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

Widget buildNumber(PlacesModel item, CachedNetworkImage photo) {
  return Container(
    child: Column(
      children: [
        photo,
        Text(item.name),
      ],
    ),
    // padding: const EdgeInsets.all(16),
    // decoration: BoxDecoration(
    //     image: DecorationImage(
    //   image: photo,
    //   fit: BoxFit.cover,
    // )),
    // color: Colors.orange,
    // child: Center(
    //   child: Text(item.name),
    // ),
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
            child: FutureBuilder<List<CachedNetworkImage>>(
              future: fetchImg(widget.result),
              builder: (context, snapshot) {
                print("result : ${widget.result}");
                if (snapshot.hasData) {
                  print("future builder");
                  print(snapshot.data);
                  return buildGridView(widget.result, snapshot.data!);
                  // return const Text("data");
                } else {
                  return Text("failed: ${snapshot.error}");
                }
              },
            ),
            // child: buildGridView(widget.result),
          ),
        ],
      ),
    );
  }
}
