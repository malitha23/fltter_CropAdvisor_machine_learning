import 'dart:convert';
import 'package:agriculture/screens/diseaseDetailPage.dart';
import 'package:agriculture/screens/fullScreenImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class allDiseaseshowpage extends StatefulWidget {
  @override
  _allDiseaseshowpageState createState() => _allDiseaseshowpageState();
}

class _allDiseaseshowpageState extends State<allDiseaseshowpage> {
  List<Disease> diseases = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDiseases(); // Load diseases when the page initializes
  }

  Future<void> loadDiseases() async {
    setState(() {
      isLoading = true; // Set isLoading to true when fetching starts
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/diseasesgetall'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);

          if (responseData != null && responseData['diseases'] != null) {
            List<dynamic> parsedJson = responseData['diseases'];

            // Validate and decode base64 image paths
            parsedJson = parsedJson.map((json) {
              if (json['image_paths'] != null) {
                json['image_paths'] = json['image_paths'].map((path) {
                  if (path is String) {
                    // Clean base64 string if necessary
                    path = path.replaceAll(RegExp(r'\s+'), '');
                    try {
                      // Validate base64 string length
                      if (path.length % 4 != 0) {
                        path = path.padRight(
                            path.length + (4 - path.length % 4), '=');
                      }
                      // Optionally, decode base64 data to check validity
                      base64.decode(path);
                    } catch (e) {
                      print('Base64 decoding error: $e');
                      // Handle the error (e.g., set a placeholder image)
                      path = ''; // Or set to a placeholder URL
                    }
                  }
                  return path;
                }).toList();
              }
              return json;
            }).toList();

            setState(() {
              diseases =
                  parsedJson.map((json) => Disease.fromJson(json)).toList();
              isLoading = false;
            });
          } else {
            print('Error: Response data does not contain "diseases"');
            setState(() {
              isLoading = false;
            });
          }
        } catch (jsonError) {
          print('JSON decoding error: $jsonError');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to get diseases: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error loading diseases: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Cards'),
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.stretchedDots(
              color: Color.fromRGBO(5, 183, 119, 1),
              size: 40,
            ))
          : ListView.builder(
              itemCount: diseases.length,
              itemBuilder: (context, index) {
                Disease disease = diseases[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiseaseDetailPage(
                            diseaseiD: disease.id
                                .toString()), // Pass your disease value here
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      150, // Set a fixed width or use constraints to limit the width
                                  child: Text(
                                    'Disease Name: ${disease.diseaseName}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 150,
                                  child: Text(
                                    'Crop Name: ${disease.cropName}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 150,
                                  child: Text(
                                    'Description: ${disease.description}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 150,
                                  child: Text(
                                    'Solution: ${disease.solution}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 16, // Adjust as needed
                          ),
                          SizedBox(
                            width: 150,
                            height: 100, // Set the height of the container
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final subImage
                                      in disease.decodedSubImages)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenImage(
                                                imageBytes: subImage!,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color.fromARGB(
                                                        255, 227, 225, 225)
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 3,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: subImage != null
                                                ? Image.memory(
                                                    subImage,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 100,
                                                    height: 100,
                                                    color: Colors.grey,
                                                    child: Center(
                                                      child: Text(
                                                        'No Image',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class Disease {
  List<Uint8List?> decodedSubImages;
  final int id;
  final String diseaseName;
  final String cropName;
  final String description;
  final String solution;
  final List<String> imagePaths;

  Disease({
    required this.id,
    required this.diseaseName,
    required this.cropName,
    required this.description,
    required this.solution,
    required this.imagePaths,
    required this.decodedSubImages,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    List<String> subImagePaths = List<String>.from(json['image_paths'] ?? []);
    List<Uint8List?> decodedSubImages = [];

    for (String imagePath in subImagePaths) {
      if (imagePath != null) {
        decodedSubImages
            .add(base64Decode(imagePath.substring(imagePath.indexOf(',') + 1)));
      } else {
        decodedSubImages.add(null);
      }
    }

    return Disease(
      id: json['id'],
      diseaseName: json['disease_name'],
      cropName: json['crop_name'],
      description: json['description'],
      solution: json['solution'],
      imagePaths: List<String>.from(json['image_paths']),
      decodedSubImages: decodedSubImages,
    );
  }
}
