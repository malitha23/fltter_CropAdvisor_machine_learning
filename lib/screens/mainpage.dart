import 'package:agriculture/screens/HomeScreen.dart';
import 'package:agriculture/screens/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
        ProfileScreen(tokenVal: widget.tokenVal),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.home),
          title: "Home",
          activeColorPrimary: Color.fromRGBO(5, 183, 119, 1),
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.person),
          title: "Profile",
          activeColorPrimary: Color.fromRGBO(5, 183, 119, 1),
          inactiveColorPrimary: Colors.grey,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        // Other properties remain the same
        // Add necessary properties such as backgroundColor, decoration, etc.
      ),
    );
  }
}
