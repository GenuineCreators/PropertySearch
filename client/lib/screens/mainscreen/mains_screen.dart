import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Houses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('houses')
            .where('agentID', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No houses found.'));
          }

          final houses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: houses.length,
            itemBuilder: (context, index) {
              final house = houses[index].data() as Map<String, dynamic>;
              final imageUrls = house['imageUrls'] as List<dynamic>;
              final price = house['price'] as double;
              final bedrooms = house['bedrooms'] as int;
              final bathrooms = house['bathrooms'] as int;
              final amenities = house['amenities'] as Map<String, dynamic>;
              final hasSwimmingPool = house['hasSwimmingPool'] as bool;
              final type = house['type'] as String;
              final location = house['location'] as String; // Get the type

              // Convert amenities to Map<String, bool>
              final amenitiesMap = amenities.map<String, bool>(
                (key, value) => MapEntry(key, value as bool),
              );

              return GestureDetector(
                onTap: () {
                  // Navigate to house details page (optional)
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // Display the first image from imageUrls
                      if (imageUrls.isNotEmpty)
                        Container(
                          height: 150, // Reduced height
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                            image: DecorationImage(
                              image: NetworkImage(imageUrls[0]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Display the type at the top left corner
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Display the heart icon at the top right corner
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    // Handle heart icon click
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Display the price
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 18, right: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              location,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),

                      // Display bedrooms and bathrooms in a row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.bed, size: 20),
                            SizedBox(width: 5),
                            Text('$bedrooms Bedrooms'),
                            SizedBox(width: 20),
                            Icon(Icons.bathtub, size: 20),
                            SizedBox(width: 5),
                            Text('$bathrooms Bathrooms'),
                          ],
                        ),
                      ),

                      // Display amenities in rows of 2 items per row
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (amenitiesMap['Malls'] == true)
                              _buildAmenityIcon(Icons.local_mall, 'Malls'),
                            if (amenitiesMap['Schools'] == true)
                              _buildAmenityIcon(Icons.school, 'Schools'),
                            if (amenitiesMap['Police Station'] == true)
                              _buildAmenityIcon(
                                  Icons.local_police, 'Police Station'),
                            if (amenitiesMap['Shopping Centre'] == true)
                              _buildAmenityIcon(
                                  Icons.shopping_cart, 'Shopping Centre'),
                            if (hasSwimmingPool)
                              _buildAmenityIcon(Icons.pool, 'Swimming Pool'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to build an amenity icon with a label
  Widget _buildAmenityIcon(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:async'; // Import Timer

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Houses'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('houses')
//             .where('agentID', isEqualTo: _auth.currentUser?.uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No houses found.'));
//           }

//           final houses = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: houses.length,
//             itemBuilder: (context, index) {
//               final house = houses[index].data() as Map<String, dynamic>;
//               final imageUrls = house['imageUrls'] as List<dynamic>;
//               final price = house['price'] as double;
//               final bedrooms = house['bedrooms'] as int;
//               final bathrooms = house['bathrooms'] as int;
//               final amenities = house['amenities'] as Map<String, dynamic>;
//               final hasSwimmingPool = house['hasSwimmingPool'] as bool;
//               final type = house['type'] as String;

//               // Convert amenities to Map<String, bool>
//               final amenitiesMap = amenities.map<String, bool>(
//                 (key, value) => MapEntry(key, value as bool),
//               );

//               return HouseItem(
//                 imageUrls: imageUrls,
//                 price: price,
//                 bedrooms: bedrooms,
//                 bathrooms: bathrooms,
//                 amenitiesMap: amenitiesMap,
//                 hasSwimmingPool: hasSwimmingPool,
//                 type: type,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class HouseItem extends StatefulWidget {
//   final List<dynamic> imageUrls;
//   final double price;
//   final int bedrooms;
//   final int bathrooms;
//   final Map<String, bool> amenitiesMap;
//   final bool hasSwimmingPool;
//   final String type;

//   const HouseItem({
//     required this.imageUrls,
//     required this.price,
//     required this.bedrooms,
//     required this.bathrooms,
//     required this.amenitiesMap,
//     required this.hasSwimmingPool,
//     required this.type,
//   });

//   @override
//   _HouseItemState createState() => _HouseItemState();
// }

// class _HouseItemState extends State<HouseItem> {
//   int _currentImageIndex = 0;
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     // Start a timer to change the image every 5 seconds
//     _timer = Timer.periodic(Duration(seconds: 5), (timer) {
//       setState(() {
//         _currentImageIndex = (_currentImageIndex + 1) % widget.imageUrls.length;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel(); // Cancel the timer when the widget is disposed
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // Navigate to house details page (optional)
//       },
//       child: Container(
//         margin: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             // Display the current image from imageUrls
//             if (widget.imageUrls.isNotEmpty)
//               Container(
//                 height: 150, // Reduced height
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//                   image: DecorationImage(
//                     image: NetworkImage(widget.imageUrls[_currentImageIndex]),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Display the type at the top left corner
//                     Positioned(
//                       top: 10,
//                       left: 10,
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.black54,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           widget.type,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Display the heart icon at the top right corner
//                     Positioned(
//                       top: 10,
//                       right: 10,
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.favorite_border,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                         onPressed: () {
//                           // Handle heart icon click
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             // Display the price
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Text(
//                     '\$${widget.price.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Display bedrooms and bathrooms in a row
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Row(
//                 children: [
//                   Icon(Icons.bed, size: 20),
//                   SizedBox(width: 5),
//                   Text('${widget.bedrooms} Bedrooms'),
//                   SizedBox(width: 20),
//                   Icon(Icons.bathtub, size: 20),
//                   SizedBox(width: 5),
//                   Text('${widget.bathrooms} Bathrooms'),
//                 ],
//               ),
//             ),

//             // Display amenities in rows of 2 items per row
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: [
//                   if (widget.amenitiesMap['Malls'] == true)
//                     _buildAmenityIcon(Icons.local_mall, 'Malls'),
//                   if (widget.amenitiesMap['Schools'] == true)
//                     _buildAmenityIcon(Icons.school, 'Schools'),
//                   if (widget.amenitiesMap['Police Station'] == true)
//                     _buildAmenityIcon(Icons.local_police, 'Police Station'),
//                   if (widget.amenitiesMap['Shopping Centre'] == true)
//                     _buildAmenityIcon(Icons.shopping_cart, 'Shopping Centre'),
//                   if (widget.hasSwimmingPool)
//                     _buildAmenityIcon(Icons.pool, 'Swimming Pool'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to build an amenity icon with a label
//   Widget _buildAmenityIcon(IconData icon, String label) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 20),
//         SizedBox(width: 5),
//         Text(label),
//       ],
//     );
//   }
// }