import 'package:agriculture/screens/HomeScreen.dart';
import 'package:agriculture/screens/ProfileScreen.dart';
import 'package:agriculture/screens/FavoritesScreen.dart'; // Import the new page
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Mainpage extends StatefulWidget {
  final String tokenVal;

  const Mainpage({Key? key, required this.tokenVal}) : super(key: key);

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  PersistentTabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController();
  }

  List<Widget> _buildScreens() => [
        HomeScreen(tokenVal: widget.tokenVal),
        FavoritesScreen(tokenVal: widget.tokenVal), // Add FavoritesScreen here
        ProfileScreen(tokenVal: widget.tokenVal),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.home),
          title: "Home",
          activeColorPrimary: Colors.white,
          inactiveColorPrimary: Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.favorite),
          title: "Favorites",
          activeColorPrimary: Colors.white,
          inactiveColorPrimary: Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.person),
          title: "Profile",
          activeColorPrimary: Colors.white,
          inactiveColorPrimary: Colors.white,
        )
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        backgroundColor: Color.fromRGBO(5, 183, 119, 1),
      ),
    );
  }
}
