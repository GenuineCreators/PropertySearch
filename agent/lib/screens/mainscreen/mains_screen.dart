import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _userId =
      FirebaseAuth.instance.currentUser!.uid; // Get the current user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // Stay on this screen
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.blue, width: 3),
                        ),
                      ),
                      child: Text(
                        'On-Site',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // Navigate to the WorkShopScreen
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => WorkShopScreen(),
                      //   ),
                      // );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.transparent, width: 3),
                        ),
                      ),
                      child: Text(
                        'WorkShop',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildClickableContainer(
                      context,
                      icon: Icons.search,
                      text: 'Search Location',
                      onTap: () {
                        // Handle Search Location action
                      },
                    ),
                    SizedBox(height: 10),
                    _buildClickableContainer(
                      context,
                      icon: Icons.my_location,
                      text: 'Current Location',
                      onTap: () {
                        // Handle Current Location action
                      },
                    ),
                    SizedBox(height: 10),
                    _buildClickableContainer(
                      context,
                      icon: Icons.home,
                      text: 'Home',
                      onTap: () {
                        // Handle Home action
                      },
                    ),
                    SizedBox(height: 10),
                    _buildClickableContainer(
                      context,
                      icon: Icons.work,
                      text: 'Work',
                      onTap: () {
                        // Handle Work action
                      },
                    ),
                    Divider(thickness: 1, height: 30), // Divider
                    Text(
                      'My Cars',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('MyCars')
                            .where('clientID', isEqualTo: _userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No cars found.'));
                          }
                          return ListView(
                            children: snapshot.data!.docs.map((car) {
                              return _buildCarContainer(
                                image: car['image'],
                                name: car['name'],
                                numberPlate: car['numberPlate'],
                                color: car['color'],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => addCarScreen()),
                          // );
                        },
                        child: const Text(
                          'Order Another Car',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width: 350,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Order Total Price:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableContainer(BuildContext context,
      {required IconData icon,
      required String text,
      required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarContainer({
    required String image,
    required String name,
    required String numberPlate,
    required String color,
  }) {
    return InkWell(
      onTap: () {
        // Handle car click action
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Image.network(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Plate: $numberPlate', style: TextStyle(fontSize: 14)),
                  Text('Color: $color', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('price',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Checkbox(
                  value: false, // Replace with dynamic value if needed
                  onChanged: (bool? value) {
                    // Handle checkbox change
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
