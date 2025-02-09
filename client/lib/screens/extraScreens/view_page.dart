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

  Widget _buildFeatureRow(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
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
                      Text(
                        type,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        location,
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bedrooms: $bedrooms',
                              style: TextStyle(fontSize: 18)),
                          Text('Bathrooms: $bathrooms',
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      SizedBox(height: 16),
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
                            _buildFeatureRow('Security', hasSecurity),
                            _buildFeatureRow('Parking', hasParking),
                            _buildFeatureRow('Swimming Pool', hasSwimmingPool),
                            _buildFeatureRow('Balcony', hasBalcony),
                            _buildFeatureRow('Gym', hasGym),
                            _buildFeatureRow('Pet Friendly', isPetFriendly),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
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
                            ...amenities.entries
                                .map((entry) => _buildFeatureRow(
                                    entry.key, entry.value ?? false))
                                .toList(),
                          ],
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

//   Widget _buildFeatureRow(String label, bool value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: TextStyle(fontSize: 16)),
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
//                       Text(
//                         type,
//                         style: TextStyle(
//                             fontSize: 24, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         location,
//                         style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         '\$${price.toStringAsFixed(2)}',
//                         style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue),
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Bedrooms: $bedrooms',
//                               style: TextStyle(fontSize: 18)),
//                           Text('Bathrooms: $bathrooms',
//                               style: TextStyle(fontSize: 18)),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       Container(
//                         padding: EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Closest Amenities',
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 8),
//                             ...amenities.entries.map((entry) =>
//                                 _buildFeatureRow(
//                                     entry.key, entry.value ?? false)),
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
// }