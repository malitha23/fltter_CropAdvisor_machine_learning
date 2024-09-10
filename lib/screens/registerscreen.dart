import 'dart:convert';
import 'package:agriculture/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Regscreen extends StatefulWidget {
  const Regscreen({super.key});

  @override
  State<Regscreen> createState() => _RegscreenState();
}

class _RegscreenState extends State<Regscreen> {
  var width, height;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> regUser() async {
    // Get the email and password entered by the user
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String repassword = repasswordController.text;

    // Validate username
    if (username.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Register Failed'),
            content: Text('Please enter username.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validate email
    if (email.isEmpty || !isValidEmail(email)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Register Failed'),
            content: Text('Please enter a valid email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validate password
    if (password.isEmpty || password.length < 6) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Register Failed'),
            content: Text('Password should be at least 6 characters.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validate if passwords match
    if (password != repassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Register Failed'),
            content: Text('The passwords do not match.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      isLoading = true; // Set loading state
    });

    var apiUrl = Uri.parse('http://10.0.2.2:8000/api/register');

    // Data to be sent in the request body
    var data = {
      'name': username,
      'email': email,
      'password': password,
    };

    try {
      var response = await http.post(apiUrl, body: data);
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLoading = false;
        });

        // Use rawToken or token from JSON
        var token = jsonResponse['token'] ?? '';

        // Store the token using SharedPreferences (if not on web)
        if (!kIsWeb) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }

        // Navigate to the main page with the token
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Mainpage(tokenVal: token)),
        );
      } else {
        // Handle non-success HTTP responses
        setState(() {
          isLoading = false;
        });

        String errorMessage =
            jsonResponse['message'] ?? 'Unknown error occurred.';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Register Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred: $e');
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Exception'),
            content:
                Text('An unexpected error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Email validation
  bool isValidEmail(String email) {
    // Use RegExp or other logic to validate the email format
    // For example, you could use RegExp to validate email format
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    SizedBox(
                      width: width,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(
                                  0.8), // You can adjust the opacity level (0.0 to 1.0)
                              BlendMode.dstATop,
                            ),
                            child: Image.asset(
                              "assets/images/b23e7e61e46dead0a5387688f9cb568a.jpg", // Replace with your image path
                              fit: BoxFit.cover,
                            ),
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                height: 300,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF7F8FA),
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(4, 4),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(-4, 0),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 70.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: const Text(
                                        'Please Create New Account To Continue:',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18.0,
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: const Text(
                                        'Username',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.0,
                                          color: Color.fromRGBO(0, 0, 0, 0.75),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: TextField(
                                        controller: usernameController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              Color.fromRGBO(255, 255, 255, 1),
                                          labelStyle: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.0,
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.75),
                                          ),
                                          hintText: 'Enter your username',
                                          hintStyle: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                  5, 183, 119, 1),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: const Text(
                                        'Email or Phone Number',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.0,
                                          color: Color.fromRGBO(0, 0, 0, 0.75),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: TextField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              Color.fromRGBO(255, 255, 255, 1),
                                          labelStyle: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.0,
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.75),
                                          ),
                                          hintText:
                                              'Enter your email or phone number',
                                          hintStyle: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                  5, 183, 119, 1),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: const Text(
                                        'Password',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.0,
                                          color: Color.fromRGBO(0, 0, 0, 0.75),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: TextField(
                                        obscureText: true,
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              Color.fromRGBO(255, 255, 255, 1),
                                          labelStyle: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.0,
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.75),
                                          ),
                                          hintText: 'Input Your Password',
                                          hintStyle: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                  5, 183, 119, 1),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: const Text(
                                        'Re-enter Password',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.0,
                                          color: Color.fromRGBO(0, 0, 0, 0.75),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: TextField(
                                        obscureText: true,
                                        controller: repasswordController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              Color.fromRGBO(255, 255, 255, 1),
                                          labelStyle: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.0,
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.75),
                                          ),
                                          hintText: 'Input Your Password',
                                          hintStyle: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                  5, 183, 119, 1),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      alignment: Alignment.center,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromRGBO(5, 183, 119, 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          fixedSize: Size(194.0, 43.0),
                                        ),
                                        onPressed: regUser,
                                        child: Text(
                                          isLoading
                                              ? 'Registering...'
                                              : 'Register',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
