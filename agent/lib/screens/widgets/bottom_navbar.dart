// import 'package:customers/screens/Pages/searchScreen.dart';
import 'package:agent/screens/mainscreen/activity_screen.dart';
import 'package:agent/screens/mainscreen/home_page.dart';
import 'package:agent/screens/mainscreen/mains_screen.dart';
import 'package:agent/screens/mainscreen/profile_screen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  List<Widget> _pages() {
    return [
      MainScreen(),
      NewHouses(),
      // SearchScreen(),
      ActivityScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: Colors.blue,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              color: Colors.blue,
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

// // ignore_for_file: sort_child_properties_last

// import 'package:customers/screens/booking_screen.dart';
// import 'package:customers/screens/home_screen.dart';
// import 'package:customers/screens/profile_screen.dart';
// import 'package:customers/screens/search_screen.dart';
// import 'package:flutter/material.dart';

// class BottomNavBar extends StatefulWidget {
//   @override
//   _BottomNavBarState createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int _selectedIndex = 0;

//   static const List<Widget> _pages = <Widget>[
//     HomeScreen(),
//     SearchScreen(),
//     Screen(),
//     ProfileScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomAppBar(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: <Widget>[
//             _buildNavItem(0, Icons.home, 'Home'),
//             _buildNavItem(1, Icons.search, 'Search'),
//             _buildNavItem(2, Icons.book_sharp, 'Booking'),
//             _buildNavItem(3, Icons.person, 'Profile'),
//           ],
//         ),
//         color: Colors.white,
//       ),
//     );
//   }

//   Widget _buildNavItem(int index, IconData icon, String label) {
//     return InkWell(
//       onTap: () {
//         _onItemTapped(index);
//       },
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Icon(
//             icon,
//             color: _selectedIndex == index ? Colors.blue : Colors.black,
//           ),
//           Text(
//             label,
//             style: TextStyle(
//               color: _selectedIndex == index ? Colors.blue : Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: BottomNavBar(),
//   ));
// }
