import 'package:client/screens/extraScreens/view_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of items for the scrollable containers
  final List<Map<String, dynamic>> _scrollableItems = [
    {'icon': Icons.access_time, 'label': 'Time'},
    {'icon': Icons.attach_money, 'label': 'Price'},
    {'icon': Icons.money_off, 'label': 'Rent'},
    {'icon': Icons.sell, 'label': 'Sale'},
    {'icon': Icons.home, 'label': 'AirBnb'},
    {'icon': Icons.bed, 'label': 'Bedroom'},
    {'icon': Icons.bathtub, 'label': 'Bathroom'},
    {'icon': Icons.pool, 'label': 'Swimming'},
    {'icon': Icons.fitness_center, 'label': 'Gym'},
    {'icon': Icons.pets, 'label': 'Pets'},
    {'icon': Icons.local_parking, 'label': 'Parking'},
    {'icon': Icons.balcony, 'label': 'Balcony'},
    {'icon': Icons.security, 'label': 'Security'},
    {'icon': Icons.school, 'label': 'Schools'},
    {'icon': Icons.local_mall, 'label': 'Malls'},
    {'icon': Icons.shopping_cart, 'label': 'Shopping Center'},
    {'icon': Icons.local_police, 'label': 'Police Station'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the AppBar
      body: Column(
        children: [
          // Search Button at the Top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Scrollable Small Containers
          Container(
            height: 100, // Height of the scrollable row
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _scrollableItems.length,
              itemBuilder: (context, index) {
                final item = _scrollableItems[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], size: 30, color: Colors.blue),
                      SizedBox(height: 8),
                      Text(
                        item['label'],
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Rest of the Body
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('houses').snapshots(),
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
                    final amenities =
                        house['amenities'] as Map<String, dynamic>;
                    final hasSwimmingPool = house['hasSwimmingPool'] as bool;
                    final type = house['type'] as String;
                    final location = house['location'] as String;
                    final houseID = house["houseID"];

                    // Convert amenities to Map<String, bool>
                    final amenitiesMap = amenities.map<String, bool>(
                      (key, value) => MapEntry(key, value as bool),
                    );

                    return GestureDetector(
                      onTap: () {
                        // Navigate to ViewPage with the houseID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewPage(houseID: houseID),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            // Display the imageUrls in a PageView for horizontal scrolling
                            if (imageUrls.isNotEmpty)
                              Container(
                                height: 150, // Reduced height
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                ),
                                child: Stack(
                                  children: [
                                    // PageView for horizontal scrolling
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      child: PageView.builder(
                                        itemCount: imageUrls.length,
                                        itemBuilder: (context, imageIndex) {
                                          return Image.network(
                                            imageUrls[imageIndex],
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    // Display the type at the top left corner
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                    // Display the love icon at the top right corner
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
                                          // Handle love icon click
                                        },
                                      ),
                                    ),
                                    // Display a dot indicator at the bottom center
                                    Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          imageUrls.length,
                                          (index) => Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 4),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    _buildAmenityIcon(
                                        Icons.local_mall, 'Malls'),
                                  if (amenitiesMap['Schools'] == true)
                                    _buildAmenityIcon(Icons.school, 'Schools'),
                                  if (amenitiesMap['Police Station'] == true)
                                    _buildAmenityIcon(
                                        Icons.local_police, 'Police Station'),
                                  if (amenitiesMap['Shopping Centre'] == true)
                                    _buildAmenityIcon(
                                        Icons.shopping_cart, 'Shopping Centre'),
                                  if (hasSwimmingPool)
                                    _buildAmenityIcon(
                                        Icons.pool, 'Swimming Pool'),
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
          ),
        ],
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









// import 'package:client/screens/extraScreens/view_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Houses'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('houses').snapshots(),
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
//               final location = house['location'] as String;
//               final houseID = house["houseID"];

//               // Convert amenities to Map<String, bool>
//               final amenitiesMap = amenities.map<String, bool>(
//                 (key, value) => MapEntry(key, value as bool),
//               );

//               return GestureDetector(
//                 onTap: () {
//                   // Navigate to ViewPage with the houseID
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ViewPage(houseID: houseID),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     children: [
//                       // Display the imageUrls in a PageView for horizontal scrolling
//                       if (imageUrls.isNotEmpty)
//                         Container(
//                           height: 150, // Reduced height
//                           decoration: BoxDecoration(
//                             borderRadius:
//                                 BorderRadius.vertical(top: Radius.circular(10)),
//                           ),
//                           child: Stack(
//                             children: [
//                               // PageView for horizontal scrolling
//                               ClipRRect(
//                                 borderRadius: BorderRadius.vertical(
//                                     top: Radius.circular(10)),
//                                 child: PageView.builder(
//                                   itemCount: imageUrls.length,
//                                   itemBuilder: (context, imageIndex) {
//                                     return Image.network(
//                                       imageUrls[imageIndex],
//                                       fit: BoxFit.cover,
//                                     );
//                                   },
//                                 ),
//                               ),
//                               // Display the type at the top left corner
//                               Positioned(
//                                 top: 10,
//                                 left: 10,
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 4),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black54,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     type,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // Display a dot indicator at the bottom center
//                               Positioned(
//                                 bottom: 10,
//                                 left: 0,
//                                 right: 0,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: List.generate(
//                                     imageUrls.length,
//                                     (index) => Container(
//                                       margin:
//                                           EdgeInsets.symmetric(horizontal: 4),
//                                       width: 8,
//                                       height: 8,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Colors.white.withOpacity(0.5),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                       // Display the price
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             top: 8, bottom: 8, left: 18, right: 18),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               location,
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               '\$${price.toStringAsFixed(2)}',
//                               style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Display bedrooms and bathrooms in a row
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Row(
//                           children: [
//                             Icon(Icons.bed, size: 20),
//                             SizedBox(width: 5),
//                             Text('$bedrooms Bedrooms'),
//                             SizedBox(width: 20),
//                             Icon(Icons.bathtub, size: 20),
//                             SizedBox(width: 5),
//                             Text('$bathrooms Bathrooms'),
//                           ],
//                         ),
//                       ),

//                       // Display amenities in rows of 2 items per row
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Wrap(
//                           spacing: 10,
//                           runSpacing: 10,
//                           children: [
//                             if (amenitiesMap['Malls'] == true)
//                               _buildAmenityIcon(Icons.local_mall, 'Malls'),
//                             if (amenitiesMap['Schools'] == true)
//                               _buildAmenityIcon(Icons.school, 'Schools'),
//                             if (amenitiesMap['Police Station'] == true)
//                               _buildAmenityIcon(
//                                   Icons.local_police, 'Police Station'),
//                             if (amenitiesMap['Shopping Centre'] == true)
//                               _buildAmenityIcon(
//                                   Icons.shopping_cart, 'Shopping Centre'),
//                             if (hasSwimmingPool)
//                               _buildAmenityIcon(Icons.pool, 'Swimming Pool'),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
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