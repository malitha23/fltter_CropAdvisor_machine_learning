import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WeatherCardPage extends StatefulWidget {
  const WeatherCardPage({Key? key});

  @override
  State<WeatherCardPage> createState() => _WeatherCardPageState();
}

class _WeatherCardPageState extends State<WeatherCardPage> {
  late Weather _weather;

  @override
  void initState() {
    super.initState();
    // Initialize _weather to null
    _weather = Weather(
        cityName: '',
        weatherDescription: '',
        temperature: 0,
        humidity: 0,
        windSpeed: 0,
        weatherIcon: '');
    fetchWeatherData();
  }

  // Fetch weather data for the current location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Method to fetch weather data from the API
  Future<void> fetchWeatherData() async {
    // Request permission to access the device's location
    Position position = await _determinePosition();
    print(position);
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=7444f13628fcf6709e97d873a3ddee2f'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _weather = Weather.fromJson(jsonData);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _weather != ''
        ? WeatherCard(
            cityName: _weather.cityName ?? 'Unknown',
            weatherDescription: _weather.weatherDescription ?? 'Unknown',
            temperature: _weather.temperature ?? 0,
            humidity: _weather.humidity ?? 0,
            windSpeed: _weather.windSpeed ?? 0,
            weatherIcon: _weather.weatherIcon ?? '',
          )
        : Center(
            child: LoadingAnimationWidget.stretchedDots(
              color: Color.fromRGBO(5, 183, 119, 1),
              size: 40,
            ),
          );
  }
}

class WeatherCard extends StatelessWidget {
  final String cityName;
  final String weatherDescription;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String weatherIcon;

  WeatherCard({
    required this.cityName,
    required this.weatherDescription,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          title: Text('Weather Details'),
          backgroundColor:
              Color.fromRGBO(135, 191, 250, 1), // Set background color to white
          foregroundColor: Colors.white,
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/whether.jpg', // Replace with your image URL
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Aligns children to the start and end of the row
                    children: [
                      Text(
                        cityName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .end, // Aligns children to the end of the column
                        children: [
                          Text(
                            'Humidity: $humidity%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                              height:
                                  4), // Add some spacing between the two text widgets
                          Text(
                            'Wind Speed: ${windSpeed.toStringAsFixed(1)} m/s',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(width: 26),
                        Image.network(
                          'https://openweathermap.org/img/w/$weatherIcon.png',
                          width: 50,
                          height: 50,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              // Image has finished loading
                              return child;
                            } else {
                              // Show a placeholder while loading
                              return LoadingAnimationWidget.stretchedDots(
                                color: Color.fromRGBO(5, 183, 119, 1),
                                size: 40,
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            // Show an error message if the image fails to load
                            return LoadingAnimationWidget.stretchedDots(
                              color: Color.fromRGBO(5, 183, 119, 1),
                              size: 40,
                            );
                          },
                        ),
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white, // Set text color to white
                            fontWeight: FontWeight.bold, // Make text bold
                          ),
                        ),
                        Text(
                          '$weatherDescription',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white, // Set text color to white
                            fontWeight: FontWeight.bold, // Make text bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}

class Weather {
  final String? cityName;
  final String? weatherDescription;
  final double? temperature;
  final int? humidity;
  final double? windSpeed;
  final String? weatherIcon;

  Weather({
    required this.cityName,
    required this.weatherDescription,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherIcon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      weatherDescription: json['weather'][0]['description'],
      temperature: json['main']['temp'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
      weatherIcon: json['weather'][0]['icon'],
    );
  }
}
