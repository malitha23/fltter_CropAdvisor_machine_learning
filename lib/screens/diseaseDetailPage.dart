import 'dart:convert';
import 'package:agriculture/screens/fullScreenImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiseaseDetailPage extends StatefulWidget {
  final String diseaseiD;

  const DiseaseDetailPage({required this.diseaseiD, Key? key})
      : super(key: key);

  @override
  State<DiseaseDetailPage> createState() => _DiseaseDetailPageState();
}

class _DiseaseDetailPageState extends State<DiseaseDetailPage> {
  late Future<Map<String, dynamic>> _diseaseDetailsFuture;

  @override
  void initState() {
    super.initState();
    _diseaseDetailsFuture = fetchDiseaseDetails(widget.diseaseiD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Details'),
        backgroundColor:
            Color.fromRGBO(5, 183, 119, 1), // Set background color to white
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _diseaseDetailsFuture,
          initialData: null,
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == null) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<dynamic> imagePaths = snapshot.data!['image_paths'];

              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var imagePath in imagePaths)
                          Row(
                            children: [
                              for (var imagePath in imagePaths)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImage(
                                          imageBytes: base64Decode(imagePath),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        base64Decode(imagePath),
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: 100,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // _buildText(
                  //     'Disease ID:', snapshot.data!['id'].toString(), true),
                  SizedBox(height: 8.0),
                  _buildText('Disease Name:', '', true),
                  SizedBox(height: 5.0),
                  Container(
                    padding: EdgeInsets.all(8.0), // Adjust padding as needed
                    color: Colors.grey.withOpacity(0.2), // Set background color
                    child: _buildText(snapshot.data!['disease_name'], '', true),
                  ),

                  SizedBox(height: 8.0),
                  SizedBox(height: 8.0),
                  _buildText('Description:', '', true),
                  SizedBox(height: 5.0),
                  Container(
                    padding: EdgeInsets.all(8.0), // Adjust padding as needed
                    color: Colors.grey.withOpacity(0.2), // Set background color
                    child: _buildText(snapshot.data!['description'], '', true),
                  ),

                  SizedBox(height: 8.0),
                  SizedBox(height: 8.0),
                  _buildText('Solution:', '', true),
                  SizedBox(height: 5.0),
                  Container(
                    padding: EdgeInsets.all(8.0), // Adjust padding as needed
                    color: Colors.grey.withOpacity(0.2), // Set background color
                    child: _buildText(snapshot.data!['solution'], '', true),
                  ),

                  SizedBox(height: 8.0),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildText(String label, String value, bool isBold) {
    return Text(
      '$label $value',
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Future<Map<String, dynamic>> fetchDiseaseDetails(String id) async {
    final response = await http.post(Uri.parse(
        'https://foodappbackend.jaffnamarriage.com/public/api/diseasesgetiD?id=$id'));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> diseases = responseData['diseases'];
      if (diseases.isNotEmpty) {
        return diseases[0];
      } else {
        throw Exception('Disease not found');
      }
    } else {
      throw Exception('Failed to load disease details');
    }
  }
}
