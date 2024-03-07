import 'package:agriculture/screens/loginpage.dart';
import 'package:agriculture/screens/mainpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
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
