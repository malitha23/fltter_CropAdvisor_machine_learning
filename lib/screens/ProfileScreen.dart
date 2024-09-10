import 'package:agriculture/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String tokenVal;

  const ProfileScreen({Key? key, required this.tokenVal}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is created
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/user-data'),
        headers: {'Authorization': 'Bearer ${widget.tokenVal}'},
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the user data
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          userData = data['user'];
        });
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${userData?['role'] ?? 'User'} Profile'),
      ),
      body: Center(
        child: userData != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 100,
                    // Use the user's profile image URL from userData
                    // For example: NetworkImage(userData['profile_image']),
                    backgroundImage: AssetImage('assets/images/manager.jpg'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    userData!['name'] ?? 'User',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Email: ${userData!['email']}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return MyApp();
                          },
                        ),
                        (_) => false,
                      );
                    },
                    child: Text('Logout'),
                  ),
                  // Add more user-related information as needed
                ],
              )
            : LoadingAnimationWidget.stretchedDots(
                color: Color.fromRGBO(5, 183, 119, 1),
                size: 40,
              ), // Show a loading indicator while fetching data
      ),
    );
  }
}
