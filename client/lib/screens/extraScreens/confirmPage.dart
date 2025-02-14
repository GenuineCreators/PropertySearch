import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class ConfirmPage extends StatefulWidget {
  final String houseID;

  const ConfirmPage({super.key, required this.houseID});

  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>> _houseData;
  DateTime _selectedDate =
      DateTime.now().add(Duration(days: 1)); // Default: Next day
  TimeOfDay _selectedTime = TimeOfDay(hour: 16, minute: 0); // Default: 4:00 PM

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Details'),
      ),
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
          final name = houseData['name'] as String;
          final price = houseData['price'] as double;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Row with imageUrls and name, price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the first image from imageUrls
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(imageUrls[0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Column with name and price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(), // Divider below the row

                // Clickable containers for date and time
                Column(
                  children: [
                    // Date of Visit
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date of Visit: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Time of Visit
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time of Visit: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(), // Divider below the containers
              ],
            ),
          );
        },
      ),
    );
  }
}
