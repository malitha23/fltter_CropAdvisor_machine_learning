import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:agriculture/screens/getCropsWithSimilarSoilType.dart';
import 'package:agriculture/screens/selectedcropviewpage.dart';
import 'package:agriculture/services/favorites_manager.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  final String tokenVal;

  const FavoritesScreen({Key? key, required this.tokenVal}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Crop> favoriteCrops = [];
  bool isLoading = true;
  Uint8List defaultImageBytes = Uint8List(0);

  void _setDefaultImage() async {
    final ByteData data = await rootBundle.load('assets/images/noimage.jpg');
    defaultImageBytes = data.buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _setDefaultImage();
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch the crops
      List<Crop> fetchedCrops =
          await FavoritesManager.loadFavorites(widget.tokenVal);

      // Debugging line
      print('Fetched crops: $fetchedCrops');

      // Update each crop's isFavorite property to true
      fetchedCrops.forEach((crop) {
        print(
            'Crop name: ${crop.cropName}, original isFavorite: ${crop.isFavorite}'); // Debugging line
        crop.isFavorite = true; // Set isFavorite to true
      });

      setState(() {
        favoriteCrops = fetchedCrops;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshFavorites() async {
    print('Refreshing favorites'); // Debugging line
    await _loadFavorites();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _toggleFavorite(Crop crop) async {
    String? token = await getToken();

    // Toggle the favorite status locally
    setState(() {
      crop.isFavorite = !crop.isFavorite;
    });

    // Save the updated favorite status
    try {
      await FavoritesManager.saveFavorite(
          crop, crop.isFavorite, token.toString());

      // Optionally, update the list of favorites after toggling
      if (!crop.isFavorite) {
        // If the crop is no longer a favorite, remove it from the list
        setState(() {
          favoriteCrops.removeWhere((c) => c.id == crop.id);
        });
      }
      // You might want to re-fetch the list to ensure it's up-to-date
      // await _loadFavorites(); // Uncomment if needed
    } catch (e) {
      print('Error toggling favorite status: $e');
      // Optionally, revert the local change if the server update fails
      setState(() {
        crop.isFavorite = !crop.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Crops'),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromRGBO(5, 183, 119, 1),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : favoriteCrops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No favorites added',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                        SizedBox(height: 16), // Space between text and button
                        ElevatedButton(
                          onPressed: _refreshFavorites,
                          child: Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color.fromRGBO(5, 183, 119, 1),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: (favoriteCrops.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      final startIndex = index * 2;
                      final endIndex = startIndex + 2;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: favoriteCrops
                              .sublist(
                                  startIndex,
                                  endIndex < favoriteCrops.length
                                      ? endIndex
                                      : favoriteCrops.length)
                              .map((crop) => Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SelectedCropPage(crop: crop),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            crop.decodedMainImage != null &&
                                                    crop.decodedMainImage!
                                                        .isNotEmpty
                                                ? Image.memory(
                                                    crop.decodedMainImage!,
                                                    fit: BoxFit.fitWidth,
                                                  )
                                                : Image.memory(
                                                    defaultImageBytes,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                            const SizedBox(height: 8),
                                            Text(
                                              crop.cropName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(crop.lifeCycleDescription),
                                            const SizedBox(height: 8),
                                            IconButton(
                                              icon: Icon(
                                                crop.isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: crop.isFavorite
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              onPressed: () {
                                                _toggleFavorite(crop);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
