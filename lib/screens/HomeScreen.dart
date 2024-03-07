import 'dart:io';
import 'package:agriculture/screens/DataInputForm%20.dart';
import 'package:agriculture/screens/UploadedImageScreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  final String tokenVal;

  const HomeScreen({Key? key, required this.tokenVal}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;
  static const IconData medical_services_outlined =
      IconData(0xf1be, fontFamily: 'MaterialIcons');
  @override
  void initState() {
    super.initState();
    // Initialize the Future for fetching user data
    _userDataFuture = getUserData();
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://foodappbackend.jaffnamarriage.com/public/api/user-data'),
        headers: {'Authorization': 'Bearer ${widget.tokenVal}'},
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the user data
        final Map<String, dynamic> data = json.decode(response.body);
        return data['user'];
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred: $e');
      throw e; // Re-throw the exception to propagate it
    }
  }

  File? _image;

  Future<void> _getImage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadedImageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loader while fetching data
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Show an error message if data fetching fails
              return Center(child: Text('Error loading user data'));
            } else {
              // Data fetching successful
              final userData = snapshot.data!;

              // Determine the role and display content accordingly
              if (userData['role'] == 'admin') {
                return buildAdminContent(userData);
              } else {
                return buildUserContent(userData);
              }
            }
          },
        ),
      ),
    );
  }

  Widget buildAdminContent(Map<String, dynamic> userData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          datainputformmain(userData: userData),
        ],
      ),
    );
  }

  Widget buildUserContent(Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi ${userData['name']}!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildContainer(
                      'Crops', Icons.grass, Color.fromRGBO(5, 183, 119, 1)),
                  SizedBox(width: 20),
                  buildContainer(
                      'Whether', Icons.cloud, Color.fromRGBO(5, 183, 119, 1)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildContainer('Disease', Icons.medical_services_outlined,
                      Color.fromRGBO(5, 183, 119, 1)),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildContainerWithImageUpload('Identify Your Crops',
                      Icons.file_upload, Color.fromRGBO(5, 183, 119, 1)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildContainer(String text, IconData iconData, Color color) {
    return Container(
      width: 150,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: Colors.white,
            size: 30, // Adjust the icon size as needed
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildContainerWithImageUpload(
      String text, IconData iconData, Color color) {
    return Container(
      width: 200,
      height: 130,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: Colors.white,
            size: 40, // Adjust the icon size as needed
          ),
          const SizedBox(height: 7),
          Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              _getImage();
            },
            child: Text('Upload Image'),
          ),
        ],
      ),
    );
  }
}

class datainputformmain extends StatefulWidget {
  final Map<String, dynamic> userData;

  const datainputformmain({Key? key, required this.userData}) : super(key: key);

  @override
  State<datainputformmain> createState() => _datainputformmainState();
}

class _datainputformmainState extends State<datainputformmain> {
  bool isForm1Visible = true; // Set Form 1 as initially visible
  bool isForm2Visible = false;

  void openForm1() {
    setState(() {
      isForm1Visible = true;
      isForm2Visible = false;
    });
  }

  void openForm2() {
    setState(() {
      isForm1Visible = false;
      isForm2Visible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Hi ${widget.userData['name']}!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => openForm1(),
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: isForm1Visible ? Colors.grey : Colors.green,
                          borderRadius: BorderRadius.circular(
                              10), // Set your desired radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Form 1',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add some space between buttons
                    GestureDetector(
                      onTap: () => openForm2(),
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: isForm2Visible ? Colors.grey : Colors.green,
                          borderRadius: BorderRadius.circular(
                              10), // Set your desired radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Form 2',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            // Conditionally show Form1 or Form2 based on visibility
            if (isForm1Visible) datainputformadmin(),
            if (isForm2Visible) Container(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
