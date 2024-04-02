import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class datainputformadmin extends StatefulWidget {
  const datainputformadmin({Key? key}) : super(key: key);

  @override
  State<datainputformadmin> createState() => _datainputformadminState();
}

class _datainputformadminState extends State<datainputformadmin> {
  final TextEditingController cropsNameController = TextEditingController();
  final TextEditingController mainImageController = TextEditingController();
  final TextEditingController subImage1Controller = TextEditingController();
  final TextEditingController subImage2Controller = TextEditingController();
  final TextEditingController cropvariety = TextEditingController();
  final TextEditingController selectedLifeCycle = TextEditingController();

  String selectedZone = "dry";
  String selectedSoilType = "Reddish Brown Earths soil";
  String selectedSeasons = "December-February";

  String selectedCycle = "daily";
  String selectedDailyOption = "morning half";
  String selectedWeeklyOption = "2 days";
  String selectedTimeOption = "morning half";

  List<String> selectedDiseases = [];

  final List<String> allDiseases = [
    "Disease A",
    "Disease B",
    "Disease C",
    // Add more diseases as needed
  ];

  final List<String> zones = ["dry", "wet", "intermediate"];
  final List<String> soilTypes = [
    "Reddish Brown Earths soil",
    "red soil",
    "clay soil",
    "black soil",
    "Alluvial soil"
  ];

  final List<String> seasons = [
    "December-February",
    "March-May",
    "June-August",
    "September-November",
  ];

  final List<String> cycles = ["daily", "weekly"];
  final List<String> dailyOptions = ["morning half", "evening"];
  final List<String> weeklyOptions = ["2 days", "3 days"];
  final List<String> timeOptions = ["morning half", "evening"];

  File? mainImage;
  String? mainImagebase64;
  List<File> subImages = [];
  List<File> lifeCycleImages = [];
  List<String> lifeCycleImagesString = [];
  List<String> lifeCycleImagesBase64 = [];
  List<String> subImagesBase64 = [];

  Future<void> _pickImageForLifeCycle() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        lifeCycleImages.add(File(pickedImage.path)); // Add the original file
        lifeCycleImagesBase64.add(base64Image); // Add the base64-encoded string
        lifeCycleImagesString.add(pickedImage.path);
      });
    }
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(bool isMainImage) async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() {
        if (isMainImage) {
          mainImage = File(pickedImage.path);
          mainImagebase64 = base64Image;
        } else {
          subImages.add(File(pickedImage.path));
          subImagesBase64.add(base64Image);
        }
      });
    }
  }

  bool isLoading = false;

  List<Widget> previewImages = [];
  void _handleSubmit() async {
    // Validate the form
    setState(() {
      isLoading = true; // Set loading state to true when button is pressed
    });
    // Get all the values from the form
    String cropName = cropsNameController.text;
    String mainImagePath = mainImage?.path ?? '';
    List<String> subImagePaths = subImages.map((image) => image.path).toList();
    String zone = selectedZone;
    String soilType = selectedSoilType;
    String selectedSeason = selectedSeasons;
    String selectedWateringCycle = selectedCycle;
    String weeklyOption = '';
    String timeOption = '';
    String dailyOption = '';
    List<String> selectedDiseaseList = selectedDiseases;
    String cropVariety = cropvariety.text;
    String lifeCycleDescription = selectedLifeCycle.text;
    List<String> lifeCycleImagePaths =
        lifeCycleImages.map((image) => image.path).toList();

    if (cropName == null ||
        mainImagebase64 == null ||
        subImagesBase64 == null ||
        zone == null ||
        soilType == null ||
        selectedSeason == null ||
        selectedWateringCycle == null ||
        // Add similar checks for other fields
        false) {
      // Display an alert if any value is null
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill in all the required fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the alert
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        isLoading = false; // Set loading state to true when button is pressed
      });
      return; // Exit the function if any value is null
    }

    // Set options based on selectedWateringCycle
    if (selectedWateringCycle == "daily") {
      dailyOption = selectedDailyOption;
    } else if (selectedWateringCycle == "weekly") {
      weeklyOption = selectedWeeklyOption;
      timeOption = selectedTimeOption;
    }

    // Create a map with the form data
    Map<String, dynamic> formData = {
      'cropName': cropName,
      'mainImagePath': mainImagebase64,
      'subImagePaths': subImagesBase64,
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
      'lifeCycleImagePaths': lifeCycleImagesBase64,
    };

    // Convert the form data to JSON
    String jsonData = jsonEncode(formData);
    print(jsonData); // For debugging

    // Replace 'your_laravel_endpoint' with your actual Laravel endpoint
    String endpoint = 'http://127.0.0.1:8000/api/cropsstore';

    // Make the HTTP POST request
    var response = await http.post(
      Uri.parse(endpoint),
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> responseData = json.decode(response.body);

      // Access the lifeCycleImagePaths property
      List<String> lifeCycleImagePaths =
          List<String>.from(responseData['data']['lifeCycleImagePaths'] ?? []);

      // Load and set preview images

      for (String imagePath in lifeCycleImagePaths) {
        List<int> bytes = base64Decode(imagePath);

        // Use Image.memory instead of Image.network
        Widget imageWidget = Image.memory(
          Uint8List.fromList(bytes),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );

        // Add the image widget to the list
        setState(() {
          previewImages.add(imageWidget);
        });
      }

      // Print or use the preview images
      print('Preview Images: $previewImages');
      print('Form data submitted successfully!');
      setState(() {
        isLoading = false; // Set loading state to true when button is pressed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('Form data submitted successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the alert
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    } else {
      setState(() {
        isLoading = false; // Set loading state to true when button is pressed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('Form data submitted unsuccessfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the alert
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
      print('Failed to submit form data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Column(
            //   children: previewImages,
            // ),
            TextField(
              controller: cropsNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Crop Name',
                hintText: 'Enter Crop Name',
              ),
            ),
            // TextFormField(
            //   controller: cropsNameController,
            //   decoration: InputDecoration(labelText: 'Crop Name'),
            // ),
            SizedBox(height: 20),
            Row(
              children: [
                Stack(
                  children: [
                    if (mainImage != null)
                      Container(
                        width: 50,
                        height: 50,
                        child: kIsWeb
                            ? Image.network(
                                mainImage!.path,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                mainImage!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                      ),
                    if (mainImage != null)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              mainImage = null;
                            });
                          },
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 5),
                Stack(
                  children: [
                    if (subImages.length >= 1)
                      Container(
                        width: 50,
                        height: 50,
                        child: kIsWeb
                            ? Image.network(
                                subImages[0].path,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                subImages[0],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                      ),
                    if (subImages.length >= 1)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              subImages.removeAt(0);
                            });
                          },
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 5),
                Stack(
                  children: [
                    if (subImages.length >= 2)
                      Container(
                        width: 50,
                        height: 50,
                        child: kIsWeb
                            ? Image.network(
                                subImages[1].path,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                subImages[1],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                      ),
                    if (subImages.length >= 2)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              subImages.removeAt(1);
                            });
                          },
                        ),
                      ),
                  ],
                ),
                if (mainImage == null)
                  ElevatedButton(
                    onPressed: () => _pickImage(true),
                    child: Text('Crops Image'),
                  ),
                if (mainImage != null && subImages.length < 1)
                  ElevatedButton(
                    onPressed: () => _pickImage(false),
                    child: Text('Crops Image 1'),
                  ),
                if (subImages.length >= 1 && subImages.length < 2)
                  ElevatedButton(
                    onPressed: () => _pickImage(false),
                    child: Text('Crops Image 2'),
                  ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedZone,
              onChanged: (value) {
                setState(() {
                  selectedZone = value!;
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
                // Customize the dropdown style
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedSoilType,
              onChanged: (value) {
                setState(() {
                  selectedSoilType = value!;
                });
              },
              items: soilTypes.map((soilType) {
                return DropdownMenuItem<String>(
                  value: soilType,
                  child: Text(soilType),
                );
              }).toList(),
              decoration: InputDecoration(
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
              value: selectedSeasons,
              onChanged: (value) {
                setState(() {
                  selectedSeasons = value!;
                });
              },
              items: seasons.map((season) {
                return DropdownMenuItem<String>(
                  value: season,
                  child: Text(season),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Seasons',
                // Customize the dropdown style
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedCycle,
              onChanged: (value) {
                setState(() {
                  selectedCycle = value!;
                  selectedWeeklyOption = weeklyOptions
                      .first; // Reset weekly option on cycle change
                  selectedTimeOption =
                      timeOptions.first; // Reset time option on cycle change
                });
              },
              items: cycles.map((cycle) {
                return DropdownMenuItem<String>(
                  value: cycle,
                  child: Text(cycle),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Watering Cycle',
                // Customize the dropdown style
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (selectedCycle == "weekly")
              DropdownButtonFormField<String>(
                value: selectedWeeklyOption,
                onChanged: (value) {
                  setState(() {
                    selectedWeeklyOption = value!;
                  });
                },
                items: weeklyOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Days',
                  // Customize the dropdown style
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
            if (selectedCycle == "weekly")
              DropdownButtonFormField<String>(
                value: selectedTimeOption,
                onChanged: (value) {
                  setState(() {
                    selectedTimeOption = value!;
                  });
                },
                items: timeOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Time',
                  // Customize the dropdown style
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
            SizedBox(height: 20),

// Conditionally show the dropdown for daily options
            if (selectedCycle == "daily")
              DropdownButtonFormField<String>(
                value: selectedDailyOption,
                onChanged: (value) {
                  setState(() {
                    selectedDailyOption = value!;
                  });
                },
                items: dailyOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Daily Option',
                  // Customize the dropdown style
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: MultiSelectDialogField(
                items: allDiseases.map((e) => MultiSelectItem(e, e)).toList(),
                listType: MultiSelectListType.CHIP,
                searchable: true,
                onConfirm: (values) {
                  setState(() {
                    selectedDiseases = values;
                  });
                },
              ),
            ),

            SizedBox(height: 20),
            TextFormField(
              controller: cropvariety,
              decoration: InputDecoration(
                labelText: 'Crop Variety',
                // Customize the dropdown style
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: selectedLifeCycle,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Life Cycle Description',
                hintText: 'Enter Life Cycle Description',
                contentPadding: EdgeInsets.symmetric(
                    vertical: 30.0,
                    horizontal: 10), // Adjust the value as needed
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                kIsWeb
                    ? Container(
                        child: Row(
                          children: [
                            for (int i = 0;
                                i < lifeCycleImagesString.length;
                                i++)
                              Stack(
                                children: [
                                  Container(
                                      width: 50,
                                      height: 50,
                                      child: Image.network(
                                        lifeCycleImagesString[i],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )),
                                  Positioned(
                                    top: 5,
                                    left: 5,
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          lifeCycleImagesString.removeAt(i);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      )
                    : Container(
                        child: Row(
                          children: [
                            for (int i = 0; i < lifeCycleImages.length; i++)
                              Stack(
                                children: [
                                  Container(
                                      width: 50,
                                      height: 50,
                                      child: Image.file(
                                        lifeCycleImages[i],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )),
                                  Positioned(
                                    top: 5,
                                    left: 5,
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          lifeCycleImages.removeAt(i);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                if (lifeCycleImages.length < 5)
                  ElevatedButton(
                    onPressed: () => _pickImageForLifeCycle(),
                    child: Text('Add Life Cycle Image'),
                  ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
                _handleSubmit();
              },
              child: Text(
                isLoading ? 'Submitting...' : 'Submit',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromRGBO(5, 183, 119, 1), // Background color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Adjust the value as needed
                ),
                padding: EdgeInsets.all(16.0), // Adjust the padding as needed
                minimumSize: Size(
                    double.infinity, 50), // Set to full-width and adjust height
              ),
            ),
          ],
        ),
      ),
    );
  }
}
