import 'dart:convert';
import 'dart:typed_data';
import 'package:agriculture/screens/selectedcropviewpage.dart';
import 'package:agriculture/services/favorites_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class getCropsWithSimilarSoilType extends StatefulWidget {
  final String soilType;

  const getCropsWithSimilarSoilType({Key? key, required this.soilType})
      : super(key: key);

  @override
  State<getCropsWithSimilarSoilType> createState() =>
      _getCropsWithSimilarSoilTypeState();
}

class _getCropsWithSimilarSoilTypeState
    extends State<getCropsWithSimilarSoilType> {
  List<Crop> crops = [];
  List<Crop> originalcrops = [];
  bool isLoading = false;
  Uint8List defaultImageBytes = Uint8List(0);
  bool filterloader = false;

  // Controllers for filter input fields
  final TextEditingController cropNameController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController selectedSeasonController =
      TextEditingController();
  final TextEditingController selectedWateringCycleController =
      TextEditingController();

  void _setDefaultImage() async {
    final ByteData data = await rootBundle.load('assets/images/noimage.jpg');
    defaultImageBytes = data.buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();
    _fetchCrops();
    _setDefaultImage();
  }

  String selectedSeasons = "December-February";
  String selectedZone = "dry";
  String selectedCycle = "daily";

  final List<String> zones = ["dry", "wet", "intermediate"];

  final List<String> seasons = [
    "December-February",
    "March-May",
    "June-August",
    "September-November",
  ];

  final List<String> soilTypes = [
    "Reddish Brown Earths soil",
    "red soil",
    "clay soil",
    "black soil",
    "Alluvial soil"
  ];
  String selectedSoilType = "Reddish Brown Earths soil";
  final List<String> cycles = ["daily", "weekly"];

  String sanitizeJson(String jsonString) {
    // Replace problematic escape sequences if needed
    return jsonString.replaceAll(r'\/', '/');
  }

  Future<void> _fetchCrops() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await getToken();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/getCropsWithSimilarSoilType'),
        body: {'soilType': widget.soilType},
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // If the server returns a success response, parse the JSON
        String sanitizedResponse = sanitizeJson(response.body);
        final responseData = json.decode(sanitizedResponse);

        if (responseData is Map && responseData.containsKey('data')) {
          List<dynamic> jsonData = responseData['data'];
          setState(() {
            crops = jsonData.map((data) => Crop.fromJson(data)).toList();
            originalcrops =
                jsonData.map((data) => Crop.fromJson(data)).toList();
          });
        } else {
          // Handle case when response data is missing or not in the expected format
          print('Unexpected response format: $responseData');
        }
      } else {
        // If the server did not return a success response, throw an exception
        throw Exception('Failed to load crops: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      // Handle errors
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Uint8List decodeImage(String base64String) {
    // Remove the data prefix if it exists
    if (base64String.startsWith('data:')) {
      base64String = base64String.substring(base64String.indexOf(',') + 1);
    }

    // Decode the base64 string into bytes
    Uint8List bytes = base64Decode(base64String);

    return bytes;
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _toggleFavorite(Crop crop) async {
    String? token = await getToken();
    setState(() {
      crop.isFavorite = !crop.isFavorite;
    });

    // Save the updated favorite status
    await FavoritesManager.saveFavorite(
        crop, crop.isFavorite, token.toString());

    // Optionally, you might want to update the list of favorites after toggling
    // await _loadFavorites(); // Uncomment if needed
  }

  // Open filter bottom sheet
  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final sheetHeight =
            screenHeight * 0.75; // Set height to 75% of screen height

        return Container(
          height: sheetHeight,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Crops',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: cropNameController,
                    decoration: InputDecoration(labelText: 'Crop Name'),
                    onChanged: (value) {
                      setState(() {
                        filterloader = true;
                      });
                      crops = originalcrops;
                      List<Crop> filteredCrops = crops;

                      // Filter crops based on cropName
                      if (value.isNotEmpty) {
                        filteredCrops = filteredCrops
                            .where((crop) => crop.cropName == value)
                            .toList();
                      }
                      // Update the state with the filtered crops
                      setState(() {
                        crops = filteredCrops;
                        filterloader = false;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  if (widget.soilType == '')
                    DropdownButtonFormField<String>(
                      value: selectedSoilType,
                      onChanged: (value) {
                        setState(() {
                          filterloader = true;
                          selectedSoilType = value!;
                        });
                        crops = originalcrops;
                        List<Crop> filteredCrops = crops;

                        // Filter crops based on cropName
                        if (selectedSoilType.isNotEmpty) {
                          filteredCrops = filteredCrops
                              .where(
                                  (crop) => crop.soilType == selectedSoilType)
                              .toList();
                        }
                        // Update the state with the filtered crops
                        setState(() {
                          crops = filteredCrops;
                          filterloader = false;
                        });
                      },
                      items: soilTypes.map((soilType) {
                        return DropdownMenuItem<String>(
                          value: soilType,
                          child: Text(soilType),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Soil Type',
                        // Customize the dropdown style
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedZone,
                    onChanged: (value) {
                      setState(() {
                        filterloader = true;
                        selectedZone = value!;
                      });
                      crops = originalcrops;
                      List<Crop> filteredCrops = crops;

                      // Filter crops based on cropName
                      // Filter crops based on zone
                      if (selectedZone.isNotEmpty) {
                        filteredCrops = filteredCrops
                            .where((crop) => crop.zone == selectedZone)
                            .toList();
                      }
                      // Update the state with the filtered crops
                      setState(() {
                        crops = filteredCrops;
                        filterloader = false;
                      });
                    },
                    items: zones.map((zone) {
                      return DropdownMenuItem<String>(
                        value: zone,
                        child: Text(zone),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Zone',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedSeasons,
                    onChanged: (value) {
                      setState(() {
                        filterloader = true;
                        selectedSeasons = value!;
                      });
                      crops = originalcrops;
                      List<Crop> filteredCrops = crops;

                      // Filter crops based on cropName
                      if (selectedSeasons.isNotEmpty) {
                        filteredCrops = filteredCrops
                            .where((crop) =>
                                crop.selectedSeason == selectedSeasons)
                            .toList();
                      }
                      // Update the state with the filtered crops
                      setState(() {
                        crops = filteredCrops;
                        filterloader = false;
                      });
                    },
                    items: seasons.map((season) {
                      return DropdownMenuItem<String>(
                        value: season,
                        child: Text(season),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Seasons',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCycle,
                    onChanged: (value) {
                      setState(() {
                        filterloader = true;
                        selectedCycle = value!;
                      });
                      crops = originalcrops;
                      List<Crop> filteredCrops = crops;

                      // Filter crops based on cropName
                      if (selectedCycle.isNotEmpty) {
                        filteredCrops = filteredCrops
                            .where((crop) =>
                                crop.selectedWateringCycle == selectedCycle)
                            .toList();
                      }
                      // Update the state with the filtered crops
                      setState(() {
                        crops = filteredCrops;
                        filterloader = false;
                      });
                    },
                    items: cycles.map((cycle) {
                      return DropdownMenuItem<String>(
                        value: cycle,
                        child: Text(cycle),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Watering Cycle',
                      // Customize the dropdown style
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // setState(() {
                      //   crops = originalcrops;
                      // });
                      // _applyFilters();
                      Navigator.pop(context); // Close bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(
                          5, 183, 119, 1), // Set background color
                    ),
                    child: Text('Apply'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Apply filters
  void _applyFilters() {
    // List<Crop> filteredCrops = crops;

    // // Filter crops based on cropName
    // if (cropNameController.text.isNotEmpty) {
    //   filteredCrops = filteredCrops
    //       .where((crop) => crop.cropName == cropNameController.text)
    //       .toList();
    // }

    // // Filter crops based on zone
    // if (selectedZone.isNotEmpty) {
    //   filteredCrops =
    //       filteredCrops.where((crop) => crop.zone == selectedZone).toList();
    // }

    // // Filter crops based on selectedSeasons
    // if (selectedSeasons.isNotEmpty) {
    //   filteredCrops = filteredCrops
    //       .where((crop) => crop.selectedSeason == selectedSeasons)
    //       .toList();
    // }

    // // Filter crops based on selectedSeasons
    // if (selectedCycle.isNotEmpty) {
    //   filteredCrops = filteredCrops
    //       .where((crop) => crop.selectedWateringCycle == selectedCycle)
    //       .toList();
    // }

    // // Filter crops based on selectedSeasons
    // if (selectedSoilType.isNotEmpty) {
    //   filteredCrops = filteredCrops
    //       .where((crop) => crop.soilType == selectedSoilType)
    //       .toList();
    // }

    // // Update the state with the filtered crops
    // setState(() {
    //   crops = filteredCrops;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromRGBO(5, 183, 119, 1), // Set background color to white
        foregroundColor: Colors.white,
        title: Text(
          widget.soilType != ''
              ? 'Crops with : ${widget.soilType}'
              : 'All Crops',
          style: const TextStyle(
            color: Colors.white, // Set text color to black
            fontSize: 16, // Set font size to 16
          ),
        ),
      ),
      body: filterloader
          ? Center(
              child: LoadingAnimationWidget.stretchedDots(
                color: Color.fromRGBO(5, 183, 119, 1),
                size: 40,
              ),
            )
          : Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 217, 216, 216)
                            .withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    // Using Column instead of Stack
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // Make children full-width
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      if (!isLoading)
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                _openFilterBottomSheet();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        20), // Set left and right padding
                                backgroundColor: const Color.fromRGBO(
                                    5, 183, 119, 1), // Set background color
                              ),
                              child: const Text(
                                'Filter',
                                style: TextStyle(
                                    color: Colors
                                        .white), // Set text color to white
                              ),
                            )),
                      if (crops.isEmpty &&
                          !isLoading) // Display message when no crops are available
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'No data found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _fetchCrops();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            20), // Set left and right padding
                                    backgroundColor: const Color.fromRGBO(
                                        5, 183, 119, 1), // Set background color
                                  ),
                                  child: const Text(
                                    'Reload',
                                    style: TextStyle(
                                        color: Colors
                                            .white), // Set text color to white
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (crops.isNotEmpty && !isLoading)
                        Expanded(
                          // Expanded to occupy remaining space
                          child: ListView.builder(
                            itemCount: (crops.length / 2).ceil(),
                            itemBuilder: (context, index) {
                              final startIndex = index * 2;
                              final endIndex = startIndex + 2;
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: crops
                                      .sublist(
                                          startIndex,
                                          endIndex < crops.length
                                              ? endIndex
                                              : crops.length)
                                      .map((crop) => Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SelectedCropPage(
                                                            crop: crop),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8),
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
                                                    crop.decodedMainImage !=
                                                                null &&
                                                            crop.decodedMainImage!
                                                                .isNotEmpty
                                                        ? Image.memory(
                                                            crop.decodedMainImage!,
                                                            fit:
                                                                BoxFit.fitWidth,
                                                          )
                                                        : Image.memory(
                                                            defaultImageBytes,
                                                            fit:
                                                                BoxFit.fitWidth,
                                                          ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      crop.cropName,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(crop
                                                        .lifeCycleDescription),
                                                    const SizedBox(height: 8),
                                                    IconButton(
                                                      icon: Icon(
                                                        crop.isFavorite
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                        color: crop.isFavorite
                                                            ? Colors.red
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _toggleFavorite(crop);
                                                        });
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
                    ],
                  ),
                ),
                if (isLoading)
                  Center(
                    child: LoadingAnimationWidget.stretchedDots(
                      color: Color.fromRGBO(5, 183, 119, 1),
                      size: 40,
                    ),
                  ),
              ],
            ),
    );
  }
}

class Crop {
  Uint8List? decodedMainImage;
  List<Uint8List?> decodedSubImages;
  List<Uint8List?> decodedlifeCycleImagePaths;
  final int id;
  final String cropName;
  final String? mainImagePath;
  final List<String> subImagePaths;
  final String zone;
  final String soilType;
  final String selectedSeason;
  final String selectedWateringCycle;
  final String? weeklyOption;
  final String? timeOption;
  final String? dailyOption;
  final List<String> selectedDiseaseList;
  final String cropVariety;
  final String lifeCycleDescription;
  final List<String> lifeCycleImagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isFavorite;

  Crop({
    required this.id,
    required this.cropName,
    required this.mainImagePath,
    required this.subImagePaths,
    required this.zone,
    required this.soilType,
    required this.selectedSeason,
    required this.selectedWateringCycle,
    required this.weeklyOption,
    required this.timeOption,
    required this.dailyOption,
    required this.selectedDiseaseList,
    required this.cropVariety,
    required this.lifeCycleDescription,
    required this.lifeCycleImagePaths,
    required this.createdAt,
    required this.updatedAt,
    this.decodedMainImage,
    required this.decodedSubImages,
    required this.decodedlifeCycleImagePaths,
    this.isFavorite = false,
  });

  // Convert Crop object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'mainImagePath': mainImagePath,
      'subImagePaths': subImagePaths,
      'zone': zone,
      'soilType': soilType,
      'selectedSeason': selectedSeason,
      'selectedWateringCycle': selectedWateringCycle,
      'weeklyOption': weeklyOption,
      'timeOption': timeOption,
      'dailyOption': dailyOption,
      'selectedDiseaseList': selectedDiseaseList,
      'cropVariety': cropVariety,
      'lifeCycleDescription': lifeCycleDescription,
      'lifeCycleImagePaths': lifeCycleImagePaths,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  // Create Crop object from JSON
  factory Crop.fromJson(Map<String, dynamic> json) {
    String? mainImagePath = json['mainImagePath'];
    List<String> subImagePaths = List<String>.from(json['subImagePaths'] ?? []);
    List<Uint8List?> decodedSubImages = [];

    List<String> lifeCycleImages =
        List<String>.from(json['lifeCycleImagePaths'] ?? []);
    List<Uint8List?> decodedlifeCycleImages = [];

    Uint8List? decodedMainImage;

    if (mainImagePath != null) {
      decodedMainImage =
          base64Decode(mainImagePath.substring(mainImagePath.indexOf(',') + 1));
    }

    for (String imagePath in subImagePaths) {
      if (imagePath.isNotEmpty) {
        decodedSubImages
            .add(base64Decode(imagePath.substring(imagePath.indexOf(',') + 1)));
      } else {
        decodedSubImages.add(null);
      }
    }

    for (String imagePath in lifeCycleImages) {
      if (imagePath.isNotEmpty) {
        decodedlifeCycleImages
            .add(base64Decode(imagePath.substring(imagePath.indexOf(',') + 1)));
      } else {
        decodedlifeCycleImages.add(null);
      }
    }

    return Crop(
      id: json['id'] ?? 0,
      cropName: json['cropName'] ?? '',
      mainImagePath: json['mainImagePath'],
      subImagePaths: subImagePaths,
      zone: json['zone'] ?? '',
      soilType: json['soilType'] ?? '',
      selectedSeason: json['selectedSeason'] ?? '',
      selectedWateringCycle: json['selectedWateringCycle'] ?? '',
      weeklyOption: json['weeklyOption'],
      timeOption: json['timeOption'],
      dailyOption: json['dailyOption'] ?? '',
      selectedDiseaseList: List<String>.from(json['selectedDiseaseList'] ?? []),
      cropVariety: json['cropVariety'] ?? '',
      lifeCycleDescription: json['lifeCycleDescription'] ?? '',
      lifeCycleImagePaths: List<String>.from(json['lifeCycleImagePaths'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
      decodedMainImage: decodedMainImage,
      decodedSubImages: decodedSubImages,
      decodedlifeCycleImagePaths: decodedlifeCycleImages,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
