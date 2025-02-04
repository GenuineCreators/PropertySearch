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
    // Ensure the imageUrls list is available
    _houseData.then((data) {
      final imageUrls = data['imageUrls'] as List<dynamic>;
      final length = imageUrls.length;

      setState(() {
        _currentImageIndex = (_currentImageIndex + direction) % length;
        if (_currentImageIndex < 0) {
          _currentImageIndex = length - 1; // Wrap around to the last image
        }
      });
    });
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

          return SingleChildScrollView(
            child: Column(
              children: [
                // Display the current image with navigation buttons
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
                    // Left navigation button
                    Positioned(
                      left: 10,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => _navigateImage(-1),
                      ),
                    ),
                    // Right navigation button
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
                // Display house details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
