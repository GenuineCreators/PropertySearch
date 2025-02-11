import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPage extends StatefulWidget {
  final String houseID;

  const ViewPage({super.key, required this.houseID});

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>> _houseData;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _houseData = _fetchHouseData();
  }

  Future<Map<String, dynamic>> _fetchHouseData() async {
    final doc = await _firestore.collection('houses').doc(widget.houseID).get();
    if (!doc.exists) {
      throw Exception('House not found');
    }
    return doc.data()!;
  }

  void _navigateImage(int direction) {
    _houseData.then((data) {
      final imageUrls = data['imageUrls'] as List<dynamic>;
      final length = imageUrls.length;

      setState(() {
        _currentImageIndex = (_currentImageIndex + direction) % length;
        if (_currentImageIndex < 0) {
          _currentImageIndex = length - 1;
        }
      });
    });
  }

  // Helper method to build a feature row with an icon
  Widget _buildFeatureRow(String label, bool value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue), // Display the icon
        SizedBox(width: 8), // Add spacing between icon and text
        Text(label, style: TextStyle(fontSize: 16)),
        Spacer(), // Add space between text and check/cancel icon
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _houseData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data found.'));
          }

          final houseData = snapshot.data!;
          final imageUrls = houseData['imageUrls'] as List<dynamic>;
          final type = houseData['type'] as String;
          final location = houseData['location'] as String;
          final price = houseData['price'] as double;
          final bedrooms = houseData['bedrooms'] as int;
          final bathrooms = houseData['bathrooms'] as int;
          final hasSecurity = houseData['hasSecurity'] as bool? ?? false;
          final hasParking = houseData['hasParking'] as bool? ?? false;
          final hasSwimmingPool =
              houseData['hasSwimmingPool'] as bool? ?? false;
          final hasBalcony = houseData['hasBalcony'] as bool? ?? false;
          final hasGym = houseData['hasGym'] as bool? ?? false;
          final isPetFriendly = houseData['isPetFriendly'] as bool? ?? false;
          final amenities =
              houseData['amenities'] as Map<String, dynamic>? ?? {};
          final description = houseData['description'] as String? ??
              'No description available.';

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrls[_currentImageIndex]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => _navigateImage(-1),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      child: IconButton(
                        icon:
                            Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onPressed: () => _navigateImage(1),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type, Location, and Price
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.blue), // Icon for type
                          SizedBox(width: 8),
                          Text(
                            type,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.blue), // Icon for location
                          SizedBox(width: 8),
                          Text(
                            location,
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money,
                              color: Colors.blue), // Icon for price
                          SizedBox(width: 8),
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Bedrooms and Bathrooms
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bed,
                                  color: Colors.blue), // Icon for bedrooms
                              SizedBox(width: 8),
                              Text('Bedrooms: $bedrooms',
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.bathtub,
                                  color: Colors.blue), // Icon for bathrooms
                              SizedBox(width: 8),
                              Text('Bathrooms: $bathrooms',
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Home Highlights
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Home Highlights',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            _buildFeatureRow(
                                'Security', hasSecurity, Icons.security),
                            _buildFeatureRow(
                                'Parking', hasParking, Icons.local_parking),
                            _buildFeatureRow(
                                'Swimming Pool', hasSwimmingPool, Icons.pool),
                            _buildFeatureRow(
                                'Balcony', hasBalcony, Icons.balcony),
                            _buildFeatureRow(
                                'Gym', hasGym, Icons.fitness_center),
                            _buildFeatureRow(
                                'Pet Friendly', isPetFriendly, Icons.pets),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Closest Amenities
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Closest Amenities',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            ...amenities.entries.map((entry) =>
                                _buildFeatureRow(
                                    entry.key,
                                    entry.value ?? false,
                                    _getAmenityIcon(entry.key))),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),

                      // Check Availability Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle "Check Availability" button click
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Check Availability',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to get an icon for amenities
  IconData _getAmenityIcon(String amenity) {
    switch (amenity) {
      case 'Schools':
        return Icons.school;
      case 'Malls':
        return Icons.local_mall;
      case 'Shopping Centre':
        return Icons.shopping_cart;
      case 'Police Station':
        return Icons.local_police;
      default:
        return Icons.help_outline; // Default icon for unknown amenities
    }
  }
}










// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ViewPage extends StatefulWidget {
//   final String houseID;

//   const ViewPage({super.key, required this.houseID});

//   @override
//   _ViewPageState createState() => _ViewPageState();
// }

// class _ViewPageState extends State<ViewPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late Future<Map<String, dynamic>> _houseData;
//   int _currentImageIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _houseData = _fetchHouseData();
//   }

//   Future<Map<String, dynamic>> _fetchHouseData() async {
//     final doc = await _firestore.collection('houses').doc(widget.houseID).get();
//     if (!doc.exists) {
//       throw Exception('House not found');
//     }
//     return doc.data()!;
//   }

//   void _navigateImage(int direction) {
//     _houseData.then((data) {
//       final imageUrls = data['imageUrls'] as List<dynamic>;
//       final length = imageUrls.length;

//       setState(() {
//         _currentImageIndex = (_currentImageIndex + direction) % length;
//         if (_currentImageIndex < 0) {
//           _currentImageIndex = length - 1;
//         }
//       });
//     });
//   }

//   // Helper method to build a feature row with an icon
//   Widget _buildFeatureRow(String label, bool value, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.blue), // Display the icon
//         SizedBox(width: 8), // Add spacing between icon and text
//         Text(label, style: TextStyle(fontSize: 16)),
//         Spacer(), // Add space between text and check/cancel icon
//         Icon(
//           value ? Icons.check_circle : Icons.cancel,
//           color: value ? Colors.green : Colors.red,
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _houseData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData) {
//             return Center(child: Text('No data found.'));
//           }

//           final houseData = snapshot.data!;
//           final imageUrls = houseData['imageUrls'] as List<dynamic>;
//           final type = houseData['type'] as String;
//           final location = houseData['location'] as String;
//           final price = houseData['price'] as double;
//           final bedrooms = houseData['bedrooms'] as int;
//           final bathrooms = houseData['bathrooms'] as int;
//           final hasSecurity = houseData['hasSecurity'] as bool? ?? false;
//           final hasParking = houseData['hasParking'] as bool? ?? false;
//           final hasSwimmingPool =
//               houseData['hasSwimmingPool'] as bool? ?? false;
//           final hasBalcony = houseData['hasBalcony'] as bool? ?? false;
//           final hasGym = houseData['hasGym'] as bool? ?? false;
//           final isPetFriendly = houseData['isPetFriendly'] as bool? ?? false;
//           final amenities =
//               houseData['amenities'] as Map<String, dynamic>? ?? {};

//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       height: 300,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: NetworkImage(imageUrls[_currentImageIndex]),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       left: 10,
//                       child: IconButton(
//                         icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//                         onPressed: () => _navigateImage(-1),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10,
//                       child: IconButton(
//                         icon:
//                             Icon(Icons.arrow_forward_ios, color: Colors.white),
//                         onPressed: () => _navigateImage(1),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Type, Location, and Price
//                       Row(
//                         children: [
//                           Icon(Icons.home, color: Colors.blue), // Icon for type
//                           SizedBox(width: 8),
//                           Text(
//                             type,
//                             style: TextStyle(
//                                 fontSize: 24, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(Icons.location_on,
//                               color: Colors.blue), // Icon for location
//                           SizedBox(width: 8),
//                           Text(
//                             location,
//                             style: TextStyle(
//                                 fontSize: 18, color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(Icons.attach_money,
//                               color: Colors.blue), // Icon for price
//                           SizedBox(width: 8),
//                           Text(
//                             '\$${price.toStringAsFixed(2)}',
//                             style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),

//                       // Bedrooms and Bathrooms
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.bed,
//                                   color: Colors.blue), // Icon for bedrooms
//                               SizedBox(width: 8),
//                               Text('Bedrooms: $bedrooms',
//                                   style: TextStyle(fontSize: 18)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Icon(Icons.bathtub,
//                                   color: Colors.blue), // Icon for bathrooms
//                               SizedBox(width: 8),
//                               Text('Bathrooms: $bathrooms',
//                                   style: TextStyle(fontSize: 18)),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),

//                       // Home Highlights
//                       Container(
//                         padding: EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Home Highlights',
//                                 style: TextStyle(
//                                     fontSize: 20, fontWeight: FontWeight.bold)),
//                             SizedBox(height: 8),
//                             _buildFeatureRow(
//                                 'Security', hasSecurity, Icons.security),
//                             _buildFeatureRow(
//                                 'Parking', hasParking, Icons.local_parking),
//                             _buildFeatureRow(
//                                 'Swimming Pool', hasSwimmingPool, Icons.pool),
//                             _buildFeatureRow(
//                                 'Balcony', hasBalcony, Icons.balcony),
//                             _buildFeatureRow(
//                                 'Gym', hasGym, Icons.fitness_center),
//                             _buildFeatureRow(
//                                 'Pet Friendly', isPetFriendly, Icons.pets),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 16),

//                       // Closest Amenities
//                       Container(
//                         padding: EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Closest Amenities',
//                                 style: TextStyle(
//                                     fontSize: 20, fontWeight: FontWeight.bold)),
//                             SizedBox(height: 8),
//                             ...amenities.entries
//                                 .map((entry) => _buildFeatureRow(
//                                     entry.key,
//                                     entry.value ?? false,
//                                     _getAmenityIcon(entry.key)))
//                                 .toList(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Helper method to get an icon for amenities
//   IconData _getAmenityIcon(String amenity) {
//     switch (amenity) {
//       case 'Schools':
//         return Icons.school;
//       case 'Malls':
//         return Icons.local_mall;
//       case 'Shopping Centre':
//         return Icons.shopping_cart;
//       case 'Police Station':
//         return Icons.local_police;
//       default:
//         return Icons.help_outline; // Default icon for unknown amenities
//     }
//   }
// }