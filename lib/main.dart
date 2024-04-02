import 'package:agriculture/TfliteModel.dart';
import 'package:agriculture/screens/loginpage.dart';
import 'package:agriculture/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
// import 'package:background_fetch/background_fetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // initBackgroundFetch();
    // Fetch data initially
    fetchData();
    // Schedule periodic data fetch every 15 seconds
    _timer = Timer.periodic(Duration(seconds: 15), (t) => fetchData());
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  // Future<void> initBackgroundFetch() async {
  //   await BackgroundFetch.configure(
  //     BackgroundFetchConfig(
  //       minimumFetchInterval: 15, // Minimum interval in minutes
  //       stopOnTerminate: false,
  //       enableHeadless: true,
  //       requiresBatteryNotLow: false,
  //       requiresCharging: false,
  //       requiresStorageNotLow: false,
  //       requiresDeviceIdle: false,
  //     ),
  //     (String taskId) async {
  //       print('[BackgroundFetch] Headless event received.');
  //       try {
  //         final String urlData =
  //             await fetchUrl(); // Call the function to fetch URL
  //         print('URL data: $urlData');
  //         BackgroundFetch.finish(taskId);
  //       } catch (e) {
  //         print('Error: $e');
  //       }
  //     },
  //   );
  // }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://foodappbackend.jaffnamarriage.com/public/api/get-url'));
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          List<dynamic> dataList = jsonDecode(response.body);
          if (dataList.isNotEmpty) {
            String originalUrl = dataList[0]['url'].replaceAll(r'\/', '/');
            prefs.setString('urlData', jsonEncode(originalUrl));
          }
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

Future<String> fetchUrl() async {
  final response = await http.get(Uri.parse(
      'https://foodappbackend.jaffnamarriage.com/public/api/get-url'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to fetch URL');
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Trigger the fading-in effect after a delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        opacity = 1.0;
      });
    });

    // Introduce a delay of 3 seconds before navigating to the homepage
    Future.delayed(const Duration(seconds: 5), () {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => const Mainpage(
      //           tokenVal:
      //               '94|r9M0rktIk0ObYXIYACpsxWwA0EtreEHbKQoRWm01b555cae5')),
      // );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color.fromRGBO(5, 183, 119, 1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: opacity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          70.0), // Set the border radius as needed
                      child: Image.asset(
                        'assets/images/splashAgri.png',
                        width: 200,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
